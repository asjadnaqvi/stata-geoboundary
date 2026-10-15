*! geoboundary v1.3 (15 Oct 2026)
*! Asjad Naqvi (asjadnaqvi@gmail.com)

* v1.3  (15 Oct 2026): Eurostat GISCO NUTS layers in WGS84, with vintage and scale selection. Requires Stata 17.
* v1.23 (01 Sep 2026): Refreshed World Bank release 5 shapefiles (Jul 2026 update).
* v1.22 (02 Nov 2025): Update to World Bank release 5 which now has ADM0-ADM2 boundaries.
* v1.21 (29 Oct 2025): meta now displays all the data is options are missing.
* v1.2  (09 Jan 2025): Direct convertion to geoframe. WorldBank official layer added. Several fixes.
* v1.1  (08 Dec 2024): Added geoboundaries meta data. Added GDAM as an additional source. Added source(). Lower cases are now allowed. Added meta data.
* v1.0  (23 Nov 2024): First release


/*
Data source: 
GeoBoundaries: https://www.geoboundaries.org/, https://github.com/wmgeolab/geoBoundaries/
GADM: 
World Bank: https://datacatalog.worldbank.org/search/dataset/0038272/World-Bank-Official-Administrative-Boundaries
Eurostat GISCO: https://gisco-services.ec.europa.eu/distribution/v2/nuts/
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
cap prog drop _geogisco
cap prog drop _geogisco_run
cap prog drop _geogisco_download
cap prog drop _geob_retry
cap prog drop _geometa

program define geoboundary, rclass 
version 17
	
syntax anything, [level(string) convert replace remove name(string) source(string) country(string) iso(string) NOSEParator region(string) length(string) any(string) strict geoframe vintage(string) scale(string)]

	local source = lower(trim("`source'"))
	if "`source'" != "" & !inlist("`source'", "geoboundaries", "geob", "gadm", "worldbank", "eurostat") {
		di as error "Valid source() options are geoboundaries, geob, gadm, worldbank, or eurostat."
		exit 198
	}
	if "`source'" == "eurostat" {
		if "`anything'" == "meta" {
			if "`level'`vintage'`scale'`country'`iso'`region'`any'`length'`strict'`noseparator'`convert'`geoframe'`remove'`replace'`name'" != "" {
				di as error "Eurostat metadata uses: geoboundary meta, source(eurostat)"
				exit 198
			}
			di as text "Eurostat GISCO NUTS region polygons; coverage: EUR (all supplied countries)"
			di as text "Vintages: 2003 2006 2010 2013 2016 2021 2024 (default: 2024)"
			di as text "Levels: NUTS0 NUTS1 NUTS2 NUTS3 ALL"
			di as text "Scales: 01m 03m 10m 20m 60m (default: 20m); CRS: EPSG:4326"
			di as text "NUTS 2003 has no 60m layer. Other listed vintage/scale combinations are supported."
			return local source "eurostat"
			return local vintages "2003 2006 2010 2013 2016 2021 2024"
			return local levels "NUTS0 NUTS1 NUTS2 NUTS3"
			return local scales "01m 03m 10m 20m 60m"
			return local crs "EPSG:4326"
			exit
		}
		if "`country'`iso'`region'`any'`length'`strict'`noseparator'" != "" {
			di as error "Country metadata search options do not apply to Eurostat boundary downloads."
			exit 198
		}
		_geogisco `anything', level(`"`level'"') vintage(`"`vintage'"') scale(`"`scale'"') ///
			name(`"`name'"') `convert' `geoframe' `replace' `remove'
		return add
		exit
	}
	if "`vintage'`scale'" != "" {
		di as error "vintage() and scale() require source(eurostat)."
		exit 198
	}
	
	
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
		exit
	}
	else {
		local baseurl https://github.com/wmgeolab/geoBoundaries/raw/refs/heads/main/releaseData/gbOpen/
		local skip 0
	}
	
	
	
	if "`replace'"!= "" local rep replace
	
	local length1 : word count `level'
	local length2 : word count `anything'
	
	if "`anything'" != "meta" {
		if "`source'" == "" {
			local source geoboundaries
			di in green _newline "Option {bf:source()} not specified. Assuming {bf:geoboundaries} as the default."
		}
	}
	
	
	
	///////////////
	//  checks   //
	///////////////

	
	if "`source'" == "gadm" local level ALL
	local level = upper(trim("`level'"))
	local length1 : word count `level'
	if "`level'" == "" {
		di as error "Specify level(), for example level(ADM0)."
		exit 198
	}
	if "`source'" == "worldbank" & `skip' != 1 {
		di as error "source(worldbank) requires WLD."
		exit 198
	}
	
	if "`anything'" != "meta" {
		forval i = 1/`length2' {
			local lvl : word `i' of `anything'
			
			if length("`lvl'") != 3 {
				display as error "`lvl' is an invalid ISO3 code."
				exit 198
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
		
		if `errcount' > 0 exit 198
	}
	
	if "`level'" == "ALL" | "`level'" == "all" {
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
							capture _geob_retry copy "`baseurl'/`x1'/`lvl'/geoBoundaries-`x1'-`lvl'.`j'" "`x1'_`lvl'.`j'", `rep'

							if _rc!= 0 {
								local ++_check
							}	
						}
					}
					else {
						_geob_retry copy "`baseurl'/geoBoundariesCGAZ_`lvl'.zip" "WLD_`lvl'.zip", `replace'
						_geob_retry unzipfile WLD_`lvl', `rep'
						
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
									_geob_retry spshape2dta `x1'_`lvl', replace saving(`name'_`lvl')
									noisily display in yellow _continue " > {bf:`name'_`lvl'.dta}, {bf:`name'_`lvl'_shp.dta} saved"
									
									if "`geoframe'" != "" {
										geoframe create `name'_`lvl', `replace'
										noisily display in yellow _continue " > geoframe {bf:`name'_`lvl'} created"
									}
								}
								else {
									_geob_retry spshape2dta `x1'_`lvl', replace
									noisily display in yellow _continue " > {bf:`x1'_`lvl'.dta}, {bf:`x1'_`lvl'_shp.dta} saved"
									
									if "`geoframe'" != "" {
										geoframe create `x1'_`lvl', `replace'
										noisily display in yellow _continue " > geoframe {bf:`x1'_`lvl'} created"
									}
								}
							}
							else {
								if "`name'"!="" {					
									_geob_retry spshape2dta geoBoundariesCGAZ_`lvl', replace saving(`name'_`lvl')
									noisily display in yellow _continue " > {bf:`name'_`lvl'.dta}, {bf:`name'_`lvl'_shp.dta} saved"
									
									if "`geoframe'" != "" {
										geoframe create `name'_`lvl', `replace'
										noisily display in yellow _continue " > geoframe {bf:`name'_`lvl'} created"
									}
									
								}
								else {
									_geob_retry spshape2dta geoBoundariesCGAZ_`lvl', replace saving(WLD_`lvl')
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
				
				*noisily display in yellow _continue  " > Done." 
				
			}
		}
		
		
		if "`source'" == "gadm" & "`anything'"!="meta" {
			
			foreach x of local anything {
			local x1 = upper("`x'")
				
				noisily display in yellow _newline "`x1'-`lvl': Fetching" _continue
				
				_geob_retry copy "https://geodata.ucdavis.edu/gadm/gadm4.1/shp/gadm41_`x1'_shp.zip" "`x1'.zip", `rep'

				_geob_retry unzipfile `x1', replace // ifilter(`"(.*\.(dbf)$)"')

				local x2  = lower("`x1'")
				local files : dir "." files "gadm41_`x1'_*.dbf"
				
				
				foreach y of local files {
					
					local layer = ustrregexra("`y'", ".dbf", "")
					
					
					local xtemp = ustrregexra("`layer'", "gadm41_`x2'_", "")
					local xtemp = "ADM" + "`xtemp'"
					
					if "`convert'"!= "" {	
						
						noisily display in yellow _newline "`x1'-`xtemp' > Converting to Stata format" _continue
						
						
						if "`name'"!="" {
							_geob_retry spshape2dta `layer', replace saving(`name'_`xtemp')
						}
						else {
							_geob_retry spshape2dta `layer', replace saving(`x1'_`xtemp')
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
		
		
		// WORLD BANK // Updated to release 5
		
		if "`source'"=="worldbank" & "`anything'"!="meta"  {

				forval i = 1/`length1' {
					local lvl : word `i' of `level'
					local lvl = upper("`lvl'")
					
					// fetch
					noisily display in yellow _newline "World Bank `lvl' (Jul 14, 2026): Fetching" _continue
					
					local _check = 0
					
					if `skip' == 1 {
						foreach j in shp prj shx dbf cpg {
							*capture copy "`baseurl'/`x1'/`lvl'/geoBoundaries-`x1'-`lvl'.`j'" "`x1'_`lvl'.`j'", `rep'
							
							capture _geob_retry copy "https://huggingface.co/datasets/asjadnaqvi/shapefiles/resolve/main/WB_GAD_`lvl'.`j'" "WB_`lvl'.`j'", `rep'
							
							if _rc!= 0 {
								local ++_check
							}	
						}
					}

					

					if `_check' != 0 {
						noisily display in red _continue " > Does not exist."
					}
					else {
					
						// convert (if specified)
						if "`convert'" != "" {
														
							if `skip' == 1 {
								if "`name'"!="" {
									_geob_retry spshape2dta WB_`lvl', replace saving(`name'_`lvl')
									noisily display in yellow _continue " > {bf:`name'_`lvl'.dta}, {bf:`name'_`lvl'_shp.dta} saved"
									
									if "`geoframe'" != "" {
										geoframe create `name'_`lvl', `replace'
										noisily display in yellow _continue " > geoframe {bf:`name'_`lvl'} created"
									}
								}
								else {
									_geob_retry spshape2dta WB_`lvl', replace
									noisily display in yellow _continue " > {bf:WB_`lvl'.dta}, {bf:WB_`lvl'_shp.dta} saved"
									
									if "`geoframe'" != "" {
										geoframe create WB_`lvl', `replace'
										noisily display in yellow _continue " > geoframe {bf:WB_`lvl'} created"
									}
								}
							}
			
						}
						
						// delete raw files (if specified)
						if "`remove'" != "" {
							noisily display in yellow _continue  " > shapefiles deleted" 
							
							if `skip' == 1 {
								foreach j in shp prj shx dbf {
									capture erase 	"WB_`lvl'.`j'" 	// Windows
									capture rm 		"WB_`lvl'.`j'"	// MAC
								}
							}
						}
					}
				}
					
		}		
	}
	
end

program define _geogisco, rclass
	version 17
	syntax anything, [level(string) vintage(string) scale(string) name(string) convert geoframe replace remove]

	if upper(trim("`anything'")) != "EUR" {
		di as error "source(eurostat) requires EUR for the full GISCO coverage."
		exit 198
	}
	if "`vintage'" == "" local vintage 2024
	if !inlist("`vintage'", "2003", "2006", "2010", "2013", "2016", "2021", "2024") {
		di as error "Supported NUTS vintages are 2003, 2006, 2010, 2013, 2016, 2021, and 2024."
		exit 198
	}
	if "`scale'" == "" local scale 20m
	local scale = upper(trim("`scale'"))
	if !inlist("`scale'", "01M", "03M", "10M", "20M", "60M") {
		di as error "Valid scale() options are 01m, 03m, 10m, 20m, and 60m."
		exit 198
	}
	if "`vintage'" == "2003" & "`scale'" == "60M" {
		di as error "NUTS 2003 is not available at scale(60m); use 01m, 03m, 10m, or 20m."
		exit 198
	}
	local level = upper(trim("`level'"))
	if "`level'" == "ALL" local level NUTS0 NUTS1 NUTS2 NUTS3
	if "`level'" == "" {
		di as error "Specify level(NUTS0), level(NUTS1), level(NUTS2), level(NUTS3), or level(ALL)."
		exit 198
	}
	local level : list uniq level
	foreach lvl of local level {
		if !inlist("`lvl'", "NUTS0", "NUTS1", "NUTS2", "NUTS3") {
			di as error "Invalid NUTS level: `lvl'. Use NUTS0 through NUTS3, or ALL alone."
			exit 198
		}
	}
	if "`convert'" == "" & "`geoframe'`remove'" != "" {
		di as error "For Eurostat downloads, geoframe and remove require convert."
		exit 198
	}
	if "`name'" != "" {
		confirm name `name'
	}
	if "`geoframe'" != "" {
		capture which geoframe
		if _rc {
			di as error "geoframe is not installed. Install geoplot before using the geoframe option."
			exit 199
		}
	}
	foreach lvl of local level {
		local prefix ESTAT
		if "`name'" != "" local prefix `name'
		local out `prefix'_`lvl'_`vintage'_`scale'_4326
		if "`geoframe'" != "" {
			confirm name `out'
			confirm name `out'_shp
		}
		if "`replace'" == "" {
			foreach ext in shp shx dbf prj cpg {
				confirm new file "`out'.`ext'"
			}
			if "`convert'" != "" {
				confirm new file "`out'.dta"
				confirm new file "`out'_shp.dta"
			}
			if "`geoframe'" != "" {
				foreach f in `out' `out'_shp {
					capture frame `f': describe
					if !_rc {
						di as error "Frame `f' already exists; specify replace."
						exit 110
					}
				}
			}
		}
	}

	local cwd `"`c(pwd)'"'
	local sep = cond("`c(os)'" == "Windows", char(92), "/")
	tempfile token
	local stage `"`token'_gisco"'
	mkdir `"`stage'"'
	preserve
	capture noisily _geogisco_run, level(`level') vintage(`vintage') scale(`scale') ///
		stage(`"`stage'"') cwd(`"`cwd'"') name(`"`name'"') `convert' `geoframe' `replace' `remove'
	local rc = _rc
	local files `"`r(files)'"'
	local urls `"`r(urls)'"'
	restore
	quietly cd `"`cwd'"'
	foreach lvl of local level {
		local n = substr("`lvl'", 5, 1)
		local remote NUTS_RG_`scale'_`vintage'_4326_LEVL_`n'
		foreach ext in shp.zip shp shx dbf prj cpg {
			local file `"`stage'`sep'`remote'.`ext'"'
			capture confirm file `"`file'"'
			if !_rc {
				capture erase `"`file'"'
				local cleanup_rc = _rc
				if `cleanup_rc' {
					di as error `"Could not remove temporary file: `file'"'
					if !`rc' local rc = `cleanup_rc'
				}
			}
		}
	}
	capture rmdir `"`stage'"'
	local cleanup_rc = _rc
	if `cleanup_rc' {
		di as error `"Could not remove temporary directory: `stage'"'
		if !`rc' local rc = `cleanup_rc'
	}
	if `rc' {
		di as error "Eurostat request failed; completed outputs and published raw files have been retained."
		exit `rc'
	}
	return local source "eurostat"
	return local vintage "`vintage'"
	return local scale "`scale'"
	return local levels "`level'"
	return local crs "EPSG:4326"
	return local retrieved "`c(current_date)'"
	return local files `"`files'"'
	return local urls `"`urls'"'
end

program define _geogisco_run, rclass
	version 17
	syntax, level(string) vintage(string) scale(string) stage(string) cwd(string) ///
		[name(string) convert geoframe replace remove]

	local sep = cond("`c(os)'" == "Windows", char(92), "/")
	local root https://gisco-services.ec.europa.eu/distribution/v2/nuts/shp
	foreach lvl of local level {
		local n = substr("`lvl'", 5, 1)
		local remote NUTS_RG_`scale'_`vintage'_4326_LEVL_`n'
		local url "`root'/`remote'.shp.zip"
		local prefix ESTAT
		if "`name'" != "" local prefix `name'
		local out `prefix'_`lvl'_`vintage'_`scale'_4326
		di as text _newline "Eurostat `lvl' (`vintage', `scale', EPSG:4326): Fetching"
		_geogisco_download "`url'" `"`stage'`sep'`remote'.shp.zip"'
		quietly cd `"`stage'"'
		unzipfile "`remote'.shp.zip"
		quietly cd `"`cwd'"'
		foreach ext in shp shx dbf prj {
			confirm file `"`stage'`sep'`remote'.`ext'"'
		}
		tempname prj
		file open `prj' using `"`stage'`sep'`remote'.prj"', read text
		file read `prj' projection
		file close `prj'
		if substr(upper(trim(`"`projection'"')), 1, 7) != "GEOGCS[" | ///
			(!strpos(upper(`"`projection'"'), "WGS_1984") & !strpos(upper(`"`projection'"'), "WGS 84")) {
			di as error "The downloaded projection is not the expected WGS84 geographic CRS."
			exit 459
		}
		foreach ext in shp shx dbf prj cpg {
			capture confirm file `"`stage'`sep'`remote'.`ext'"'
			if !_rc _geob_retry copy `"`stage'`sep'`remote'.`ext'"' "`out'.`ext'", `replace'
		}
		if "`convert'" != "" {
			_geob_retry spshape2dta "`out'", saving(`out') `replace'
			foreach dataset in `out' `out'_shp {
				quietly use "`dataset'.dta", clear
				char _dta[geoboundary_source] "Eurostat GISCO"
				char _dta[geoboundary_vintage] "`vintage'"
				char _dta[geoboundary_level] "`lvl'"
				char _dta[geoboundary_scale] "`scale'"
				char _dta[geoboundary_crs] "EPSG:4326"
				char _dta[geoboundary_url] "`url'"
				char _dta[geoboundary_retrieved] "`c(current_date)'"
				_geob_retry quietly save "`dataset'.dta", replace
			}
			if "`geoframe'" != "" {
				geoframe create `out', `replace'
			}
			local files "`files' `out'.dta `out'_shp.dta"
		}
		else local files "`files' `out'.shp"
		if "`remove'" != "" {
			foreach ext in shp shx dbf prj cpg {
				capture confirm file "`out'.`ext'"
				if !_rc {
					capture erase "`out'.`ext'"
					// cloud-sync clients (Dropbox, OneDrive) can briefly lock new files
					if _rc {
						sleep 2000
						capture erase "`out'.`ext'"
					}
					if _rc di as error "Warning: could not delete `out'.`ext' (file locked?); delete it manually."
				}
			}
		}
		local urls "`urls' `url'"
		di as result "`out': saved"
	}
	return local files = trim("`files'")
	return local urls = trim("`urls'")
end

program define _geogisco_download
	version 17
	args url destination
	capture noisily copy "`url'" `"`destination'"'
	local rc = _rc
	if `rc' {
		di as error "Could not download GISCO archive: `url'"
		di as error "Check the connection and catalogue availability for this vintage, scale, and level."
		exit `rc'
	}
end

// Cloud-sync clients (Dropbox, OneDrive) can briefly lock new files; retry on r(608).
program define _geob_retry
	version 17
	forvalues attempt = 1/4 {
		capture noisily `0'
		local rc = _rc
		if `rc' != 608 | `attempt' == 4 continue, break
		di as text "(file locked, retrying in 3 seconds)"
		sleep 3000
	}
	exit `rc'
end

program define _geometa, rclass
 version 17

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
				replace _markme = 1 if ustrregexm("ADM" + string(adm, "%1.0f"), "\b(`x')\b", 1)==1
			}
			else {
				replace _markme = 1 if ustrregexm("ADM" + string(adm, "%1.0f"), "`x'", 1)==1
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
		
		
		// display everything is specifics are missing.
		if "`iso'"=="" & "`country'"=="" & "`region'"=="" & "`level'"=="" & "`any'"=="" {
			replace _markme=1
		}
		
		
		if "`noseparator'" == "" {
			local mysep sepby(iso3) 
		}
		else {
			local mysep separator(0)
		}
		

		sort name iso3 adm
		noisily list name iso3 adm adm_geoboundary geob_year adm_gadm continent un_region wb_region wb_regioncode if _markme==1, string(`length') header table noobs subvarname `mysep'

		quietly levelsof iso3 if _markme==1 & !missing(adm_gadm), clean local(iso3_gadm)
		quietly levelsof iso3 if _markme==1 & !missing(adm_geoboundary), clean local(iso3_geob)
		
		return local iso3_gadm = "`iso3_gadm'"
		return local iso3_geob = "`iso3_geob'"
		

	
	}
	restore	
		
	
	
end	

************************
***** END OF FILE ******
************************
