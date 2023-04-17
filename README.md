# ALEPH-facet-searching-for-OPAC
OPAC short results page includes new html element with displaying facets - filters on authors, subjects, years etc. to narrow the current search results.

# FACETED SEARCHING FOR ALEPH OPAC

## Requirements:
ALEPH version 21 (for below purposed procession of years of publishing, otherwise ver. 18); ALEPH X-server, Perl with implemented modules: XML::XPath (this one might not be included in Perl ALEPH distribution), DBI, LWP, POSIX, 
JavaScript, AJAX, CGI.

## Description 
Front-end process: On OPAC short-results web page a search set No. and amount of recs. found are determined from OPAC placeholders. These values are processed by JavaScript class facets, which code is mostly in standalone file facets.js. This class uses AJAX call to cgi script `facets.cgi`, which is simple csh redirection to outside of Apache dirs located Perl script `facets.pl`. This Perl script calls X-server function (op) “present” to get set of record Nos. of the current search set. Then, Oracle z01 and z02 tables are queried to get facets as acc headings for these records. The results are processed and returned back to end user JavaScript as xml response, which is again processed and displayed. The recently performed facet filter name is now marked bold and a new link “Cancel filters” is added to beginning of facet html element. The Perl script also stores temporary results of these X-server and Oracle queries for faster responding when listing through results on more www pages.

The facets as to their type and contents can be defined fully upon admin decision. The amount of facets values for each type can be limited to total amount of displayed recommendations, as well as to amount of primarily displayed with link “show more” to display others. The procession can be defined for more OPAC language versions. Sorting of facet values in each group can be set as: by no. of corresponding recs descending and by alphabet ascending or descending.

**Creator**: Matyas Franciszek Bajger ( http://bajger.wz.cz, matyas.bajger@seznam.cz ), University of Ostrava Library (http://library.osu.eu) , 2016-2017.   
**Licence**: GNU GPL version 3.0   
**Live example**: [http://aleph.osu.cz](http://aleph.osu.cz) (University of Ostrava Library)   
 ![screenshot live example](http://aleph.osu.cz/facets/pack/aleph_facets_live_screenshot.jpg)  


# Implementation
## I. Definition of facets

###I.0 Implementation files / pack
The following files – script, configuration, etc. are used in this extension.   
`audience-abbrev-cze.fix` – fix_doc_do_file_08 ALEPH fix for changing Marc21 008 field / 22 position – target   audience code to natural language, Czech version  
`audience-abbrev-eng.fix` – the same, English version  
`close2.png` – image with cross (X) used for hiding html element with facets   
`facets.cgi` – cgi script called by AJAX from OPAC (executable – chmod +x)   
`facets.js` – javascript included in OPAC web pages   
`facets.pl` – Perl script retrieving and processing facets for displaying them (called by the facets.cgi script)   
`genre-abbrev-cze.fix` - fix_doc_do_file_08 ALEPH fix for changing Marc21 008 field / 24-27 and 33 positions (nature of contents and literary form) codes to natural language, Czech version   
`genre-abbrev-eng.fix` – the same, English version   
`osu_facets` – definition of facets used by front-end displaying facets in OPAC, to be stored at $data_tab directory   
`tab_abbrev_LNG_only_cze` – part of $data_tab/tab_abbrev standard ALEPH config. file with translation of Marc21    language codes to natural language. To be added to the $data_tab/tab_abbrev file. Czech version   
`tab_abbrev_LNG_only_eng`  – the same, English version   

_These files are available_ at Github - [https://github.com/osulib/ALEPH-facet-searching-for-OPAC/](https://github.com/osulib/ALEPH-facet-searching-for-OPAC/) or [https://github.com/matyasbajger/](https://github.com/matyasbajger/)
Or a pack with them can be downloaded from [http://aleph.osu.cz/facets/pack/aleph_facets.tgz](http://aleph.osu.cz/facets/pack/aleph_facets.tgz) [2016-02-03]

###I.1 Define facets as common ALEPH ACC headings 
Define facets as common ALEPH ACC headings using common definition tables/files `tab11_acc, tab00.{lng}, tab_expand` located in `$data_tab` of the corresponding BIB base, and potentially further expand procedures. You can also use formerly defined and already used headings, when defined subfields could be omitted for facets from them, or define new headings. It is recommended to name these new headings with starting letter F (like “FLN”, “FYR” etc.) for easier orientation. See below (chapter I.3) for purposed definition of facets. After changing definition of ACC headings, rebuilt this headings using manage-02 and following procedures manage-16, manage-17 and manage-32 (this just if you use z0102 table in definition of logical bases). 

###I.2.  osu_facets configuration file
Take (download) an empty defintion table – file `osu_facets` and save it in `$data_tab` directory of the corresponding BIB base.  
Configure this table. Its syntax is conformable to common ALEPH config. tables. Comments are also lines starting with exclamation mark “!”  

**Part I** of this file – lines starting with at_sign @ - contain general settings for facets. Namely:  
* BIB base name,   
*               Oracle password for this BIB base,   
*               Oracle SID (for connection to the database) and  Oracle host DNS,   
*               X-server URL (DNS),   
*               Max. lines/values of facets in each group that are showed immediately (others can be displayed after clicking on “show more”)  
*               Max. lines/values of facets in each group that are displayed in total. If more values are found, they are omitted (trimmed).  
*              Language definition for “show more” and “cancel filters” links used in facet html element.  

See heading of this `osu_facets` table for instructions, how to fill up these values.  

Part II of the file osu_facets contains definition of particular facets and it is used by `facets.pl` Perl script. They are displayed in OPAC in the same order as listed in this file.  
This part is used for referring to ACC headings used for facets (col. 1), selecting or omitting subfields from headings (col. 2), sort order of values (col. 3), and names of facets displayed in OPAC for more languages (col. 4). 
See heading and comments of this osu_facets table for instructions, how to fill up these values.

###I.3 Purposed definition of facets
This is purposed and possible definition of facets for ALEPH BIB base that can be used or modified up to local demands. This setting is based on Marc21 format and AACR2 and RDA cataloguing rules. Language settings are for English and Czech. The facets defined here are (starting with ACC heading code used):

-	AUT authors: taken from fields 100, 700, using acc headings AUT; with omitting subfields 4, 7 (authority identifier and relator code), sorted by amount of occurrences in search set results.
-	SUB subjects: taken from fields 600, 610, 611, 630, 648, 650, 651, 653, 690, using acc headings SUB; omitting subfields 2, 7 (authority identifier and dictionary/thesaurus code) , sorted by amount of occurrences in search set results.
-	GNR genre: taken from fields 655 and 008/position 24-27, 33 (for books – FMT BK recs only). The coded values from 008 field are converted to natural language using genre-abbrev-eng.fix (for English), resp. genre-abbrev-cze.fix (for Czech), using  expanded GNR field, which is indexed. Only 655 field, subfield a is used. Sorted by amount of occurrences in search set results.
-	FLN language: taken from fields 008/positions 35-37 and fields 041. These fields/position are expanded to virtual field LNG, which is transferred from Marc21 codes to natural language names using tab_abbrev
-	FYR year of publishing – taken from 008, 260, 264 Marc21 fields using standard ALEPH expand procedure expand_doc_date_yrr. Then modified by own expansion procedure osu_facets_year.pl, which changes years between 1900-2000 to decades (1900-1909, 1910-1919 etc.) and years before 1900 to centuries (1800-1899, 1700-1799 etc.). Sorted by facet value descending.
-	FAU target audience – taken from field 008 / position  22 (only for records with FMT field values BK, MU, VM; i.e. books, music, and visual material). Modified to natural language using audience-abbrev-eng.fix (for English), resp. audience-abbrev-cze.fix (for Czech), using expanded FAD field, which is indexed. Sorted by amount of occurrences in search set results.

Definitions for particular configuration tables for creating headings, expansion, fixes and definition of facets   

a) `tab00.{lng}` [i.e. tab00.eng, tab00.eng and suchlike according to languages defined]
	Add or check the following lines – definition of acc headings. Note that headings AUT, SUB and might GNR are potentially already defined in your system.

     H AUT   ACC     01 00       00       Authors
     H SUB   ACC     01 00       00       Subjects
     H GNR   ACC     01 00       00       Genre/Form
     H FLN   ACC     01 00       00       Facets-language
     H FYR   ACC     01 00       00       Facets-year

Check the column 5 - Filing procedure (specified in tab_filing), if such filing is defined in your system or modify it according to local usage of filing. Change column 11 – heading name by language version of the table    

b) `tab11_acc`
	Add or check the following lines – definition of acc headings. Note that headings AUT, SUB and might GNR are potentially already defined in your system and might have different subfields, indicators and some definition of subfield filter (column 3)

     100##                    AUT   abcdq0789
     600##                    SUB   -eh468
     610##                    SUB   -h4682
     611##                    SUB   -h4682
     630##                    SUB   adfgklmnoprs097
     648##                    SUB   avxyz27
     650##                    SUB   a27
     651##                    SUB   a27
     653##                    SUB   -68
     655##                    GNR   -wi
     690##                    SUB   a7
     700##                     AUT   abcdklmnopqrstu0789
     LNG##                    FLN   a
     GNR##                    FGN   a
     FYR##                    FYR   a

 c) `tab_expand`
	Add or check the following expansions defined in $data_tab/tab_expand used for this purposed settings

     ACC        fix_doc_do_file_08             language-abbrev.fix
     ACC        fix_doc_do_file_08             genre-abbrev.fix
     ACC        fix_doc_do_file_08             audience-abbrev.fix
     ACC        expand_doc_fix_abbreviation    REPLACE
     ACC        expand_doc_date_yrr
     ACC        osu_facets_year.pl

d) fix/expansion definitions or script used by preceding definition of tab_expand   
      Take/download files `language-abbrev.fix`, `genre-abbrev.fix`, `audience-abbrev.fix` and save them to `$data_tab/import directory`  

Download file `tab_abbrev_LNG_only_cze` – for Czech, or `tab_abbrev_LNG_only_eng` – for English, and copy its content to file `$data_tab/tab_abbrev`. This setting is used for expansion of language code in expanded LNG field to natural language according to Marc21 language code list.

Download own expansion script `osu_facets_year.pl` and save it to `$aleph_exe` directory. As the $aleph_exe dir is located in “a” branch of ALEPH directory tree, we recommend to save it somewhere else in your own directories and create a symlink to it from $aleph_exe directory. ALEPH version 21 needed for this (cf. [http://knowledge.exlibrisgroup.com/@api/deki/files/27349/Writing_Expand_Routines_in_any_Programing_Language.pptx](http://knowledge.exlibrisgroup.com/@api/deki/files/27349/Writing_Expand_Routines_in_any_Programing_Language.pptx)) 


e) `$data_tab/osu_facets file`, Part II – definition of facets

     !1  2      3 4
     !!!-!!!!!!-!-!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!... ...
     AUT -47    F cze=Autoři;eng=Authors
     SUB -27    F cze=Předměty;eng=Subjects
     FGN a      F cze=Žánr;eng=Genre
     FLN a      F cze=Jazyk;eng=Language
     FYR a      D cze=Rok;eng=Year
     FAD a      F cze=Uživatelské určení;eng=Audience

## II. Scripts and configuration of front-end process – displaying facets in OPAC

The process and implementation of the service for end users consists of modified ALEPH OPAC html templates for short-results view, which must have    
a) new hidden elements for loading current set number and amount of recs. found,    
b) load of external facets.js script and    
c) new element for displaying facets.    
The `facets.js` gathers the Set No. and No.of recs. and calls cgi script `facets.cgi` using AJAX. This cgi script in CSH is just a simple redirection, which calls Perl script `facets.pl` with two arguments (set no., no. of recs.). The Perl script retrieves doc. numbers of the current search set calling X-server API op=present. Knowing these doc numbers, the script retrieves the relevant facet values as acc headings from Oracle z01, z02 tables in the BIB base, using the setting in osu_facets configuration file. The data are formatted in XML and returned to client, where they are processed again by `facets.js` and displayed.

###II.1. Perl script facets.pl
Create a directory `./facets` somewhere in your ALEPH filesystem accessible fully by your Aleph Linux user, where you are used to place your own extensions, additions or so. Make a subdirectory under it: `./facets/tmp` , which is used for temporary storing of facets for each search set to avoid repeated redundant calling API and database. This `./tmp` directory is regularly cleared by the Perl script. Simply said do:      

     cd {{dir_upon_your_decision}}
     mkdir facets
     mkdir facets/tmp
Take/download the file `facets.pl` and save it in this `…/facets` directory.
Edit the file `facets.pl` and replace the line 19 – definition of variable `$configFile`     

     my $configFile='/exlibris/aleph/u2X_X/xxx01/tab/osu_facets';

to real full path of your BIB tab directory.   

Now, you should also check if all needed modules of Perl are installed. Try to run following commands in Linux commandline:     

     $aleph_product/local/perl/bin/perldoc -l XML::XPath 
     $aleph_product/local/perl/bin/perldoc -l DBI
     $aleph_product/local/perl/bin/perldoc -l LWP
     $aleph_product/local/perl/bin/perldoc -l POSIX 

All these command should return a path and filename for the particular module.
If you meet the response: _No documentation found for "…"_, this Perl module is missing in your system and must be added.

###II.2. CGI script facets.js
This needs enabled settings of CGI execution in your Apache. If you do not use CGI or not sure, check your `$httpd_root/conf/httpd.conf` file. This Apache config should contain the following lines, when u2X_X is changed to real version and instance of the ALEPH.

     ScriptAlias /cgi-bin/ "/exlibris/aleph/u2X_X/alephe/apache/cgi-bin/"
         <Directory "/exlibris/aleph/u2X_X/alephe/apache/cgi-bin">
             AllowOverride None
             Options None
             Order allow,deny
             Allow from all
         </Directory>
If you do not find these lines in the httpd.conf file, add them and restart Apache. Of course, you may also use another directory for cgi scripts up to your settings. The script was also tested on uncgi frontend for processing queries (see [http://www.midwinter.com/~koreth/uncgi.html](http://www.midwinter.com/~koreth/uncgi.html)).   

Take/download the script `facets.cgi` and save it to the directory set for CGI usage. This may be, according to settings above, the dir: `/exlibris/aleph/u2X_X/alephe/apache/cgi-bin` or simply `$httpd_root/cgi-bin`

Makes this script executable   

     chmod +x facets.cgi

Edit the file `facets.cgi` and set two variables on lines 3 and 4:    

     set facets_dir="{{some_dir_upon_to_your_decision}}/facets/"   -  this is directory where you have saved the facets.pl Perl 
     perl_location="/exlibris/aleph/a2X_X/product/local/perl/bin/perl"   - this is path to Perl used for execution of the Perl script. If you use ALEPH distribution of Perl, just modify the path here to version and instance of your system (a20_1, a22_2 etc.).

###II.3. Javascript facets.js
Make a directory `./facets` in your “htdocs” directory     

     mkdir $httpd_root/htdocs/facets
Take/download the file `facets.js` and save it to this dir.
Of course, you can also use other directories defined in Apache, like directly $httpd_root/htdocs/ , but change this path also in OPAC templates, when the script is called.

###II.4  OPAC html templates stored in $alephe_root/www_f_{{lng}} directory
Note that if you use more bases in OPAC (including authority or external Z39.50 bases), you should make this settings in files defined for the desired BIB base only, so with suffix of this base (like “-xxx01”), or have/make this specific base based setting for templates for all other used bases.

**II.4.1. Files/templates short-1-head and short-2-head**   
In both files, anywhere in the body section of the file (might at the end) insert the following two lines:     

     <span id="getSearchSet4facets" style="display:none;">$2200</span>
     <span id="getNoOfRecs4facets" style="display:none;">$0300</span>
These are two hidden html elements that store Search Set Number and Number of Records Found from ALEPH placeholders. They are used later by facet methods in `facet.js`   

**II.4.2. File/template short-tail**
Somewhere at the end (might before “<include> copyrights”) insert the following lines     

     <script type="text/javascript" src="/facets/facets.js"></script> <!--set the path to the javascript file-->
     <script type="text/javascript">
        var facets=facets || new Object();
        facets.serverSideScriptPath='/cgi-bin/facets.cgi' //set URL path to the cgi script according to your situation
        facets.noOfRecs = Number( ( (document.getElementById('getNoOfRecs4facets') || document.createElement('span')).innerHTML.match(/[0-9]+/) || '0')[0] ); //the element 'getNoOfRecs4facets' in short-2-head opac template should contain placheolder $0300, which stands for amount of records found
        facets.lang = 'eng' //language code according to {{dollar}}data_tab/osu_facets settings. Use different values in different www_f_{{lng}} directories
        facets.targetElementID = 'facets' //id attribute of html element, where facet should be displayed
        facets.serverFurl = '&server_f'.replace(/http[s]*:/, window.location.protocol);
        facets.ask();
     </script>

This is loading of external facets.js script, setting some values and calling the facet methods.
Two of these newly added lines also need adjustment to your local environment. These to be modified are:    

     facets.serverSideScriptPath='/cgi-bin/facets.cgi' //set URL path to the cgi script according to your situation
     facets.lang = 'eng' //language code according to {{dollar}}data_tab/osu_facets settings. Use different values in different www_f_{{lng}} directories

**II.4.3  Add a new html element** with attribute id=”facets” to some of the short-results OPAC templates. Like    

     <div id=”facets”></div>
It will be used for displaying facets after their getting through AJAX and processing.
Still, the definition of the html element for displaying facets might be more sophisticated, due to definition of CSS, floating or reserving space before AJAX loading. Cf. the following chapter for II.4.3.1. for possible setting this tested at University of Ostrava.

**II.4.3.1. Possible setting of html element for displaying facets.**
Using this example, facets are added to the right side of the table with short-results (and other page contents after the table till “copyright” section. Until facets are loaded through AJAX and shown, a free space is left of the place to avoid “dancing” of web page after loading. If the browser window has lesser width than 980 pixels, loading and displaying facets is suppressed.  
The table with short-results and other contents after it must be inserted to a new div element with id=”main_contents” for proper setting of element floating. Cf. live version at [http://aleph.osu.cz](http://aleph.osu.cz)

a] File/template `short-include-2`
Before the table with navigation through results (Records of…, Jump to, Next Page, Previous Page), i,e, before default code lines:   

      <table border=0 width=100%>
      <tr>
       <td class=text3 id=bold width=20% nowrap>
          Records $0100 -$0200 of $0300 (maximum display and sort is $4500 records)
       </td>

insert a start of the main content div:     

     <div id="main_content"><!--used for facets display and floating-->

b] File/template `short-tail`
Before the line     

     <include>copyrights

insert the following code:     

     </div>
     <div id="facets">&nbsp;<!--this space is required for reserving space on page before loading AJAX, do not remove--><h2 style="display: none; white-space: nowrap;">Filter results: <img src="&icon_path/close2.png" style="height: 15px; cursor: pointer;" alt="(X)" title="Hide this selection of filters" onmouseover="this.border='1px';" onmouseout="this.border='0';" onclick="document.getElementById( facets.targetElementID ).innerHTML=''; (document.getElementById('main_content') || document.createElement('span')).style.width='100%';"/></h2></div>
      
     <script type="text/javascript" src="/facets/facets.js"></script> <!--set the path to the javascript file-->
     <script type="text/javascript">
        var facets=facets || new Object();
        facets.serverSideScriptPath='/cgi-bin/uncgi/facets.cgi' //set url path to the cgi script accroding to your situation
        facets.noOfRecs = Number( ( (document.getElementById('getNoOfRecs4facets') || document.createElement('span')).innerHTML.match(/[0-9]+/) || '0')[0] ); //the element 'getNoOfRecs4facets' in short-2-head opac template should contain placheolder $0300, which stands for amount of records found
        facets.lang = 'eng' //language code according to {{dollar}}data_tab/osu_facets settings. Use different values in different www_f_{{lng}} directories
        facets.targetElementID = 'facets' //id attribute of html element, where facet should be displayed
        facets.serverFurl = '&server_f'.replace(/http[s]*:/, window.location.protocol);  //suppress display of facets for devices with width less 980px
        if ( window.innerWidth >=980 || document.documentElement.offsetWidth >= 980 ) { facets.ask(); }
        else { document.getElementById( 'main_content' || document.createElement('span') ).style.width='100%'; }
     </script>

This code consists of closing div tag for the ```id=”main_content”``` element; div for facets. This div has a h2 heading, which is hidden primarily and displayed not until facet values are loaded. A small image with cross ```close2.php``` is added after this heading text. You may use any image with cross as a symbol closing for this and save it in ```www_f_{{lng}}/icon``` directory. Clicking this cross makes hiding the facet div and extension of the “main_content” to whole window width.   
Simple `facets.ask();` at the end of the script is replaced here by condition check of browser window width and suppression of facet displaying in too narrow windows/displays. The minimal window width is set to 980 pixels here. Note that this min. width may change its ideal values according to local setting of contents and columns in the short-table with results. Tested browsers do not want to narrow tables together with window ad infinitum, but at certain level that would cause nasty text breaking stop the table narrowing and hide a part of it using horizontal ruler for navigation. You should test the ideal value according to local settings.   

 c] CSS in the `$httpd_root/htdocs/exlibris.css` (or any other CSS definition if you use such), add the following definition for “main_content” and “facets” elements.     

     * { box-sizing: border-box; }
     #main_content { width: 85%; float: left; margin-right: 1eM; overflow: hidden;}
     #facets {  font-size: 70%;}
     #facets::after {content:''; display:block; clear:both; }

##Known issues
Retrieving of facet values for each search set is very slow, it usually takes several seconds until these are displayed in OPAC. Replacing the present querying X-server for getting doc numbers of the current search set might be possibly replaced by select to database, vir01 user, table with search set results used commonly by OPAC.
