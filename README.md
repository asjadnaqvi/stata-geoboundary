
![StataMin](https://img.shields.io/badge/stata-2021-blue) ![issues](https://img.shields.io/github/issues/asjadnaqvi/stata-geoboundary) ![license](https://img.shields.io/github/license/asjadnaqvi/stata-geoboundary) ![Stars](https://img.shields.io/github/stars/asjadnaqvi/stata-geoboundary) ![version](https://img.shields.io/github/v/release/asjadnaqvi/stata-geoboundary) ![release](https://img.shields.io/github/release-date/asjadnaqvi/stata-geoboundary)

[Installation](#Installation) | [Syntax](#Syntax) | [Examples](#Examples) | [Feedback](#Feedback) | [Disclaimer](#Disclaimer)  | [Change log](#Change-log)

---

![geoboundary_banner](https://github.com/user-attachments/assets/302797f0-ad99-40ca-81a3-bf3def8606c0)



# geoboundary v1.3
(15 Oct 2026)

A package for fetching country-level or global adminstrative boundaries from the following databases:
-    [geoBoundaries](https://www.geoboundaries.org/) 
-    [GADM](https://gadm.org/) v4.1
-    [World Bank](https://datacatalog.worldbank.org/search/dataset/0038272/World-Bank-Official-Boundaries) official ADM0-ADM2 layers (July 2026 release).
-    [Eurostat GISCO](https://gisco-services.ec.europa.eu/distribution/v2/nuts/) NUTS0-NUTS3 region polygons.

Please note that by using the data provided through this package, you are acknowledging the [disclaimer](#Disclaimer).

All files are in the standard EPSG: 4326 (WGS84) projection.

The package uses globally standardized administration boundary classifications. They allows different systems to be combined together. Under this classification, `ADM0` is always the country boundary, while `ADM1` can represent provinces, districts, or other classifications depending on the country. For some countries data is available up to the 5th administrative depth or `ADM5`.

**Note 1**: GIS files are large and quickly accumulate. Please try and download exacly what you need. Please also avoid repeated downloading of the same datasets.

**Note 2**: If you are bulk downloading multiple datasets in directories where disk writing is slower than the download speed, then you might get return or I/O errors even if the file is valid. This could potentially occur if downloading directly on to cloud storage (e.g. Dropbox, OneDrive, etc.), or using slower hard drives (e.g. 5400 rpm, non SATA etc.). In this case, either download the files somewhere else, or wait for the files to synchronize and try again.


## Installation

The package can be installed via SSC or GitHub. The GitHub version, *might* be more recent due to bug fixes, feature updates etc, and *may* contain syntax improvements and changes in *default* values. See version numbers below. Eventually the GitHub version is published on SSC.

The SSC version (**v1.2**):

```stata
ssc install geoboundary, replace
```

Or it can be installed from GitHub (**v1.3**):

```stata
net install geoboundary, from("https://raw.githubusercontent.com/asjadnaqvi/stata-geoboundary/main/installation/") replace
```


Additional code for the maps shown below:


```stata
ssc install schemepack, replace
set scheme white_tableau  

graph set window fontface "Arial Narrow"
```


## Citation guidelines
Software packages take countless hours of programming, testing, and bug fixing. If you use this package, then a citation would be highly appreciated:


Click here for the latest [SSC citation](https://ideas.repec.org/c/boc/bocode/s459399.html).



## Syntax


Syntax for meta data: 

```stata
geoboundary meta, [ country(list) iso(list) level(list) region(list) any(list) length(num) strict noseperator ]
```

Syntax for boundary data: 

```stata
geoboundary ISO3 codes, level(string) [ source(str) convert geoframe name(str) replace remove ]
geoboundary EUR, source(eurostat) level(string) [ vintage(str) scale(str) convert geoframe name(str) replace remove ]
```

See `help geoboundary` for details.


## Examples

Before starting, make sure you are in the correct directory where the maps files will be downloaded:

```
cd <mypath>
```


### Meta data

The meta data syntax loads the **geoboundary_meta.dta** file from the [GIS](/gis) folder and parses it depending on the query. If you would like the full overview, download the file directly from GitHub.

The if nothing is specified, then `geoboundary meta` will list all the countries in the database. This might be useful to get the ISO3 codes or check which countries are available.


Let's find a country with ISO3 code DOM:

``` stata
geoboundary meta, iso(dom) length(20)				// search just iso3 codes
geoboundary meta, any(dom) length(20)				// search any of the data columns
geoboundary meta, any(dom) length(20) strict        // make the searches strict to exactly find the keyword DOM
```

The first expression return Dominican Republic, the correct iso3 country. The second expression does a fuzzy search and also returns Dominica (DMA), Dominican Republic (DOM), and United Kingdom (GBR). This is because `any()` searches all the columns and finds any possible match. We can also retrict it by specifying `strict` so that we ONLY find *DOM* in our searches.

Another example is searching for the generic term *island*:


```
geoboundary meta, any(island) length(15) nosep
geoboundary meta, any(island) length(15) strict nosep
```

The first expression returns any country with both `island` and `islands`, while the second one returns only countries that just have the name `island`. 


Another example:

```
geoboundary meta, region(NA) length(15) 
geoboundary meta, region(NA) length(15) strict
```

where the first expression with return World Bank region North America (NA) and Middle East and North Africa (MENA). So uses these searches carefully.

Let's say we want to download a set of countries, e.g. in the ECA region, we can specify:

```
geoboundary meta, region(ECA) length(15) strict
return list
```

where `return list` will show us two locals `r(geob)` and `r(gadm)` or the list of countries that can be downloaded from either databases. These lists can be passed onto the command below.



### Boundary data

Download the raw shapefiles in ESRI format:

```stata
geoboundary AUT DEU, level(ADM0 ADM1) replace
```

Convert them to Stata format:

```stata
geoboundary AUT DEU, level(ADM0 ADM1) replace convert
```


if you do not want to keep the raw shapefiles, that can be very large for very small finer administrative units, then the `remove` option is highlighy recommended.


```stata
geoboundary MEX, level(ADM0 ADM1 ADM2) replace convert remove
```

Global composite boundary can be downloaded as follows:

```stata
geoboundary WLD, level(ADM0 ADM1) replace convert remove
```


### Eurostat GISCO NUTS layers

List the supported download settings:

```stata
geoboundary meta, source(eurostat)
```

Download NUTS2 polygons in EPSG:4326 (WGS84), convert to Stata, and remove the raw shapefiles:

```stata
geoboundary EUR, source(eurostat) level(NUTS2) vintage(2024) scale(20m) convert remove
```

`EUR` means all countries supplied in the GISCO layer, not EU membership filtering. Country-specific downloads are not currently supported.
Levels are `NUTS0`, `NUTS1`, `NUTS2`, and `NUTS3`; `ALL` downloads all four. NUTS levels are statistical units and must not be treated as equivalent to ADM levels.

Supported vintages are 2003, 2006, 2010, 2013, 2016, 2021, and 2024; the default is 2024.
Scales are `01m`, `03m`, `10m`, `20m` (default), and `60m`, denoting 1:1, 1:3, 1:10, 1:20, and 1:60 million.
NUTS 2003 is not available at `60m`. Finer scales produce larger files.
Only region polygons (`RG`) are downloaded, directly in WGS84; no reprojection tools are required.

Default converted filenames are `ESTAT_NUTS2_2024_20M_4326.dta` and `ESTAT_NUTS2_2024_20M_4326_shp.dta`.
`name(myregions)` to keep the level, vintage, scale, and CRS suffixes.


```stata
geoboundary EUR, source(eurostat) level(ALL) vintage(2021) scale(60m) ///
    convert geoframe remove

geoplot (area ESTAT_NUTS2_2021_60M_4326, color(white) lc(gs8)), tight
```

Original attributes such as `NUTS_ID`, `CNTR_CODE`, and `LEVL_CODE` are preserved. Merge regional statistics on `NUTS_ID` only after verifying that both datasets use the same NUTS vintage.
The observation year does not necessarily identify the classification vintage. Different vintages may involve code changes, splits, mergers, or boundary transfers.
The package does not harmonise statistics between vintages; use official recalculated statistics or a documented crosswalk.

The converted datasets carry `geoboundary_*` characteristics recording source, vintage, level, scale, CRS, URL, and retrieval date.
`return list` reports `r(source)`, `r(vintage)`, `r(scale)`, `r(levels)`, `r(crs)`, `r(retrieved)`, `r(files)`, and `r(urls)`.
GISCO may correct files within a vintage, so retaining a local copy for reproducibility is recommended. Consult the [GISCO catalogue and download provisions](https://gisco-services.ec.europa.eu/distribution/v2/) and acknowledge Eurostat/GISCO when using these data. The package's MIT licence does not replace the source's data usage conditions.

#### Eurostat maps

Download all four NUTS 2024 levels plus NUTS2 2021, load them as geoframes, and clip to mainland Europe (dropping overseas territories):

```stata
geoboundary EUR, source(eurostat) level(ALL) vintage(2024) scale(20m) convert replace remove
geoboundary EUR, source(eurostat) level(NUTS2) vintage(2021) scale(20m) convert replace remove

foreach f in NUTS0_2024 NUTS1_2024 NUTS2_2024 NUTS3_2024 NUTS2_2021 {
	geoframe create `f' using ESTAT_`f'_20M_4326.dta, replace
	frame `f': geoframe rclip -25 45 34 72
}
```

The NUTS hierarchy:

```stata
geoplot ///
	(area NUTS3_2024, color(white) lc(gs10) lw(0.02) label("NUTS3"))	///
	(line NUTS2_2024, lc(red) lw(0.06) label("NUTS2"))					///
	(line NUTS1_2024, lc(blue) lw(0.1) label("NUTS1"))					///
	(line NUTS0_2024, lc(black) lw(0.15) label("NUTS0"))				///
	, tight project(albers 43 62 1 10 52) background(water) glegend(layout(4 3 2 1) position(nw)) ///
	title("NUTS 2024 hierarchy: NUTS0 to NUTS3")
```

<img src="/GIS/eurostat_nuts_levels.png" width="100%">

The GISCO layers ship with attributes such as the NUTS3 urban-rural typology (`URBN_TYPE`):

```stata
frame NUTS3_2024 {
	destring URBN_TYPE, replace force
	label define urbn 1 "Predominantly urban" 2 "Intermediate" 3 "Predominantly rural", replace
	label values URBN_TYPE urbn
}

geoplot ///
	(area NUTS3_2024 i.URBN_TYPE, color(tableau) lc(white) lw(0.02))	///
	(line NUTS0_2024, lc(black) lw(0.12))								///
	, tight `proj' background(water) legend(pos(10)) ///
	title("NUTS3 urban-rural typology (NUTS 2024)")
```

<img src="/GIS/eurostat_nuts3_urban.png" width="100%">

Vintages are distinct geographies. Linking on `NUTS_ID` shows which NUTS2 codes exist in only one vintage:

```stata
frame NUTS2_2024 {
	frlink 1:1 NUTS_ID, frame(NUTS2_2021) generate(_l2021)
	gen byte new2024 = missing(_l2021)
}
frame NUTS2_2021 {
	frlink 1:1 NUTS_ID, frame(NUTS2_2024) generate(_l2024)
	gen byte only2021 = missing(_l2024)
}

geoplot ///
	(area NUTS2_2024, color(gs14) lc(white) lw(0.03) label("Unchanged code"))						///
	(area NUTS2_2021 if only2021==1, color(red%60) lc(white) lw(0.03) label("NUTS 2021 only"))		///
	(area NUTS2_2024 if new2024==1, color(blue%70) lc(white) lw(0.03) label("New in NUTS 2024"))	///
	(line NUTS0_2024, lc(black) lw(0.1))															///
	, tight `proj' background(water) glegend(layout(1 2 3) position(nw)) ///
	title("NUTS2 code changes: 2021 vs 2024 vintages")
```

<img src="/GIS/eurostat_nuts2_vintages.png" width="100%">

Unchanged codes do not guarantee unchanged boundaries; check the official NUTS amendment tables before comparing across vintages.


### Plot the map

Once the files are downloaded we can see if they are working.

We can use the `spmap` command:


```stata
use WLD_ADM0, clear

spmap using WLD_ADM0_shp, id(_ID)
```

<img src="/GIS/world_spmap.png" width="100%">

Or the `geoplot` command:


```stata
geoframe create WLD_ADM0

geoplot (line WLD_ADM0, lc(black)), tight
```

<img src="/GIS/world_geoplot.png" width="100%">

### A nicer example

If you have already downloaded global ADM0 and ADM1 boundaries, we can make a nicer map using the following code:

```stata
geoframe create WLD_ADM0
geoframe create WLD_ADM1


geoplot ///
	(area WLD_ADM1, color(white) lc(red) lw(0.02))	///
	(line WLD_ADM0, lc(gs3) lw(0.03))	///
	, tight project(robinson) background(water) grid(lc(white) label)	///
	title("Global ADM0 and ADM1 boundaries") ///
	note("Source: https://www.geoboundaries.org/. Accessed using the #Stata #geoboundary package.", size(1.8))
```

<img src="/GIS/world_geoplot2.png" width="100%">


## Downloading, coverting, merging, and plotting

Here is another example, where we download the DACH countries - Austria, Switzerland, and Germany, for three admin levels, and merge them together using the `geoplot` package (Stata v17+ only):

```stata
geoboundary DEU AUT CHE, level(ADM0 ADM1 ADM2) replace convert remove

geoframe create AUT_ADM0, replace
geoframe create AUT_ADM1, replace
geoframe create AUT_ADM2, replace

geoframe create CHE_ADM0, replace
geoframe create CHE_ADM1, replace
geoframe create CHE_ADM2, replace

geoframe create DEU_ADM0, replace
geoframe create DEU_ADM1, replace
geoframe create DEU_ADM2, replace


geoframe stack AUT_ADM0 CHE_ADM0 DEU_ADM0, into(dach0) replace
geoframe stack AUT_ADM1 CHE_ADM1 DEU_ADM1, into(dach1) replace
geoframe stack AUT_ADM2 CHE_ADM2 DEU_ADM2, into(dach2) replace
```

and plot

```stata
geoplot ///
	(area dach2 i._FRAME, lw(0.01) lc(white))	///
	(line dach1 i._FRAME, lw(0.04) lc(white))	///
	(line dach0 i._FRAME, lw(0.05) lc(black))	///
	, tight project(peters) grid

```

<img src="/GIS/world_geoplot3.png" width="100%">


### v1.1 examples:

Let's download Mexico's boundaries from both geoBoundaries and GADM:

```stata
geoboundary mex, level(all) replace convert remove name(geob_mex)
geoboundary mex, level(all) replace convert remove name(gadm_mex) source(gadm) 
```

and convert them to `geoframes`

```stata
geoframe create geob_mex_ADM0, replace
geoframe create geob_mex_ADM1, replace
geoframe create geob_mex_ADM2, replace

geoframe create gadm_mex_ADM0, replace
geoframe create gadm_mex_ADM1, replace
geoframe create gadm_mex_ADM2, replace
```

and let's plot the two:

```stata
geoplot ///
	(area geob_mex_ADM2, color(white) lc(red) lw(0.02))	///
	(line geob_mex_ADM1, lc(blue) lw(0.04))	///
	(line geob_mex_ADM0, lc(black) lw(0.1))	///
	, tight title("Mexico from geoBoundaries")
	
geoplot ///
	(area gadm_mex_ADM2, color(white) lc(red) lw(0.02))	///
	(line gadm_mex_ADM1, lc(blue) lw(0.04))	///
	(line gadm_mex_ADM0, lc(black) lw(0.1))	///
	, tight  title("Mexico from GDAM")
```

<img src="/GIS/geoboundary_mex1.png" width="100%">

<img src="/GIS/geoboundary_mex2.png" width="100%">

The maps look fairly similar but this does not mean that both the datasets give us the exact boundaries. Let's try another example by using the Gambia:


```stata
geoboundary meta, any(GAM) length(15)	 // get the iso3 code


geoboundary GMB, level(all) replace convert remove name(gadm_gmb) source(gadm) 
geoboundary GMB, level(all) replace convert remove name(geob_gmb)	
	
	
geoframe create geob_gmb_ADM0, replace
geoframe create geob_gmb_ADM1, replace
geoframe create geob_gmb_ADM2, replace

geoframe create gadm_gmb_ADM0, replace
geoframe create gadm_gmb_ADM1, replace
geoframe create gadm_gmb_ADM2, replace
```

and plot:

```
geoplot ///
	(area geob_gmb_ADM2, color(white) lc(red) lw(0.05))	///
	(line geob_gmb_ADM1, lc(blue) lw(0.1))	///
	(line geob_gmb_ADM0, lc(black) lw(0.2))	///
	, tight title("The Gambia from geoBoundaries")
	
	
geoplot ///
	(area gadm_gmb_ADM2, color(white) lc(red) lw(0.05))	///
	(line gadm_gmb_ADM1, lc(blue) lw(0.1))	///
	(line gadm_gmb_ADM0, lc(black) lw(0.2))	///
	, tight  title("The Gambia from GDAM")	
```

<img src="/GIS/geoboundary_gmb1.png" width="100%">

<img src="/GIS/geoboundary_gmb2.png" width="100%">

Both the maps look different. We can actually compare these by plotting the geoframes together:

```stata
geoplot ///
	(line geob_gmb_ADM2, lc(red) lw(0.2) label("geoBoundaries"))	///
	(line gadm_gmb_ADM2, lc(blue) lw(0.2) label("GADM"))	///
	, tight title("The Gambia: Geoboundary vs GDAM") ///
	glegend(layout(1 - 2) tsize(3.5))
```

<img src="/GIS/geoboundary_gmb3.png" width="100%">

where we see that the GADM data is more coarse than the geoboundaries data. There could also be differences in the number of regions or boundaries available from the two datasets.


### World Bank's map layer

Download the layer using this standard code:

```stata
geoboundary WLD, level(ADM0 ADM1 ADM2) replace convert remove source(worldbank) geoframe
```

If you have already downloaded the files, then just covert them directly in geoframe rather downloading them again using the above command:

```stata
geoframe create WB_ADM0, replace
geoframe create WB_ADM1, replace
geoframe create WB_ADM2, replace
```

Remember that frames can checked using `frames dir` or one can also switch to an active frame to get the variables or merge datasets etc using `frame change <frame name>`.

Test out the data:

```stata
geoplot ///
	(area WB_ADM0 i.WB_REGION, lc(white) lw(0.1) ) ///
	, ///
	tight ///
	project(robinson) background(water) grid(lc(white) label)	///
	legend(pos(7)) ///
	title("WORLD BANK's ADM0 boundaries (version: July 2026)") ///
	note("Source: https://datacatalog.worldbank.org/search/dataset/0038272/World-Bank-Official-Boundaries.", size(2))
```

<img src="/GIS/wb_admin0.png" width="100%">


Plot all the layers (warning, very large files!): 



```stata
geoplot ///
	(line WB_ADM2, lc(red) lw(0.02) ) ///
	(line WB_ADM1, lc(blue) lw(0.05) ) ///
	(line WB_ADM0, lc(black) lw(0.1) ) ///
	, ///
	tight ///
	legend(pos(7))  ///
	title("World Bank ADM0, ADM1, ADM2 boundaries (version: July 2026)", size(6)) ///
	note("Source: https://datacatalog.worldbank.org/search/dataset/0038272/world-bank-official-boundaries", size(2.5))
```

<img src="/GIS/wb_release5.png" width="100%">



## Feedback

Please open an [issue](https://github.com/asjadnaqvi/stata-geoboundary/issues) to report errors, feature enhancements, and/or other requests. 


## Disclaimer

The Geographic Information System (GIS) data provided herein is for informational/educational purposes only and is not intended for use as a legal or engineering resource. While every effort has been made to ensure the accuracy and reliability of the data, it is provided "as is" without warranty of any kind.

The data provided through this GIS package assumes no liability for any inaccuracies, errors, or omissions in the data, nor for any decision made or action taken based on the information contained herein. Users of this data are responsible for verifying its accuracy and suitability for their intended purposes.

Please be advised that GIS data may be subject to change without notice due to updates, corrections, or other modifications. Users are encouraged to consult the original data sources or contact the provider for the most current information.

By accessing or using the GIS data provided through this package, you acknowledge and agree to these terms and conditions.



## Change log

**v1.3 (15 Oct 2026)**
- Minimum Stata version raised to 17.
- Added Eurostat GISCO NUTS0-NUTS3 region polygons with `vintage()` and `scale()` selection in EPSG:4326.
- Added source-specific metadata, output provenance, staged extraction, overwrite protection, and integration tests.
- Corrected country metadata fall-through and numeric ADM-level searches; improved source and level validation.

**v1.23 (01 Sep 2026)**
- Refreshed the World Bank ADM0-ADM2 shapefiles to match the World Bank's July 2026 data update.

**v1.22 (02 Nov 2025)**
- Updated the World Bank layers to the latest release 5 which now includes ADM0-ADM2 boundaries. This can now be merged with other WB datasets that provide sub-regional data.
- Some large files are now hosted on [Hugging Face](https://huggingface.co/datasets/asjadnaqvi/shapefiles) for stable URLs. It is also better than GIT LFS for various reasons. In case your organization does not allow access to Hugging Face, then directly download the files and manually convert them to shapefiles and geoframes.
- Minor improvements to the code.

**v1.21 (29 Oct 2025)**
- `geoboundary meta` now lists all the countries on the screen.
- Updates and corrections to the meta file.
- Minor code improvements.

**v1.2 (09 Jan 2025)**
- New option `geoframe` added to directly convert to geoplot frames.
- World Bank's official ADM0 layer added to `source()`. See example above.
- Improvements to code and better notes on ongoing background processes.
- Better checks to avoid random program crashes.
- Several bug fixes.

**v1.1 (08 Dec 2024)**
- Added `geoboundary meta` for meta information. Returns locals that can be used for bulk downloading.
- GADM database added.
- Added `source()` to allow downloading from different sources. Currently the default is geoBoundaries or `source(geoboundaries)`, while `source(gadm)` is currently the second option.
- Lower cases are now allowed.
- Various code optimizations.


**v1.0 (25 Nov 2024)**
- First release




