{smcl}
{* *! version 1.0.1  28may2026}{...}
{hline}
{cmd:help redcap_export}
{hline}

{title:Title}

{phang}
{bf:redcap_export} {hline 2} Exports data from REDCap via API, imports it into Stata and labels it.


{marker syntax}{...}
{title:Syntax}

{p 4 6 2}
{cmdab:redcap_export} {cmd:,} {opth path(string)} {opth curl(string)} {opth api_url(string)}  {opth token(string)}  [{it:options}]

{synoptset 38 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt:{opth path(string)}} path to the folder where the data should be stored {p_end}
{synopt:{opth curl(string)}} location of the curl.exe file {p_end}
{synopt:{opth api_url(string)}} REDCap api url, e.g. https://redcap.ctu.unibe.ch/api/ {p_end}
{synopt:{opth token(string)}} API token {p_end}

{syntab:Optional}
{synopt:{opth additems(string)}} items to be exported in addition to the default, separated by spaces {p_end}
{synopt:{opth allitems(string)}} all items to be exported (replaces the default), separated by spaces{p_end}
{synopt:{opth curlopt(string)}} additional export options, separated by comma{p_end}
{synopt:{opt bindq:uotes(loose|strict|nobind)}} specify how to handle double quotes (default is {it:strict}); see {help import delimited} {p_end}
{synopt:{opt maxquotedr:ows(#|unlimited)}} number of rows allowed inside a quoted string (default is {it:unlimited}); see {help import delimited}.{p_end}
{synopt:{opt noi:sily}} displays details of the process {p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:redcap_export} exports data from REDCap via API, imports it into Stata and labels it.
The command requires an installation of cURL ({browse "https://curl.se/":curl}) 
with the {it:curl.exe} file specified via {opt curl()},
the URL of the REDCap API and the API token.
If you don't know if or where curl is installed, the command {it:!where /r . "curl.exe"} 
	can be used to search to current working directory. {p_end}
	
{pstd}	
The prepared files will be stored under {opt path()} in three automatically generated folders:
{it:raw_data}, {it:labelled_data}, and {it:form_data}.{p_end}
	
{pstd}		
By default, the follwing API items are exported:
{it: project, metadata, instrument, arm, event, formEventMapping, record, user}.
Further items can be specified via {opt additems()}, a completely new list can be given via {opt allitems()}.{p_end}

{pstd}	
Default export options inlcude {it:exportDataAccessGroups=TRUE} and {it:exportSurveyFields=TRUE}, further options can be 
specified via {opt curlopt(string)}, separated by comma. 
{opt curlopt(exportDataAccessGroups=FALSE, exportSurveyFields=FALSE)} would change the default.{p_end}

{pstd}	
Options {opt bindq:uotes(loose|strict|nobind)}} and {opt maxquotedr:ows(#|unlimited)}} define
how double quotes are handled when importing the csv-files form curl and are passed down 
to Stata's {help import delimited}. By default, {cmd:redcap_export} uses {it:strict}, which 
tells import delimited that once it finds one double quote on a line of data, it should keep
searching through the data for the matching double quote even if that double quote is on another line. 
With this option the number of rows allowed inside a quoted string has to be specified, for which the default is {it:unlimited}.
	

{marker results}{...}
{title:Stored results}

{phang} {cmd:redcap_export} stores the exported files in three folders under {opt path()}:{p_end}

{phang2}- {it: raw_data} contains a raw csv and dta files for each API item{p_end}

{phang2}- {it: labelled_data} contains the labelled record dta file and helper files for labelling{p_end}

{phang2}- {it: form_data} contains the labelled dta files for each eCRF forms{p_end}
	
	
{marker examples}{...}
{title:Examples}

{pstd}{p_end}

{pstd}Default {p_end}

{phang}{cmd: .redcap_export, path("project\prepared_data") curl("C:\Windows\System32\curl.exe") api_url("https://redcap.ctu.unibe.ch/api/") token("$mytoken") noisily}{p_end}
	
{pstd}Only record and meta data{p_end}

{phang}{cmd: .redcap_export, path("project\prepared_data") curl("C:\Windows\System32\curl.exe") api_url("https://redcap.ctu.unibe.ch/api/") token("$mytoken") allitems(record metadata) noisily}{p_end}
	
{pstd}Not including data access group but include check box labels {p_end}

{phang}{cmd: .redcap_export, path("project\prepared_data") curl("C:\Windows\System32\curl.exe") api_url("https://redcap.ctu.unibe.ch/api/") token("$mytoken") curlopt(exportDataAccessGroups=FALSE, exportCheckboxLabel=TRUE, ) noisily}{p_end}
	





