// the 'make.do' file is automatically created by 'github' package.
// execute the code below to generate the package installation files.
// DO NOT FORGET to update the version of the package, if changed!
// for more information visit http://github.com/haghish/github


*run test
//cd "test"

//do "00_masterfile.do"


*generate make file 
//cd ".."

make stata_redcap, replace toc pkg version(1.0.1)                           ///
     license("Academic Free License v3.0")                                   ///
     author("Lukas Bütikofer")                                              ///
     affiliation("DCR Bern")                                                 ///
     email("lukas.buetikofer@unibe.ch")                                  ///
     url("https://github.com/dcr-unibe-ch/stata_redcap")                               ///
     title("stata_redcap")                                                         ///
     description("REDCap export")                                           ///
     install("redcap_export.ado;redcap_export.sthlp;xlabel.ado;xlabel.hlp;xvarlabel.ado;xvarlabel.hlp") ///
     ancillary("")                                                         
