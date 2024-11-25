
![StataMin](https://img.shields.io/badge/stata-2015-blue) ![issues](https://img.shields.io/github/issues/asjadnaqvi/stata-geoboundary) ![license](https://img.shields.io/github/license/asjadnaqvi/stata-geoboundary) ![Stars](https://img.shields.io/github/stars/asjadnaqvi/stata-geoboundary) ![version](https://img.shields.io/github/v/release/asjadnaqvi/stata-geoboundary) ![release](https://img.shields.io/github/release-date/asjadnaqvi/stata-geoboundary)

[Installation](#Installation) | [Syntax](#Syntax) | [Examples](#Examples) | [Feedback](#Feedback) | [Disclaimer](#Disclaimer)  | [Change log](#Change-log)

---




# geoboundary v1.0
(25 Nov 2024)

A package for fetching country-level or global boundaries from the [geoBoundary](https://www.geoboundaries.org/) database. 

Please note that by using the data provided through this package, you are acknowledging the [disclaimer](#Disclaimer).

All files are in the standard EPSG: 4326 (WGS84) projection.

Note: GIS files are large and quickly accumulate. Please try and download exacly what you need. Please also avoid repeated downloading of the same datasets.


## Installation

The package can be installed via SSC or GitHub. The GitHub version, *might* be more recent due to bug fixes, feature updates etc, and *may* contain syntax improvements and changes in *default* values. See version numbers below. Eventually the GitHub version is published on SSC.

The SSC version (**v1.0**):

```stata
coming soon
```

Or it can be installed from GitHub (**v1.0**):

```stata
net install geoboundary, from("https://raw.githubusercontent.com/asjadnaqvi/stata-geoboundary/main/installation/") replace
```


Additional code for the figures shown below:


```stata
ssc install schemepack, replace
set scheme white_tableau  

graph set window fontface "Arial Narrow"
```


## Citation guidelines
Software packages take countless hours of programming, testing, and bug fixing. If you use this package, then a citation would be highly appreciated:


Click here for the latest [SSC citation](XXXXXX).


otherwise the following BibTeX citation can be used:

```BibTeX
@software{sankey,
   author = {Naqvi, Asjad},
   title = {Stata package ``geoboundary''},
   url = {https://github.com/asjadnaqvi/stata-geoboundary},
   version = {1.0},
   date = {2024-11-25}
}
```



The geoBoundary package [citation guidelines](https://www.geoboundaries.org/#tabs1-html) suggest the following citation:


Runfola, D. et al. (2020) geoBoundaries: A global database of political administrative boundaries. PLoS ONE 15(4): e0231866. https://doi.org/10.1371/journal.pone.0231866




## Syntax

The syntax for the latest version is as follows:

```stata
geoboundary ISO3 codes, level(string) [ convert name(str) replace remove ]
```

See `help geoboundary` for details.

Please note that invalid `ISO3` names in a list of names will simply skip the processing. Check the geoBoundary website for the correct list. Some ISO3 classifications do assign different ISO3 codes to the same countries. E.g. for Germany both `DEU` (correct in geoboundary) and `GER` is used.

Admin levels for some countries are available upto the 5th level (ADM5). If you are specifying a list of countries with a large administrative boundary depth, e.g. `geoboundary PAK IND, level(ADM0 ADM1 ADM2 ADM4)`, the combination that does not exist will be skipped.


## Examples

First make sure you are in the correct directory where the maps files have to be downloaded by setting the path: `cd <mypath>`.

### Download

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


### Map

Once the files are downloaded we can see if they are working.

For Stata 16 or lower, we can use the `spmap` command:


```stata
use WLD_ADM0, clear

spmap using WLD_ADM0_shp, id(_ID)
```


<img src="/GIS/world_spmap.png" width="100%">

For Stata 17 or higher, we can use the `geoplot` command:




## Feedback

Please open an [issue](https://github.com/asjadnaqvi/stata-geoboundary/issues) to report errors, feature enhancements, and/or other requests. 


## Disclaimer

The Geographic Information System (GIS) data provided herein is for informational/educational purposes only and is not intended for use as a legal or engineering resource. While every effort has been made to ensure the accuracy and reliability of the data, it is provided "as is" without warranty of any kind.

The data provided through this GIS package assumes no liability for any inaccuracies, errors, or omissions in the data, nor for any decision made or action taken based on the information contained herein. Users of this data are responsible for verifying its accuracy and suitability for their intended purposes.

Please be advised that GIS data may be subject to change without notice due to updates, corrections, or other modifications. Users are encouraged to consult the original data sources or contact the provider for the most current information.

By accessing or using the GIS data provided through this package, you acknowledge and agree to these terms and conditions.





## Change log

**v1.0 (25 Nov 2024)**
- First release





