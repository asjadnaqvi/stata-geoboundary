{smcl}
{* 04Nov2026}{...}
{hi:help geoboundary}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-geoboundary":geoboundary v1.31 (GitHub)}}

{hline}

{title:geoboundary}: 

A Stata 17+ package for fetching boundary data from:

1. {browse "https://www.geoboundaries.org/":geoBoundaries} (default).
2. {browse "https://gadm.org/":GADM} v4.1
3. {browse "https://datacatalog.worldbank.org/search/dataset/0038272/World-Bank-Official-Boundaries":World Bank} global layers release 5 (July 2026 update).
4. {browse "https://gisco-services.ec.europa.eu/distribution/v2/nuts/":Eurostat GISCO} NUTS region polygons.

All files are in the standard EPSG:4326 or {browse "https://en.wikipedia.org/wiki/World_Geodetic_System":WGS84} system.

By using the data provided through this package, you are agreeing to the disclaimer below.



{marker syntax1}{title:Syntax for meta data}

{p 8 15 2}
{cmd:geoboundary meta}, {cmd:[} {cmd:country}(list) {cmd:iso}(list) {cmd:level}(list) {cmd:region}(list) {cmd:any}(list) {cmd:length}(num) {cmd:strict} {cmdab:nosep:erator} {cmd:]} 

(see {help geoboundary##meta:{it:meta options}})


This is a helper function where users can recover the meta information by providing a set of search options.
Multiple options can also be specified.
This command returns two r-class locals, {opt r(geob)} and {opt r(gadm)} for a list of iso countries that exist in the two databases. 
These locals can be passed onto the function below for recovering boundary data. This is useful for pulling data for a set of regions.

For Eurostat, the metadata command instead lists supported NUTS vintages, levels, scales, coverage, and CRS.
It returns {cmd:r(source)}, {cmd:r(vintages)}, {cmd:r(levels)}, {cmd:r(scales)}, and {cmd:r(crs)}.
The country-oriented metadata search options cannot be combined with {cmd:source(eurostat)}.



{marker syntax2}{title:Syntax for boundary data}

{p 8 15 2}
{cmd:geoboundary} {it:ISO3 list}, {cmd:level}(string) {cmd:[} {cmd:convert} {cmd:geoframe} {cmd:name}({it:str}) {cmd:source}({it:str}) {cmd:vintage}({it:str}) {cmd:scale}({it:str}) {cmd:replace} {cmd:remove}  {cmd:]}

{pstd}
Options depend on {cmd:source()}. See the
{help geoboundary##geoboundaries:geoBoundaries},
{help geoboundary##gadm:GADM},
{help geoboundary##worldbank:World Bank}, and
{help geoboundary##eurostat:Eurostat GISCO} workflows for source-specific syntax and options.
{p_end}

(see {help geoboundary##boundary:{it:boundary options}})




{synoptset 36 tabbed}{...}
{marker meta}{synopthdr:meta options}
{synoptline}

{p2coldent : {opt country(string)}}Search by country names. Currently a list of names with spaces is not possible (forthcoming).{p_end}

{p2coldent : {opt iso(string)}}Search by ISO3 codes.{p_end}

{p2coldent : {opt region(string)}}Search by region names. Correct options are World Bank region classifications, e.g. LAC for Latin America and the Caribbean.{p_end}

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

{p2coldent : {opt level(str)}}With geoBoundaries or World Bank, use ADM0 through ADM5 or ALL; World Bank also supports NDLSA. GADM downloads all available levels and ignores {cmd:level()}. With Eurostat, use NUTS0 through NUTS3 or ALL. Specify ALL by itself: it tries ADM0 through ADM5 for geoBoundaries and World Bank, and NUTS0 through NUTS3 for Eurostat. For geoBoundaries and World Bank, unavailable administrative levels are skipped with an error message. Finer administrative levels, such as ADM4 or ADM5, can have large file sizes.{p_end}

{p2coldent : {opt source(str)}}Choose the boundary source. Each source is discussed below:
{help geoboundary##geoboundaries:geoBoundaries} ({cmd:geoboundaries} or {cmd:geob}, default),
{help geoboundary##gadm:GADM} ({cmd:gadm}),
{help geoboundary##worldbank:World Bank} ({cmd:worldbank}), or
{help geoboundary##eurostat:Eurostat GISCO} ({cmd:eurostat}).{p_end}

{p2coldent : {opt vintage(str)}}Eurostat only. NUTS classification vintage: 2003, 2006, 2010, 2013, 2016, 2021, or 2024 (default). This is not the statistical observation year.{p_end}

{p2coldent : {opt scale(str)}}Eurostat only. Map scales: 01m, 03m, 10m, 20m (default), or 60m, denoting 1:1, 1:3, 1:10, 1:20, or 1:60 million. NUTS 2003 has no 60m layer.{p_end}

{p2coldent : {opt replace}}Replace the files if they exist.{p_end}

{p2coldent : {opt convert}}Convert to Stata shapefiles using {stata help spshape2dta:spshape2dta}.{p_end}

{p2coldent : {opt geoframe}}Convert the data to a {stata help geoframe:geoframe}.
Requires the {help geoplot:geoplot} package to be installed.{p_end}

{p2coldent : {opt name(str)}}Define a custom prefix for the output files using the pattern {it:NAME_ADMx}. Otherwise, the default name pattern is {it:ISO3_ADMx}.
For example, {it:USA_ADM1.dta} and {it:USA_ADM1_shp.dta} would be the default Stata shapefile names.{p_end}

{p2coldent : {opt remove}}Remove the raw shapefiles. This option is highly recommended especially if the command is being used for bulk downloads.
The recommendation is to convert the downloaded files to Stata format and then use this option to remove the raw files (.shp .prj .shx .dbf) to avoid an exploding folder size.{p_end}



{synoptline}
{p2colreset}{...}

{marker geoboundaries}{...}
{title:geoBoundaries workflow}

{pstd}
geoBoundaries is the default source; {cmd:source(geob)} is a shorthand.
Use a country ISO3 code or a list of codes with the desired ADM levels.
Availability varies by country; use {cmd:geoboundary meta} to check coverage.
Use {cmd:WLD} for global layers.

{phang2}{cmd:geoboundary AUT, level(ADM0) convert}{p_end}
{phang2}{cmd:geoboundary WLD, level(ADM0) convert}{p_end}

{marker gadm}{...}
{title:GADM workflow}

{pstd}
Use {cmd:source(gadm)} with country ISO3 codes to download GADM v4.1.
Each country archive contains all available ADM levels, so this source
overrides {cmd:level()} and downloads all levels. Archives can be large.
Coverage and boundaries may differ from geoBoundaries; check the metadata before use.

{phang2}{cmd:geoboundary AUT, source(gadm) convert}{p_end}

{marker worldbank}{...}
{title:World Bank workflow}

{pstd}
Use {cmd:WLD} with {cmd:source(worldbank)} for global coverage.
Country-specific downloads are not supported. Available administrative layers are
{cmd:ADM0}, {cmd:ADM1}, and {cmd:ADM2}, in EPSG:4326.
Specify a single level or a list. {cmd:level(ALL)} retains the ADM-only behavior:
it attempts ADM0 through ADM5 and skips unavailable levels.

{pstd}
{cmd:level(NDLSA)} downloads the separate Non-Determined Legal Status Areas
polygon layer. Combine it with ADM levels, for example {cmd:level(ADM0 NDLSA)}.
It is not included by {cmd:level(ALL)}.
These are legal-status areas, not a general inventory of active conflicts.
No country ownership is assigned. Original attributes are retained.

{pstd}
Default raw filenames use {it:WB_ADM0} or {it:WB_NDLSA}.
{cmd:convert} creates the corresponding {it:.dta} and {it:_shp.dta} datasets.
{cmd:name(mymap)} changes the converted prefix to {it:mymap_ADM0} or {it:mymap_NDLSA}.
{cmd:geoframe} creates geoframes using the installed geoframe command distributed with geoplot.
For NDLSA, {cmd:geoframe} and {cmd:remove} require {cmd:convert};
existing files and frames require {cmd:replace}.
Failed NDLSA conversion retains the raw files.

{pstd}
NDLSA comes directly from the official catalogue's October 2026 shapefile release,
whereas the ADM layers remain the mirrored July 2026 release.
Check compatibility and retain local copies for reproducibility.

{phang2}{cmd:geoboundary WLD, source(worldbank) level(ADM0) convert}{p_end}
{phang2}{cmd:geoboundary WLD, source(worldbank) level(NDLSA) convert}{p_end}
{phang2}{cmd:geoboundary WLD, source(worldbank) level(ADM0 NDLSA) convert}{p_end}

{marker eurostat}{...}
{title:Eurostat GISCO workflow}

{pstd}
Use {cmd:EUR} with {cmd:source(eurostat)} to download NUTS region polygons in EPSG:4326.
Coverage includes all countries supplied by GISCO, not just EU members; individual countries cannot be selected.
Choose {cmd:NUTS0}, {cmd:NUTS1}, {cmd:NUTS2}, {cmd:NUTS3}, or {cmd:ALL}.
NUTS levels differ from ADM levels.

{pstd}
The defaults are {cmd:vintage(2024)} and {cmd:scale(20m)}.
Use {cmd:geoboundary meta, source(eurostat)} to list available vintages and scales.
Match the NUTS vintage to your statistical data before merging on {cmd:NUTS_ID};
the command does not harmonise boundaries across vintages.

{pstd}
Converted files use names such as {it:ESTAT_NUTS2_2024_20M_4326.dta} and
{it:ESTAT_NUTS2_2024_20M_4326_shp.dta}. {cmd:name(myregions)} replaces the ESTAT prefix.
Original attributes are retained. Both {cmd:geoframe} and {cmd:remove} require {cmd:convert};
{cmd:geoframe} also requires geoplot. Use {cmd:replace} to overwrite existing files and frames.
Failed conversion keeps the raw files. The current dataset and working directory are preserved.

{pstd}
When {cmd:convert} is specified, source details are saved as dataset characteristics; source details are also returned in {cmd:r()}.
Keep local copies for reproducibility, since GISCO may update files.
Acknowledge Eurostat/GISCO and follow the
{browse "https://gisco-services.ec.europa.eu/distribution/v2/":GISCO download provisions}.

{phang2}{cmd:geoboundary meta, source(eurostat)}{p_end}
{phang2}{cmd:geoboundary EUR, source(eurostat) level(NUTS2) convert}{p_end}
{phang2}{cmd:geoboundary EUR, source(eurostat) level(NUTS2) vintage(2021) convert}{p_end}

{title:Examples}
See {browse "https://github.com/asjadnaqvi/stata-geoboundary":GitHub} for examples.


{title:Package details}

Version      : {bf:geoboundary} v1.31
This release : 04 Nov 2026
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

{pstd}
This package downloads third-party Geographic Information System (GIS) data for informational and educational purposes.
The data are not intended as a legal or engineering resource and are provided "as is", without warranty of any kind.
The package author and contributors do not guarantee their accuracy, completeness, or suitability for any particular purpose.

{pstd}
To the extent permitted by applicable law, the package author and contributors accept no liability for errors or omissions
in the data or for loss or damage arising from their use. Users are responsible for verifying the data and their suitability
for the intended use.

{pstd}
Names, boundaries, and disputed-area classifications reflect the source datasets. Their inclusion does not imply endorsement
by the package author or contributors, or any position on sovereignty, territorial claims, or legal status.

{pstd}
Each dataset remains subject to its source provider's licence, attribution requirements, and usage restrictions.
The package's software licence does not replace these conditions.

{pstd}
Source data may change without notice. Consult the original providers for current information and retain the release,
retrieval date, and local files needed to reproduce your results.


{title:Citation guidelines}

{pstd}
See {browse "https://ideas.repec.org/c/boc/bocode/s459399.html"} for the official SSC citation. 
Please note that the GitHub version might be newer than the SSC version.


{title:References}

{pstd}
Runfola, D. et al. (2020) geoBoundaries: A global database of political administrative boundaries. PLoS ONE 15(4): e0231866.
{browse "https://doi.org/10.1371/journal.pone.0231866"}.

{pstd}
GADM. GADM database of Global Administrative Areas, version 4.1.
{browse "https://gadm.org/data.html":Dataset}.
See the {browse "https://gadm.org/license.html":GADM licence} for usage conditions.

{pstd}
World Bank (2026). World Bank Official Boundaries. World Bank Data Catalog.
ADM0-ADM2: July 2026 release; NDLSA: October 2026 release.
{browse "https://datacatalog.worldbank.org/search/dataset/0038272/world-bank-official-boundaries":Dataset}.

{pstd}
European Commission, Eurostat/GISCO. NUTS: Nomenclature of Territorial Units for Statistics.
{browse "https://ec.europa.eu/eurostat/web/gisco/geodata/statistical-units/territorial-units-statistics":Dataset}.

{pstd}
For reproducibility, include the release or vintage and access date when citing boundary datasets.{p_end}


{title:Other packages}

{psee}
    {helpb arcplot}, {helpb alluvial}, {helpb bimap}, {helpb bumparea}, {helpb bumpline}, {helpb circlebar}, {helpb circlepack}, {helpb clipgeo}, {helpb delaunay}, {helpb eurostatdata}, {helpb graphfunctions},
	{helpb geoboundary}, {helpb geoflow}, {helpb joyplot}, {helpb marimekko}, {helpb polarspike}, {helpb sankey}, {helpb schemepack}, {helpb spider}, {helpb splinefit}, {helpb streamplot}, 
	{helpb sunburst}, {helpb ternary}, {helpb tidytuesday}, {helpb treecluster}, {helpb treemap}, {helpb trimap}, {helpb waffle}

Visit {browse "https://github.com/asjadnaqvi":GitHub} for further information.