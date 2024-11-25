{smcl}
{* 24Nov2024}{...}
{hi:help geoboundary}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-geoboundary":geoboundary v1.0 (GitHub)}}

{hline}

{title:geoboundary}: 

A Stata package for fetching boundary data from {browse "https://www.geoboundaries.org/":geoBoundaries} database.
The database is provided by the {browse "William and Mary geoLab"} and is available under the CC BY 4.0 license. 

Please also cite the original database when using this package.


{marker syntax}{title:Syntax}

{p 8 15 2}
{cmd:geoboundary} {it:ISO3 codes}, {cmd:level}(string) {cmd:[} {cmd:convert} {cmd:name}({it:str}) {cmd:replace} {cmd:remove} {cmd:]} 


{synoptset 36 tabbed}{...}
{synopthdr}
{synoptline}

{p2coldent : {opt geoboundary} ISO3}Define a single or a list of 3-letter ISO3 codes. 
The codes must be specified in capital letters. Note that if the code is not valid, then the country will be skipped and an error will be displayed.{p_end}

{p2coldent : {opt level(string)}}Valid options are ADM0, ADM1, ADM2, ADM3, ADM4, ADM5, or ALL. A list can also be specified.
If all is specified, then the command will try and download all the six levels.
If any level is not found, it will be skipped and an error message will be displayed.
Note that finer levels, e.g. ADM4 or ADM5 could be very large so use carefully.{p_end}

{p2coldent : {opt replace}}Replace the raw files if they exist.{p_end}

{p2coldent : {opt convert}}Convert to Stata shapefiles.{p_end}

{p2coldent : {opt name(string)}}Define a custom name for the the Stata shape files.{p_end}

{p2coldent : {opt remove}}Remove the raw shapefiles. This option is highly recommended especially if the command is being used for bulk downloads.
The recommendation is to convert the bulk files to Stata format and use this option to remove the raw files to avoid an exploding folder size.{p_end}

{synoptline}
{p2colreset}{...}

{title:Dependencies}

None

{title:Examples}

See {browse "https://github.com/asjadnaqvi/stata-geoboundary":GitHub} for examples.


{title:Package details}

Version      : {bf:geoboundary} v1.0
This release : 24 Nov 2024
First release: 24 Nov 2024
Repository   : {browse "https://github.com/asjadnaqvi/stata-geoboundary":GitHub}
Keywords     : Stata, maps, boundaries
License      : {browse "https://opensource.org/licenses/MIT":MIT}

Author       : {browse "https://github.com/asjadnaqvi":Asjad Naqvi}
E-mail       : asjadnaqvi@gmail.com
Twitter/X    : {browse "https://x.com/AsjadNaqvi":@AsjadNaqvi}



{title:Feedback}

Please submit bugs, errors, feature requests on {browse "https://github.com/asjadnaqvi/stata-geoboundary/issues":GitHub} by opening a new issue.


{title:Citation guidelines}

Suggested citation for this package:

Naqvi, A. (2024). Stata package "geoboundary" version 1.0.
Release date 24 November 2024. https://github.com/asjadnaqvi/stata-geoboundary.

@software{geoboundary,
   author = {Naqvi, Asjad},
   title = {Stata package ``geoboundary''},
   url = {https://github.com/asjadnaqvi/stata-geoboundary},
   version = {1.0},
   date = {2024-11-24}
}



{title:References}

Runfola, D. et al. (2020) geoBoundaries: A global database of political administrative boundaries. 
PLoS ONE 15(4): e0231866. {browse "https://doi.org/10.1371/journal.pone.0231866"}.


{title:Other visualization packages}

{psee}
    {helpb arcplot}, {helpb alluvial}, {helpb bimap}, {helpb bumparea}, {helpb bumpline}, {helpb circlebar}, {helpb circlepack}, {helpb clipgeo}, {helpb delaunay}, {helpb joyplot}, 
	{helpb marimekko}, {helpb polarspike}, {helpb sankey}, {helpb schemepack}, {helpb spider}, {helpb streamplot}, {helpb sunburst}, {helpb treecluster}, {helpb treemap}, {helpb waffle}
	
or visit {browse "https://github.com/asjadnaqvi":GitHub} for detailed documentation and examples.		