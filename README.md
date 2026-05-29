_v. 1.0.2_  

`stata_redcap`
========

The `stata_redcap` package exports data from REDCap via API, imports it into Stata and labels it. 
The main function is called `redcap_export'.

Installation
------------

In order to install `stata_redcap` from github the github-package is required:

	net install github, from("https://haghish.github.io/github/")

You can then install `stata_redcap` with:

	github install dcr-unibe-ch/stata_redcap


Example
------------

	# Default settings
	redcap_export, path("project\prepared_data") curl("C:\Windows\System32\curl.exe") api_url("https://redcap.ctu.unibe.ch/api/") token("$mytoken") noisily
	
	# Add field names (usally not needed)
	redcap_export, path("project\prepared_data") curl("C:\Windows\System32\curl.exe") api_url("https://redcap.ctu.unibe.ch/api/") token("$mytoken") additems(exportFieldNames) noisily
	
	# Only record and meta data
	redcap_export, path("project\prepared_data") curl("C:\Windows\System32\curl.exe") api_url("https://redcap.ctu.unibe.ch/api/") token("$mytoken") allitems(record metadata) noisily
	
	# Not including data access group but include check box labels 
	redcap_export, path("project\prepared_data") curl("C:\Windows\System32\curl.exe") api_url("https://redcap.ctu.unibe.ch/api/") token("$mytoken") curlopt(exportDataAccessGroups=FALSE, exportCheckboxLabel=TRUE) noisily
	
	

Author
------

**Lukas Bütikofer**  
DCR Bern  
lukas.buetikofer@unibe.ch  
<https://github.com/dcr-unibe-ch/stata_redcap>  
