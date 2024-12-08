{smcl}
{* 08Dec2024}{...}
{hi:help geoboundary}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-geoboundary":geoboundary v1.1 (GitHub)}}

{hline}

{title:geoboundary}: 

A Stata package for fetching boundary data from:

1. {browse "https://www.geoboundaries.org/":geoBoundaries} database.
2. {browse "https://gadm.org/":GADM} database.

All files are in the standard EPSG:4326 or {browse "https://en.wikipedia.org/wiki/World_Geodetic_System":WGS84} system.

By using the data provided through this package, you are agreeing to the disclaimer below.



{marker syntax1}{title:Syntax for meta data}

{p 8 15 2}
{cmd:geoboundary meta}, {cmd:[} {cmd:country}(list) {cmd:iso}(list) {cmd:level}(list) {cmd:region}(list) {cmd:any}(list) {cmd:length}(num) {cmd:strict} {cmdab:nosep:erator} {cmd:]} 

(see {help geoboundary##meta:{it:meta options}})


This is a helper function where users can recover the meta information by providing a set of search options. Multiple options can also be specified. 
This command returns two r-class locals, {opt r(geob)} and {opt r(gadm)} for a list of iso countries that exist in the two databases. 
These locals can be passed onto the function below for recovering boundary data. This is useful for pulling data for a set of regions.



{marker syntax2}{title:Syntax for boundary data}

{p 8 15 2}
{cmd:geoboundary} {it:ISO3 list}, {cmd:level}(string) {cmd:[} {cmd:convert} {cmd:name}({it:str}) {cmd:source}({it:name}) {cmd:replace} {cmd:remove} {cmd:]} 

(see {help geoboundary##boundary:{it:boundary options}})




{synoptset 36 tabbed}{...}
{marker meta}{synopthdr:meta options}
{synoptline}

{p2coldent : {opt country(string)}}Search by country names. Currently a list of names with spaces is not possible (forthcoming).{p_end}

{p2coldent : {opt iso(string)}}Search by iso3 names.{p_end}

{p2coldent : {opt region(string)}}Search by region names. Correct options are World Bank region classifications, e.g. LAC for Latin America and the Carribbean.{p_end}

{p2coldent : {opt any(string)}}Search for the given expression in any of the raw meta data columns.{p_end}

{p2coldent : {opt strict}}Make the searches strictly limited to the expression specified. E.g. {opt region(NA)} will return both NA (North America) and MENA (Middle East and North Africa).
But if {opt strict} is specified only NA region countries will be returned.{p_end}

{p2coldent : {opt level(string)}}Search by ADM levels. Options that will return results are ADM0, ADM1, ADM2, ADM3, ADM4, ADM5.{p_end}

{p2coldent : {opt length(numeric)}}Limit the length of the table columns displayed after running the command. Might be useful if tables are spanning across multiple rows
and are misaligned. This can occur with long names. Default is {opt length(30)}.{p_end}

{p2coldent : {opt nosep:erator}}Do not add a separator line in the displayed table. Default separators are determined by ISO3s.{p_end}



{synoptset 36 tabbed}{...}
{marker boundary}{synopthdr:boundary options}
{synoptline}

{p2coldent : {opt geoboundary} ISO3}Define a single or a list of 3-letter ISO3 codes. Note that if the code is not valid, the country will be skipped and an error will be displayed. The use of
{cmd geoboundary meta} is highly recommended to check for the correct ISO3 codes. For the world map, the correct ISO3 code is {ul:WLD}.{p_end}

{p2coldent : {opt level(string)}}Valid options are ADM0, ADM1, ADM2, ADM3, ADM4, ADM5, or ALL. A list can also be specified. If all is specified, then the command will try and download all the six levels.
If any level is not found, it will be skipped and an error message will be displayed. Note that finer levels, e.g. ADM4 or ADM5 have large file sizes so use carefully.{p_end}

{p2coldent : {opt source(name)}}Options are {opt source(geoboundary} (default if nothing specified) or {opt source(gadm)}. Both datasets can contain different boundary data and even
different availability of ADM levels. Note that geoBoundaries is more recent than GADM but please check before using. Another note of caution: GADM is downloaded as a zip file 
containing all the ADM levels for each ISO3. This implies (a) all other options are overwritten, and (b) folder size can increases substantially. Other data sources will be added soon (forthcoming).{p_end}

{p2coldent : {opt replace}}Replace the raw files if they exist.{p_end}

{p2coldent : {opt convert}}Convert to Stata shapefiles.{p_end}

{p2coldent : {opt name(string)}}Define a custom name for the the Stata shapefiles. If this option is not used, the default name pattern is {it:ISO3_ADMx}.
For example, {it:USA_ADM1.dta} and {it:USA_ADM1_shp.dta} would be the default Stata shapefile names.{p_end}

{p2coldent : {opt remove}}Remove the raw shapefiles. This option is highly recommended especially if the command is being used for bulk downloads.
The recommendation is to convert the downloaded files to Stata format and then use this option to remove the raw files (.shp .prj .shx .dbf) to avoid an exploding folder size.{p_end}

{synoptline}
{p2colreset}{...}

{title:Dependencies}

None

{title:Examples}

See {browse "https://github.com/asjadnaqvi/stata-geoboundary":GitHub} for examples.


{title:Package details}

Version      : {bf:geoboundary} v1.1
This release : 08 Dec 2024
First release: 25 Nov 2024
Repository   : {browse "https://github.com/asjadnaqvi/stata-geoboundary":GitHub}
Keywords     : Stata, maps, boundaries
License      : {browse "https://opensource.org/licenses/MIT":MIT}

Author       : {browse "https://github.com/asjadnaqvi":Asjad Naqvi}
E-mail       : asjadnaqvi@gmail.com
Twitter/X    : {browse "https://x.com/AsjadNaqvi":@AsjadNaqvi}



{title:Feedback}

Please submit bugs, errors, feature requests on {browse "https://github.com/asjadnaqvi/stata-geoboundary/issues":GitHub} by opening a new issue.


{title:Disclaimer}

The Geographic Information System (GIS) data provided herein is for informational/educational purposes only and is not intended for use as a legal or engineering resource.
While every effort has been made to ensure the accuracy and reliability of the data, it is provided "as is" without warranty of any kind.

The data provided through this GIS package assumes no liability for any inaccuracies, errors, or omissions in the data, nor for any decision made
or action taken based on the information contained herein. Users of this data are responsible for verifying its accuracy and suitability for their intended purposes.

Please be advised that GIS data may be subject to change without notice due to updates, corrections, or other modifications.
Users are encouraged to consult the original data sources or contact the provider for the most current information.

By accessing or using the GIS data provided through this package, you acknowledge and agree to these terms and conditions.


{title:Citation guidelines}

Suggested citation for this package:

Naqvi, A. (2024). Stata package "geoboundary" version 1.1.
Release date 24 November 2024. https://github.com/asjadnaqvi/stata-geoboundary.

@software{geoboundary,
   author = {Naqvi, Asjad},
   title = {Stata package ``geoboundary''},
   url = {https://github.com/asjadnaqvi/stata-geoboundary},
   version = {1.1},
   date = {2024-12-08}
}



{title:References}

{it: for geoBoundaries:}

Runfola, D. et al. (2020) geoBoundaries: A global database of political administrative boundaries. PLoS ONE 15(4): e0231866. {browse "https://doi.org/10.1371/journal.pone.0231866"}.


{title:Other visualization packages}

{psee}
    {helpb arcplot}, {helpb alluvial}, {helpb bimap}, {helpb bumparea}, {helpb bumpline}, {helpb circlebar}, {helpb circlepack}, {helpb clipgeo}, {helpb delaunay}, {helpb graphfunctions}, {helpb geoboundary}, {helpb joyplot}, 
	{helpb marimekko}, {helpb polarspike}, {helpb sankey}, {helpb schemepack}, {helpb spider}, {helpb splinefit}, {helpb streamplot}, {helpb sunburst}, {helpb ternary}, {helpb treecluster}, {helpb treemap}, {helpb trimap}, {helpb waffle}

or visit {browse "https://github.com/asjadnaqvi":GitHub}.	