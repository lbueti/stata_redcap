{smcl}
{* *! version 1.0.0  27may2026}{...}
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


{marker options}{...}
{title:Options}
{p 4 6 2}

{syntab:Main}
{phang}
{opth path(string)} path to the folder where the data should be stored {p_end}
{phang}
{opth curl(string)} full path to the curl.exe file {p_end}
{phang}
{opth api_url(string)} REDCap api url, e.g. https://redcap.ctu.unibe.ch/api/ {p_end}
{phang}
{opth token(string)} the API token {p_end}

{syntab:Options}
{phang}
{opth additems(string)} items to be exported in addition to the default, separated by spaces{p_end}
{phang}
{opth allitems(string)} all items to be exported (replaces the default), separated by spaces{p_end}
{phang}
{opth curlopt(string)} additional export options, separated by comma{p_end}
{phang}
{opt bindq:uotes(loose|strict|nobind)} Specify how to handle double quotes; see {help import delimited}{p_end}
{phang}
{opt maxquotedr:ows(#|unlimited)} Number of rows allowed inside a quoted string when {cmd:bindquotes(strict)} is specified; see {help import delimited}.{p_end}
{phang}
{opt noi:sily} Display details of the process {p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:redcap_export} exports data from REDCap via API, imports it into Stata and labels it.
The command requires an installation of cURL ({browse "https://curl.se/":curl}) with the {it:curl.exe} file specified via {opt curl()},
the URL of the REDCap API {opt api_url()} and the API token {opt token()}.
If you don't know if or where curl is installed, command !where /r . "curl.exe" can be used to search to current working directory {p_end}
	
{pstd}	
The prepared files will be stored under {opt path()} in three automatically generated folders:
{it:raw_data}, {it:labelled_data}, and {it:form_data}.{p_end}
	
{pstd}		
By default, the follwing API items are exported: project, metadata, instrument, arm, event, formEventMapping, record, user.
Further items can be specified via {opt additems()}, a completely new list can be given via {opt allitems()}.{p_end}

{pstd}	
Default export options included are {it:exportDataAccessGroups=TRUE} and {it:exportSurveyFields=TRUE}, further options can be 
	specified via {opt curlopt(string)}, separated by comma. 
	{opt curlopt(exportDataAccessGroups=FALSE, exportSurveyFields=FALSE)} would change the default.{p_end}
	

{marker results}{...}
{title:Stored results}

{phang} {cmd:redcap_export} stores the exported files in three folders:{p_end}

{phang2}- {it: raw_data} contains raw csv and dta files for each API item{p_end}

{phang2}- {it: labelled_data} contains the labelled record dta file and hleper files for labelling{p_end}

{phang2}- {it: form_data} contains the labelled dta files separated by eCRF forms{p_end}
	
	
{marker examples}{...}
{title:Examples}

{pstd}{p_end}

{pstd}Default {p_end}

{phang}{cmd: .redcap_export, path("project\prepared_data") curl("C:\Windows\System32\curl.exe") api_url("https://redcap.ctu.unibe.ch/api/") token("$mytoken") noisily}{p_end}
	
{pstd}Only record and meta data{p_end}

{phang}{cmd: .redcap_export, path("project\prepared_data") curl("C:\Windows\System32\curl.exe") api_url("https://redcap.ctu.unibe.ch/api/") token("$mytoken") allitems(record metadata) noisily}{p_end}
	
{pstd}Not including data access group but include check box labels {p_end}

{phang}{cmd: .redcap_export, path("project\prepared_data") curl("C:\Windows\System32\curl.exe") api_url("https://redcap.ctu.unibe.ch/api/") token("$mytoken") curlopt(exportDataAccessGroups=FALSE, exportCheckboxLabel=TRUE, ) noisily}{p_end}
	





