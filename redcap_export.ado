*! version 1.0.0 27May2026

*wrapper
***********

cap program drop redcap_export
program redcap_export, nclass

version 16

syntax, path(string) curl(string) api_url(string) token(string) ///
	[additems(string) allitems(string) curlopt(string) NOIsily]


 quietly {
 
	cap	shell mkdir "`path'"
	cap	shell mkdir "`path'/raw_data"
	cap	shell mkdir "`path'/labelled_data"
	cap	shell mkdir "`path'/form_data"

	`noisily' redcap_api, pathraw("`path'/raw_data") ///
		curl("`curl'") api_url("`api_url'") token("`token'") ///
		additems(`additems') allitems(`allitems') ///
		curlopt(`curlopt')

	`noisily' redcap_label, pathraw("`path'/raw_data") ///
		pathlab("`path'/labelled_data")

	`noisily' redcap_forms, pathraw("`path'/raw_data") ///
		pathlab("`path'/labelled_data") ///
		pathform("`path'/form_data")

}


end	
	
	

*import 
***********

cap program drop redcap_api
program redcap_api, nclass

version 16

syntax, pathraw(string) curl(string) api_url(string) token(string) ///
	[additems(string) allitems(string) curlopt(string)]


*curl forms
if "`allitems'"!="" {
	local tlist `allitems' `additems'
}
else {
	local tlist project metadata instrument arm event formEventMapping record user `additems'
}


*curk options
local datacc --form exportDataAccessGroups=TRUE
local survf --form exportSurveyFields=TRUE
local addopt

if "`curlopt'"!="" {
	
	tokenize "`curlopt'", parse(",")
		
	local i = 1
	
	while "``i''" != "" {
    
		if "``i''" != "," {
			local addopt `addopt' --form ``i''
		}
		
		local i = `i' + 1
	}

	if strpos("`curlopt'","exportDataAccessGroups")>0 {
		local datacc
	}
	if strpos("`curlopt'","exportSurveyFields")>0 {
		local survf
	}

}

dis ""
dis as result "Curl options:"
dis as text "`datacc' `survf' `addopt'"

//use curl to export the tables to CSVs and then dta 
foreach tab of local tlist {
	
	dis ""
	dis as result "`tab'"
	
	shell `curl' --output "`pathraw'/`tab'.csv" ///
		--form token=`token' ///
		--form content=`tab' ///
		--form format=csv ///
		`datacc' ///
		`survf' ///
		`addopt' ///
		`api_url'
	
	qui import delim "`pathraw'/`tab'.csv", clear bindquotes(strict)  encoding(utf-8)
	
	qui save "`pathraw'/`tab'", replace
}

end 


*label
***********

cap program drop redcap_label
program redcap_label, nclass

version 16

syntax, pathraw(string)  pathlab(string)
	
*variable labels
use "`pathraw'/metadata", clear
qui drop if field_type == "descriptive"
qui keep field_name field_label 
qui  rename field_name var
qui rename field_label text
qui  save "`pathlab'/varlabels", replace

*variable types
use "`pathraw'/metadata", clear

dis ""
dis as result "Field types"

tab field_type


*a) radio/dropdown 
use "`pathraw'/metadata", clear

qui count if field_type == "radio" | field_type=="dropdown"
local radios = r(N)
if `radios' > 0 {

	qui keep if field_type == "radio" | field_type=="dropdown"
	qui gen cat = field_name + "_l"

	preserve
		qui rename field_name var 
		qui keep var cat
		qui order var cat
		qui save "`pathlab'/varvallabels", replace
	restore
	
	qui split select_choices_or_calculations, gen(opt) parse("|")
	qui reshape long opt, i(cat) j(opti)

	qui keep opt cat
	qui drop if opt == ""
	
	//replace commas if there are more than 1:
	qui egen noc=nss(opt) , find(",")
	assert strpos(opt,"*")==0
	qui replace opt = reverse(subinstr(reverse(opt),",","*",noc-1))
	qui drop noc
	qui egen noc=nss(opt) , find(",")
	assert noc==1
	qui drop noc
	
	qui split opt, parse(",")
	qui replace opt2 = trim(opt2)
	qui drop opt
	
	//change back to comma
	qui replace opt2 = subinstr(opt2,"*",",",.)

	qui rename opt1 keynr
	qui rename opt2 keytext
	qui destring keynr, replace
	qui order cat keynr keytext
	qui save "`pathlab'/vallabels", replace
}


*b) yesno
use "`pathraw'/metadata", clear
qui count if field_type == "yesno"
local yesno = r(N)
if `yesno' > 0 {
	
	qui keep if field_type == "yesno"
	qui rename field_name var 
	qui keep var
	qui gen cat="yesno_l"
	
	preserve
	qui append using "`pathlab'/varvallabels"
	qui save "`pathlab'/varvallabels", replace
	restore
	
	qui expand 2, gen(keynr)
	qui gen keytext="Yes" if keynr==1
	qui replace keytext="No" if keynr==0
	qui keep cat keynr keytext
	qui append using "`pathlab'/vallabels"
	qui save "`pathlab'/vallabels", replace
	
}


*c) check box 
use "`pathraw'/metadata", clear

//var labels
preserve
qui count if field_type == "checkbox"
local boxes = r(N)
if `boxes' > 0 {
	qui keep if field_type == "checkbox"
	qui split select_choices_or_calculations, gen(opt) parse("|")
	qui reshape long opt, i(field_name) j(opti)
	qui drop if opt == ""

	qui drop select_choices_or_calculations
	
	qui split opt, parse(",")
	qui replace opt1 = trim(opt1)
	qui replace opt2 = trim(opt2)

	qui gen var = field_name + "___" + opt1
	qui gen text = field_label + " = " + opt2
	qui keep var text 
	qui save "`pathlab'/checklabels", replace
	
}
restore

// val labels
preserve
qui count if field_type == "checkbox"
local boxes = r(N)
if `boxes' > 0 {
	qui keep if field_type == "checkbox"
	qui split select_choices_or_calculations, gen(opt) parse("|")
	qui reshape long opt, i(field_name) j(opti)
	qui drop if opt == ""

	qui drop select_choices_or_calculations
	
	qui split opt, parse(",")
	qui replace opt1 = trim(opt1)
		
	qui gen var = field_name + "___" + opt1
	qui gen cat = "checkuncheck"
	qui keep var cat 
	qui save "`pathlab'/checkvarvallabels", replace
	
	qui keep in 1/2
	qui keep cat
	qui gen byte keynr = _n - 1
	qui gen keytext = "unchecked" if keynr == 0
	qui replace keytext = "checked" if keynr == 1
	
	qui save "`pathlab'/checkvallabels", replace

}
restore


*d) date and datetime variables

use "`pathraw'/metadata", clear
qui keep if strpos(text_validation_type_or_show_sli,"date_")>0
qui keep field_name
qui levelsof field_name, local(datevars)
qui save "`pathlab'/datvars",replace

qui use "`pathraw'/metadata", clear
qui keep if strpos(text_validation_type_or_show_sli,"datetime_")>0
qui keep field_name
qui levelsof field_name, local(datetimevars)
qui save "`pathlab'/datetimevars",replace


* labeling
****************
use "`pathraw'/record", clear

//destring date variables
foreach var of local datevars {
	qui tostring `var', replace
	qui gen _date_ = date(`var',"YMD")
	qui order _date, after(`var')
	qui format _date %td
	qui drop `var'
	qui rename _date_ `var'
	
}

//destring datetime variables
foreach var of local datetimevars {
	qui tostring `var', replace
	qui gen _date_ = clock(`var',"YMDhm")
	qui order _date, after(`var')
	qui format _date %tc
	qui drop `var'
	qui rename _date_ `var'
}

//label variables
xvarlabel , varinfo("`pathlab'/varlabels")

//label values
if `radios' > 0 {
	xlabel , varinfo("`pathlab'/varvallabels") labinfo("`pathlab'/vallabels")
}

//checkboxes, special case
if `boxes' > 0 {
	xvarlabel , varinfo("`pathlab'/checklabels")
	xlabel , varinfo("`pathlab'/checkvarvallabels") labinfo("`pathlab'/checkvallabels")
}

qui save "`pathlab'/record", replace

end



*****************
*generate single forms
***************

cap program drop redcap_forms
program redcap_forms, nclass

version 16

syntax, pathraw(string) pathlab(string) pathform(string)

tempfile keepforms

use "`pathraw'/formEventMapping", clear
qui rename form form_name
qui mmerge form_name using "`pathraw'/metadata", type(n:n)
qui assert _merge==3
qui drop if field_type == "descriptive"
qui save "`pathlab'/varforms", replace


use "`pathlab'/varforms", clear

dis ""
display as result "Forms"
tab form_name

qui levelsof form_name, local(fname)

foreach f of local fname {
	
	use "`pathlab'/varforms", clear
	qui keep if form_name=="`f'"
	
	preserve
	qui  keep unique_event_name
	qui  duplicates drop
	qui rename unique_event_name redcap_event_name
	qui  save "`keepforms'", replace
	restore
	
	local keeplist
	
	//non-checkbox variables
	qui  levelsof field_name if field_type!="checkbox", local(vars) 
	foreach l of local vars {
			local keeplist `keeplist' `l'
	}	
	//checkbox variables: several entries
	qui  levelsof field_name if field_type=="checkbox", local(vars)
	foreach l of local vars {
			local keeplist `keeplist' `l'___*
	}
	

	use "`pathlab'/record", clear	
	qui mmerge redcap_event_name using  "`keepforms'", type(n:1)
	qui keep if _merge==3
	sort record_id
	local fs=substr("`f'_complete",1,32)
	label define formstat_l 0 "Incomplete" 1 "Unverified" 2 "Complete", replace	
	label val `fs' formstat_l
	
	//repeating form indicator
	cap confirm variable redcap_repeat_instrument redcap_repeat_instance
	if _rc {
		qui  keep record_id redcap_event_name `keeplist' `fs'
	}
	else {
		qui  keep record_id redcap_event_name  redcap_repeat_instrument redcap_repeat_instance `keeplist' `fs'
	}
	
	qui save "`pathform'/`f'", replace
}

end

