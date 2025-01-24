*! geoboundary v1.2 (09 Jan 2025)
*! Asjad Naqvi (asjadnaqvi@gmail.com)

* v1.2 (09 Jan 2025): Direct convertion to geoframe. WorldBank official layer added. Several fixes.
* v1.1 (08 Dec 2024): Added geoboundaries meta data. Added GDAM as an additional source. Added source(). Lower cases are now allowed. Added meta data.
* v1.0 (23 Nov 2024): First release


/*
Data source: 
GeoBoundaries: https://www.geoboundaries.org/, https://github.com/wmgeolab/geoBoundaries/
GADM: 
*/

/*

The Geographic Information System (GIS) data provided herein is for informational/educational purposes only and is not intended for use 
as a legal or engineering resource. While every effort has been made to ensure the accuracy and reliability of the data, it is provided 
"as is" without warranty of any kind.

The data provided through this GIS package assumes no liability for any inaccuracies, errors, or omissions in the data, 
nor for any decision made or action taken based on the information contained herein. 
Users of this data are responsible for verifying its accuracy and suitability for their intended purposes.

Please be advised that GIS data may be subject to change without notice due to updates, corrections, or other modifications. 
Users are encouraged to consult the original data sources or contact the provider for the most current information.

By accessing or using the GIS data provided through this package, you acknowledge and agree to these terms and conditions.


All files are in the standard EPSG: 4326 (WGS84) projection.

*/


cap prog drop geoboundary

program define geoboundary, rclass 
version 15
	
syntax anything, [level(string) convert replace remove name(string) source(string) country(string) iso(string) NOSEParator region(string) length(string) any(string) strict geoframe ]
	
	
	if "`anything'" == "WLD" | "`anything'"=="wld" {
		local baseurl https://github.com/wmgeolab/geoBoundaries/raw/refs/heads/main/releaseData/CGAZ
		local skip 1
	}
	else if "`anything'" == "meta" {
		gettoken subcmd 0: 0, parse(", ")	
		if "`subcmd'" == "meta" _geometa `0'
		*noi return list
		return local gadm `r(iso3_gadm)'
		return local geob `r(iso3_geob)'
	}
	else {
		local baseurl https://github.com/wmgeolab/geoBoundaries/raw/refs/heads/main/releaseData/gbOpen/
		local skip 0
	}
	
	
	
	if "`replace'"!= "" local rep replace
	
	local length1 : word count `level'
	local length2 : word count `anything'
	
	if "`anything'" != "meta" {
		if "`source'" != ""  {
			if !inlist("`source'", "geoboundaries", "geob", "gadm", "worldbank") {
				di as error "Correct {bf:source()} options are {ul:geoboundaries} or {ul:gadm}."
			}
		}
		else {
			local source geoboundaries
			di in green _newline "Option {bf:source()} not specified. Assuming {bf:geoboundaries} as the default."
		}
	}
	
	
	
	///////////////
	//  checks   //
	///////////////

	
	if "`source'" == "gadm" local level ALL
	
	if "`anything'" != "meta" {
		forval i = 1/`length2' {
			local lvl : word `i' of `anything'
			
			if length("`lvl'") != 3 {
				display as error "`lvl' is an invalid ISO3 code."
				exit
			}
		}
	}
	
	
	local errcount = 0

	forval i = 1/`length1' {
		local lvl : word `i' of `level'
		local lvl = upper("`lvl'")

		if !inlist("`lvl'", "ADM0", "ADM1", "ADM2", "ADM3", "ADM4", "ADM5", "ALL") {
			display as error "Option {ul:`lvl'} is not valid. Valid options are {ul:ADM0}, {ul:ADM1}, {ul:ADM2}, {ul:ADM3}, {ul:ADM4}, {ul:ADM5}, {ul:ALL}."
			local ++errcount
		}
		
		if `errcount' > 0 exit
	}
	
	if "`level'" == "ALL" | "`level'"=="all" {
		local level ADM0 ADM1 ADM2 ADM3 ADM4 ADM5
		local length1 : word count `level'
	}
	
	
	//////////////////////////
	//  geoBoundaries loop  //
	//////////////////////////
	
	quietly {
		
		if "`source'" == "" | "`source'" == "geoboundaries" | "`source'" == "geob" & "`anything'"!="meta" {
		
			foreach x of local anything {
			
				local x1 = upper("`x'")
			
				forval i = 1/`length1' {
					local lvl : word `i' of `level'
					local lvl = upper("`lvl'")
					
					// fetch
					noisily display in yellow _newline "`x1'-`lvl': Fetching" _continue
					
					local _check = 0
					
					if `skip'==0 {
						foreach j in shp prj shx dbf {
							capture copy "`baseurl'/`x1'/`lvl'/geoBoundaries-`x1'-`lvl'.`j'" "`x1'_`lvl'.`j'", `rep'

							if _rc!= 0 {
								local ++_check
							}	
						}
					}
					else {
						copy "`baseurl'/geoBoundariesCGAZ_`lvl'.zip" "WLD_`lvl'.zip", `replace'
						unzipfile WLD_`lvl', `rep'
						
						// delete the zip
						capture erase 	"WLD_`lvl'.zip"  // windows
						capture rm 		"WLD_`lvl'.zip"	 // MAC
						
						local check = 0
					}
					

					if `_check' != 0 {
						noisily display in red _continue " > Does not exist."
					}
					else {
					
						// convert (if specified)
						if "`convert'" != "" {
							
							
							if `skip'==0 {
								if "`name'"!="" {
									spshape2dta `x1'_`lvl', replace saving(`name'_`lvl')
									noisily display in yellow _continue " > {bf:`name'_`lvl'.dta}, {bf:`name'_`lvl'_shp.dta} saved"
									
									if "`geoframe'" != "" {
										geoframe create `name'_`lvl', `replace'
										noisily display in yellow _continue " > geoframe {bf:`name'_`lvl'} created"
									}
								}
								else {
									spshape2dta `x1'_`lvl', replace
									noisily display in yellow _continue " > {bf:`x1'_`lvl'.dta}, {bf:`x1'_`lvl'_shp.dta} saved"
									
									if "`geoframe'" != "" {
										geoframe create `x1'_`lvl', `replace'
										noisily display in yellow _continue " > geoframe {bf:`x1'_`lvl'} created"
									}
								}
							}
							else {
								if "`name'"!="" {					
									spshape2dta geoBoundariesCGAZ_`lvl', replace saving(`name'_`lvl')
									noisily display in yellow _continue " > {bf:`name'_`lvl'.dta}, {bf:`name'_`lvl'_shp.dta} saved"
									
									if "`geoframe'" != "" {
										geoframe create `name'_`lvl', `replace'
										noisily display in yellow _continue " > geoframe {bf:`name'_`lvl'} created"
									}
									
								}
								else {
									spshape2dta geoBoundariesCGAZ_`lvl', replace saving(WLD_`lvl')
									noisily display in yellow _continue " > {bf:WLD_`lvl'.dta}, {bf:WLD_`lvl'_shp.dta} saved"
									
									if "`geoframe'" != "" {
										geoframe create WLD_`lvl', `replace'
										noisily display in yellow _continue " > geoframe {bf:WLD_`lvl'} created"
									}
									
								}
							}
						}
						
						// delete raw files (if specified)
						if "`remove'" != "" {
							noisily display in yellow _continue  " > shapefiles deleted" 
							
							if `skip'==0 {
								foreach j in shp prj shx dbf {
									capture erase 	"`x1'_`lvl'.`j'" 	// Windows
									capture rm 		"`x1'_`lvl'.`j'"	// MAC
								}
							}
							else {
								foreach j in shp prj shx dbf {
									capture erase 	"geoBoundariesCGAZ_`lvl'.`j'"  // Windows
									capture rm 		"geoBoundariesCGAZ_`lvl'.`j'"  // MAC
								
								
								}							
							}
						}
					}
				}
				
				noisily display in yellow _continue  " > Done." 
				
			}
		}
		
		
		if "`source'" == "gadm" & "`anything'"!="meta" {
			
			foreach x of local anything {
			local x1 = upper("`x'")
				
				noisily display in yellow _newline "`x1'-`lvl': Fetching" _continue
				
				copy "https://geodata.ucdavis.edu/gadm/gadm4.1/shp/gadm41_`x1'_shp.zip" "`x1'.zip", `rep'

				unzipfile `x1', replace // ifilter(`"(.*\.(dbf)$)"')

				local x2  = lower("`x1'")
				local files : dir "." files "gadm41_`x1'_*.dbf"
				
				
				foreach y of local files {
					
					local layer = ustrregexra("`y'", ".dbf", "")
					
					
					local xtemp = ustrregexra("`layer'", "gadm41_`x2'_", "")
					local xtemp = "ADM" + "`xtemp'"
					
					if "`convert'"!= "" {	
						
						noisily display in yellow _newline "`x1'-`xtemp' > Converting to Stata format" _continue
						
						
						if "`name'"!="" {
							spshape2dta `layer', replace saving(`name'_`xtemp')
						}
						else {
							spshape2dta `layer', replace saving(`x1'_`xtemp')
						}
					}
						
					// delete raw files (if specified)
					if "`remove'" != "" {
						noisily display in yellow _continue  " > Deleting raw shapefiles" 
							
						capture erase 	"`x1'.zip"  // windows
						capture rm 		"`x1'.zip"  // MAC	
							
						foreach j in shp prj shx dbf cpg {
							capture erase 	"`layer'.`j'"  // windows
							capture rm 		"`layer'.`j'"  // MAC
						}									
					}											
				}
			}
		}
		
		
		if "`source'"=="worldbank" {
			
			noisily display in yellow _newline "WB_ADM0: Fetching" _continue
			
			foreach j in shp prj shx dbf {
				capture copy "https://github.com/asjadnaqvi/stata-geoboundary/raw/refs/heads/main/meta/WB_countries_Admin0_10m.`j'" "WB_ADM0.`j'", `rep'
			}
			

			if "`convert'" != "" {

				if "`name'"!="" {
					spshape2dta WB_ADM0, replace saving(`name'_ADM0)
					noisily display in yellow _continue " > {bf:`name'_ADM0.dta}, {bf:`name'_ADM0_shp.dta} saved"

					if "`geoframe'" != "" {
						geoframe create `name'_ADM0, `replace'
						noisily display in yellow _continue " > geoframe {bf:`name'_ADM0} created"
					}
				}
				else {
					spshape2dta WB_ADM0, replace
					noisily display in yellow _continue " > {bf:WB_ADM0.dta}, {bf:WB_ADM0_shp.dta} saved"

					if "`geoframe'" != "" {
						geoframe create WB_ADM0, `replace'
						noisily display in yellow _continue " > geoframe {bf:WB_ADM0} created"
					}
				}
			}
			
			// delete raw files (if specified)
			if "`remove'" != "" {
				noisily display in yellow _continue  " > Deleting raw shapefiles" 

				foreach j in shp prj shx dbf cpg {
					capture erase 	"WB_countries_Admin0_10m.`j'"  // windows
					capture rm 		"WB_countries_Admin0_10m.`j'"  // MAC
				}									
			}	
			
		}
		
	}
	
end

program define _geometa, rclass
 version 11

 	syntax [, country(string) iso(string) length(real 30) level(string) any(string) strict NOSEParator region(string) ] 
	
	preserve
	quietly {
	
		use "https://github.com/asjadnaqvi/stata-geoboundary/raw/refs/heads/main/meta/geoboundary_meta.dta", clear
		*use geoboundary_meta, clear  // add GitHub link

		foreach x of varlist _all { 
			char `x'[varname] `"`: var label `x''"' 
		}

		gen _markme = .	
		
		foreach x of local iso {
			if "`strict'" != "" {
				replace _markme = 1 if ustrregexm(iso3, "\b(`x')\b", 1)==1
			}
			else {
				replace _markme = 1 if ustrregexm(iso3, "`x'", 1)==1	
			}
		}
		
		foreach x of local country {
			if "`strict'" != "" {
				replace _markme = 1 if ustrregexm(name, "\b(`x')\b", 1)==1
			}
			else {
				replace _markme = 1 if ustrregexm(name, "`x'", 1)==1	
			}
		}
		
		foreach x of local region {
			if "`strict'" != "" {
				replace _markme = 1 if ustrregexm(wb_regioncode, "\b(`x')\b", 1)==1
			}
			else {
				replace _markme = 1 if ustrregexm(wb_regioncode, "`x'", 1)==1	
			}
		}	

		foreach x of local level {
			if "`strict'" != "" {
				replace _markme = 1 if ustrregexm(adm_geoboundary, "\b(`x')\b", 1)==1
				replace _markme = 1 if ustrregexm(adm_gadm       , "\b(`x')\b", 1)==1
			}
			else {
				replace _markme = 1 if ustrregexm(adm_geoboundary, "`x'", 1)==1	
				replace _markme = 1 if ustrregexm(adm_gadm       , "`x'", 1)==1	
			}		

		}	
		
		foreach x of local any {
			foreach y of varlist _all {
				if "`strict'" != "" {
					capture replace _markme = 1 if ustrregexm(`y', "\b(`x')\b", 1)==1
				}
				else {
					capture replace _markme = 1 if ustrregexm(`y', "`x'", 1)==1	
				}
			}
		}
		
		
		
		if "`noseparator'" == "" {
			local mysep sepby(iso3) 
		}
		else {
			local mysep separator(0)
		}
		

		sort name iso3 adm
		noisily list name iso3 adm* geob_year continent un_region wb_region wb_regioncode if _markme==1, string(`length') header table noobs subvarname `mysep'

		quietly levelsof iso3 if _markme==1 & !missing(adm_gadm), clean local(iso3_gadm)
		quietly levelsof iso3 if _markme==1 & !missing(adm_geob), clean local(iso3_geob)
		
		return local iso3_gadm = "`iso3_gadm'"
		return local iso3_geob = "`iso3_geob'"
		

	
	}
	restore	
		
	
	
end	

************************
***** END OF FILE ******
************************
