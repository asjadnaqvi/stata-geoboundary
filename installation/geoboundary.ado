*! geoboundary v1.0 (23 Nov 2024)
*! Asjad Naqvi (asjadnaqvi@gmail.com)

* v1.0 (23 Nov 2024): First release


/*
Data source: 
https://www.geoboundaries.org/
https://github.com/wmgeolab/geoBoundaries/
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

program define geoboundary 
version 15
	
syntax anything, level(string) [convert replace remove name(string) ]
	

	if "`anything'" == "WLD" | "`anything'" == "WORLD" {
		local baseurl https://github.com/wmgeolab/geoBoundaries/raw/refs/heads/main/releaseData/CGAZ
		local skip 1
	}
	else {
		local baseurl https://github.com/wmgeolab/geoBoundaries/raw/refs/heads/main/releaseData/gbOpen/
		local skip 0
	}
	
	if "`replace'"!= "" local rep replace
	
	
	local length1 : word count `level'
	local length2 : word count `anything'
	
	///////////////
	//  checks   //
	///////////////

	
	forval i = 1/`length2' {
		local lvl : word `i' of `anything'

		if length("`lvl'") != 3 {
			display as error "`lvl' is an invalid ISO3 code."
			exit
		}
	}
	
	
	local errcount = 0

	forval i = 1/`length1' {
		local lvl : word `i' of `level'

		if !inlist("`lvl'", "ADM0", "ADM1", "ADM2", "ADM3", "ADM4", "ADM5", "ALL") {
			display as error "Option {ul:`lvl'} is not valid. Valid options are {ul:ADM0}, {ul:ADM1}, {ul:ADM2}, {ul:ADM3}, {ul:ADM4}, {ul:ADM5}, {ul:ALL}."
			local ++errcount
		}
		
		if `errcount' > 0 exit
	}
	
	if "`level'" == "ALL" {
		local level ADM0 ADM1 ADM2 ADM3 ADM4 ADM5
		local length1 : word count `level'
	}
	

	
	/////////////////
	//  main loop  //
	/////////////////
	
	quietly {
	
		foreach x of local anything {
		
			forval i = 1/`length1' {
				local lvl : word `i' of `level'
				
				// fetch
				noisily display in yellow _newline "`x'-`lvl': Fetching" _continue
				
				
				local _check = 0
				
				if `skip'==0 {
					foreach j in shp prj shx dbf {
						capture copy "`baseurl'/`x'/`lvl'/geoBoundaries-`x'-`lvl'.`j'" "`x'_`lvl'.`j'", `rep'

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
					noisily display in red _continue " > Does not exist. Skipping"
				}
				else {
				
					// convert (if specified)
					if "`convert'" != "" {
						
						noisily display in yellow _continue " > Converting"
						
						if `skip'==0 {
							if "`name'"!="" {
								spshape2dta `x'_`lvl', replace saving(`name')
							}
							else {
								spshape2dta `x'_`lvl', replace
							}
						}
						else {
							if "`name'"!="" {					
								spshape2dta geoBoundariesCGAZ_`lvl', replace saving(`name')
							}
							else {
								spshape2dta geoBoundariesCGAZ_`lvl', replace saving(WLD_`lvl')
							}
						}
					}
					
					// delete raw files (if specified)
					if "`remove'" != "" {
						noisily display in yellow _continue  " > Deleting raw" 
						
						if `skip'==0 {
							foreach j in shp prj shx dbf {
								capture erase 	"`x'_`lvl'.`j'" // windows
								capture rm 		"`x'_`lvl'.`j'"	// MAC
							}
						}
						else {
							foreach j in shp prj shx dbf {
								capture erase 	"geoBoundariesCGAZ_`lvl'.`j'"  // windows
								capture rm 		"geoBoundariesCGAZ_`lvl'.`j'"  // MAC
							
							
							}							
						}
					}
				}
			}
		}
	}
	

end


************************
***** END OF FILE ******
************************
