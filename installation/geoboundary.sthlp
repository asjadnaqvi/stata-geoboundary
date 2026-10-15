{smcl}
{* 15Oct2026}{...}
{hi:help geoboundary}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-geoboundary":geoboundary v1.3 (GitHub)}}

{hline}

{title:geoboundary}: 

A Stata package for fetching boundary data from:

1. {browse "https://www.geoboundaries.org/":geoBoundaries} (default).
2. {browse "https://gadm.org/":GADM} v4.1
3. {browse "https://datacatalog.worldbank.org/search/dataset/0038272/World-Bank-Official-Boundaries":World Bank} global layers release 5 (July 2026 update).
4. {browse "https://gisco-services.ec.europa.eu/distribution/v2/nuts/":Eurostat GISCO} NUTS region polygons.

All files are in the standard EPSG:4326 or {browse "https://en.wikipedia.org/wiki/World_Geodetic_System":WGS84} system.

By using the data provided through this package, you are agreeing to the disclaimer below.



{marker syntax1}{title:Syntax for meta data}

{p 8 15 2}
{cmd:geoboundary meta}, {cmd:[} {cmd:country}(list) {cmd:iso}(list) {cmd:level}(list) {cmd:region}(list) {cmd:any}(list) {cmd:length}(num) {cmd:strict} {cmdab:nosep:erator} {cmd:]} 

{p 8 15 2}
{cmd:geoboundary meta, source(eurostat)}

(see {help geoboundary##meta:{it:meta options}})


This is a helper function where users can recover the meta information by providing a set of search options. Multiple options can also be specified. 
This command returns two r-class locals, {opt r(geob)} and {opt r(gadm)} for a list of iso countries that exist in the two databases. 
These locals can be passed onto the function below for recovering boundary data. This is useful for pulling data for a set of regions.

For Eurostat, the metadata command instead lists supported NUTS vintages, levels, scales, coverage, and CRS.
It returns {cmd:r(source)}, {cmd:r(vintages)}, {cmd:r(levels)}, {cmd:r(scales)}, and {cmd:r(crs)}.
Country metadata search options cannot be combined with {cmd:source(eurostat)}.



{marker syntax2}{title:Syntax for boundary data}

{p 8 15 2}
{cmd:geoboundary} {it:ISO3 list}, {cmd:level}(string) {cmd:[} {cmd:convert} {cmd:geoframe} {cmd:name}({it:str}) {cmd:source}({it:str}) {cmd:replace} {cmd:remove}  {cmd:]} 

{p 8 15 2}
{cmd:geoboundary EUR, source(eurostat) level}({it:list}) {cmd:[} {cmd:vintage}({it:str}) {cmd:scale}({it:str}) {cmd:convert} {cmd:geoframe} {cmd:name}({it:str}) {cmd:replace} {cmd:remove} {cmd:]}

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

{p2coldent : {opt geoboundary} ISO3}Define a single or a list of 3-letter ISO3 codes. Note that if the code is not valid, the country will be skipped and an error will be displayed.
The use of
{cmd geoboundary meta} is highly recommended to check for the correct ISO3 codes. For the world map, the correct ISO3 code is {ul:WLD}.{p_end}

{p2coldent : {opt level(str)}}Valid options are ADM0, ADM1, ADM2, ADM3, ADM4, ADM5, or ALL. A list can also be specified. If all is specified, then the command will
try and download all the six levels.
If any level is not found, it will be skipped and an error message will be displayed. Note that finer levels, e.g. ADM4 or ADM5 have large file sizes so use carefully.{p_end}

{p2coldent : {opt source(str)}}Options are {opt source(geoboundaries)} or {opt source(geob)} (default), {opt source(gadm)}, {opt source(worldbank)}, or {opt source(eurostat)}. World Bank only downloads
official World Bank's global boundaries. The first two datasets might contain different boundary data and different coverage of ADM levels.
Note that geoBoundaries is more recent than GADM but please check the meta information before using (see above).
Another note of caution: GADM is downloaded as a zip file containing all the ADM levels for each ISO3.
Therefore, using this option implies that layer-specific options are overwritten. This can also increase the folder size so use carefully!
Eurostat requires {cmd:EUR} and NUTS levels, as described below.{p_end}

{p2coldent : {opt vintage(str)}}Eurostat only. NUTS classification vintage: 2003, 2006, 2010, 2013, 2016, 2021, or 2024 (default). This is not the statistical observation year.{p_end}

{p2coldent : {opt scale(str)}}Eurostat only. Map scales: 01m, 03m, 10m, 20m (default), or 60m, denoting 1:1, 1:3, 1:10, 1:20, or 1:60 million. NUTS 2003 has no 60m layer.{p_end}

{p2coldent : {opt replace}}Replace the files if they exist.{p_end}

{p2coldent : {opt convert}}Convert to Stata shapefiles using {stata help spshape2dta:spshape2dta}.{p_end}

{p2coldent : {opt geoframe}}Convert the data to a {stata help geoframe:geoframe}.{p_end}

{p2coldent : {opt name(str)}}Define a custom name for the the Stata shapefiles using the pattern {it:NAME_ADMx}. Otherwise, the default name pattern is {it:ISO3_ADMx}.
For example, {it:USA_ADM1.dta} and {it:USA_ADM1_shp.dta} would be the default Stata shapefile names.{p_end}

{p2coldent : {opt remove}}Remove the raw shapefiles. This option is highly recommended especially if the command is being used for bulk downloads.
The recommendation is to convert the downloaded files to Stata format and then use this option to remove the raw files (.shp .prj .shx .dbf) to avoid an exploding folder size.{p_end}



{synoptline}
{p2colreset}{...}

{title:Eurostat GISCO workflow}

{pstd}
Use {cmd:EUR} for all countries supplied by GISCO, not an EU membership subset.
Country-specific selection is not supported. Levels are {cmd:NUTS0}, {cmd:NUTS1}, {cmd:NUTS2}, and {cmd:NUTS3};
{cmd:ALL} downloads all four. NUTS levels are not equivalent to ADM levels.
Only region polygons (RG) are downloaded, in EPSG:4326, using zipped ESRI shapefiles.

{pstd}
Default filenames follow {it:ESTAT_NUTS2_2024_20M_4326.dta} and {it:ESTAT_NUTS2_2024_20M_4326_shp.dta}.
{cmd:name(myregions)} changes only the ESTAT prefix. For Eurostat, {cmd:geoframe} and {cmd:remove} require {cmd:convert}.
Geoframes require the installed geoframe command distributed with geoplot.
{cmd:replace} controls overwriting raw files, datasets, and geoframes.
Failed conversion retains the raw files; removal occurs only after successful processing.
The current dataset and working directory are preserved.

{pstd}
Original attributes, including NUTS_ID, CNTR_CODE, and LEVL_CODE, are retained.
Match the statistical dataset's classification vintage before merging on NUTS_ID.
Observation years alone do not determine the vintage, and identical codes across vintages need not identify identical territories.
Statistical harmonisation between vintages is not performed by this command.

{pstd}
Dataset characteristics with the {cmd:geoboundary_} prefix record source, vintage, level, scale, CRS, URL, and retrieval date.
Returned locals are {cmd:r(source)}, {cmd:r(vintage)}, {cmd:r(scale)}, {cmd:r(levels)}, {cmd:r(crs)},
{cmd:r(retrieved)}, {cmd:r(files)}, and {cmd:r(urls)}.
GISCO can correct files within a vintage: retain local files for reproducibility.
Metadata does not provide a checksum or immutable snapshot.
Respect the {browse "https://gisco-services.ec.europa.eu/distribution/v2/":GISCO download provisions}
and acknowledge Eurostat/GISCO; the package licence does not replace data usage conditions.

{phang2}{cmd:geoboundary meta, source(eurostat)}{p_end}
{phang2}{cmd:geoboundary EUR, source(eurostat) level(NUTS2) vintage(2024) scale(20m) convert remove}{p_end}
{phang2}{cmd:geoboundary EUR, source(eurostat) level(ALL) vintage(2021) scale(60m) convert geoframe remove}{p_end}

{title:Examples}
See {browse "https://github.com/asjadnaqvi/stata-geoboundary":GitHub} for examples.


{title:Package details}

Version      : {bf:geoboundary} v1.3
This release : 15 Oct 2026
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

The Geographic Information System (GIS) data provided herein is for informational/educational purposes only
and is not intended for use as a legal or engineering resource.
While every effort has been made to ensure the accuracy and reliability of the data, it is provided "as is" without warranty of any kind.

The data provided through this GIS package assumes no liability for any inaccuracies, errors, or omissions in the data, nor for any decision made
or action taken based on the information contained herein.
Users of this data are responsible for verifying its accuracy and suitability for their intended purposes.

Please be advised that GIS data may be subject to change without notice due to updates, corrections, or other modifications.
Users are encouraged to consult the original data sources or contact the provider for the most current information.

By accessing or using the GIS data provided through this package, you acknowledge and agree to these terms and conditions.


{title:Citation guidelines}

See {browse "https://ideas.repec.org/c/boc/bocode/s459399.html"} for the official SSC citation. 
Please note that the GitHub version might be newer than the SSC version.


{title:References}

Runfola, D. et al. (2020) geoBoundaries: A global database of political administrative boundaries. PLoS ONE 15(4): e0231866.
{browse "https://doi.org/10.1371/journal.pone.0231866"}.


{title:Other visualization packages}

{psee}
    {helpb arcplot}, {helpb alluvial}, {helpb bimap}, {helpb bumparea}, {helpb bumpline}, {helpb circlebar}, {helpb circlepack}, {helpb clipgeo}, {helpb delaunay}, {helpb graphfunctions},
	{helpb geoboundary}, {helpb geoflow}, {helpb joyplot}, {helpb marimekko}, {helpb polarspike}, {helpb sankey}, {helpb schemepack}, {helpb spider}, {helpb splinefit}, {helpb streamplot}, 
	{helpb sunburst}, {helpb ternary}, {helpb tidytuesday}, {helpb treecluster}, {helpb treemap}, {helpb trimap}, {helpb waffle}

Visit {browse "https://github.com/asjadnaqvi":GitHub} for more information.