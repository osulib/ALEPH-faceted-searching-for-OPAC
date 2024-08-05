use strict; use warnings;
use XML::XPath;
use DBI;
use LWP;
use POSIX;
binmode(STDOUT, ":utf8");
binmode(STDIN, ":utf8");
$ENV{NLS_LANG} = 'AMERICAN_AMERICA.AL32UTF8';

#retrieves facets accrding to given search set
#script command line arguments:
#   1 - search set number (mandatory)
#   2 - no. of records found (required for repeated calling of x-server present function)


#read config. file
#SET THIS VALUE FIRST - FULL PATH AND NAME OF THE CONFIGURATION FILE FOR FACETS
#It is recommended to save it in $data_tab of the BIB base, yet must be determined in full path here.
my $configFile='/exlibris/aleph/u22_1/osu01/tab/osu_facets'; 





my $tmpDir='./tmp'; #this dir. is used for storing files with results - these are taken when user lists through results in OPAC, instead of repeated queting API and database.


unless (open ( FILESET,  "<:encoding(UTF-8)", "$configFile" ) ) { run_exemption("Configuration file $configFile cannot be opened for reading. Exiting.."); }
my $settings={};
my @facetCodes;
my %facetSubfields=();
my %facetSort=();
my %facetNames=();
while( <FILESET> ) {  
   my $setLine = $_;
   $setLine =~ s/^\s+|\s+$//g; #trim
   next if ( substr($setLine,0,1) eq '!' );
   if ( substr($setLine,0,1) eq '@' ) { #general settings
      my $setName=substr($setLine,2,12); $setName=~ s/^\s+|\s+$//g;
      my $setValue=substr($setLine,15); $setValue=~ s/^\s+|\s+$//g;
      $settings->{$setName} = $setValue;
      }
   else {
      my $fn=substr($setLine,0,3);
      if ( $fn =~ /\w{3}/ ) { 
         push ( @facetCodes, $fn ); 
         $facetSubfields{$fn} = substr($setLine,4,6);
         $facetSubfields{$fn} =~ s/^\s+|\s+$//g; #trim
         $facetSort{$fn} = substr($setLine,11,1);
         $facetNames{$fn} = substr($setLine,13)
         }
      } 
   }


#check and parse command line arguments
if ( ($#ARGV + 1) != 2 ) { run_exemption('The script needs two command line arguments: 1. search set, 2. no. of records found.Exiting...');}
my $searchSet=$ARGV[0];
my $noOfRecs=$ARGV[1];
##unless ( isdigit($noOfRecs) ) { run_exemption('The 2nd command line argument standing for no. of records found must be a number (integer). Exiting...');}
   unless ( $noOfRecs =~ m/^\d+$/ ) { run_exemption('The 2nd command line argument standing for no. of records found must be a number (integer). Exiting...');}


our ( $bibBase, $bibBasePassword, $sid, $admin_mail, $alephe_scratch );
unless ( exists $settings->{'bibBase'} && exists $settings->{'bibBasePsswd'} && exists $settings->{'oracleSID'} && exists $settings->{'oracleHost'} && exists $settings->{'xServerURL'} ) {
   run_exemption ('Some of the following parameters is/are missing in the config. table: bibBase, bibBasePsswd, oracleSID, oracleHost, xServerURL'); }
$sid = 'dbi:Oracle:host='.$settings->{'oracleHost'}.';sid='.$settings->{'oracleSID'};




#check tmp file - if facets has not been alreadz retreived for the search set 
if ( open ( my $tmpFile, "<:encoding(UTF-8)", "$tmpDir/facetSet$searchSet.xml" ) ) {
   while (my $row = <$tmpFile>) {
      chomp $row;
      print "$row\n";
      }
   close ($tmpFile);
   }
else {   

   #retrieve result records from search set. Present API response can include max. 100 recs., so calling it is divided to more https than
   my @resultSet;
   for ( my $i=0; $i < $noOfRecs; $i=$i+100 ) {
      if ( $i > $noOfRecs ) { $i=$noOfRecs; }
      my $presentRequest = LWP::UserAgent->new;
      my $presentGet = $presentRequest->get( 'http://'.$settings->{'xServerURL'}.'/X?op=present&set_number='.$searchSet.'&set_entry='.($i+1).'-'.( ($i+100) > $noOfRecs ?  $noOfRecs : ($i+100) ) );
      unless ( $presentGet->is_success ) { run_exemption('x-server has no response'); }
      my $presentx = $presentGet->content;
      my $xp = XML::XPath->new(xml => $presentx);
      my $nodeset = $xp->find("/present/record/doc_number");
      foreach my $node ($nodeset->get_nodelist) { 
         push (@resultSet, $node->string_value);
         }
      }
   
   # more than 1000 recs must be separated to 2 sql in operators. More than 2000 recs. excluded from procession
   my $resultSetLength = ( scalar @resultSet ) -1;
   my $sqlInDocs;
   if ( $resultSetLength > 2000 ) {  run_exemption('Sorry, facets cannot be searched for more than 2000 results. It would be horribly slow.'); }
   elsif (  $resultSetLength > 1000) { 
      $sqlInDocs = "( z02_doc_number in ('".join("','",@resultSet[0..999]). "') or z02_doc_number in ('".join("','",@resultSet[1000..$resultSetLength])."') )";   }
   else { 
      $sqlInDocs = "z02_doc_number in ('".join("','",@resultSet)."')"; }
   my $sqlInFacets="substr(z01_rec_key,1,3) in ('".join("','",@facetCodes)."')";
   my $dbh = DBI->connect($sid, $settings->{'bibBase'} ,$settings->{'bibBasePsswd'} ) or run_exemption ("ERROR couldn't connect to database with ".$bibBase."\n".$DBI::errstr);
   my $sth = $dbh->prepare("select substr(z01_rec_key,1,3) type, z01_display_text, count(*) counts from z01,z02 where Z01_ACC_SEQUENCE=substr(z02_rec_key,1,9) and $sqlInDocs and $sqlInFacets group by substr(z01_rec_key,1,3), z01_display_text order by 1 asc, 3 desc, 2 asc");
   $sth->execute or run_exemption ("ERROR in sql select from aleph acc headings tables (z01,z02) : ".$DBI::errstr);
   

   my $facetType="";
   unless ( open ( $tmpFile, ">:encoding(UTF-8)", "$tmpDir/facetSet$searchSet.xml" ) ) { run_exemption ('TMP file '."$tmpDir/facetSet$searchSet.xml".' cannot be opened! Might the dir ./tmp does not exist?'); }
   #convert sql results to hashref (this will be used for sorting facet types)
   my $results={};
   while(  my $ref = $sth->fetchrow_hashref() ) {
      my $facetType=$ref->{TYPE};
      my $facetValue = xml_encode( $ref->{'Z01_DISPLAY_TEXT'} );
      if ( substr( $facetSubfields{$facetType}, 0, 1 ) eq '-' ) { #exclude these subfields
         my $subfields=$facetSubfields{$facetType};
         my @ar = $facetValue =~ /(\$\$[^ $subfields ].+?(?=\$\$|$))/g;
         $facetValue = join ('',@ar);
         }
      elsif ( $facetSubfields{$facetType} ne '' ) { #include these subfields only
         my $subfields=$facetSubfields{$facetType};
         my @ar = $facetValue =~ /(\$\$[ $subfields ].+?(?=\$\$|$))/g;
         $facetValue = join ('',@ar);
         }
      $facetValue =~ s/\$\$./ /g; #remove ALEPH subfield codes
      $facetValue=~s/^\s+|\s+$//g; #trim
      unless ( exists $results->{$facetType} ) { $results->{$facetType}=''; }
      {$results->{$facetType} .= '<value count="'.$ref->{COUNTS}.'">'.$facetValue."</value>"; }
      }
   #print resutls
   print "<facetsResults>\n";   print $tmpFile "<facetsResults>\n";

   #response - part 1 containg settings
   print "<settings><viewLinesTotal>".$settings->{'linesTotal'}."</viewLinesTotal><viewLinesImmediate>".$settings->{linesImmed}."</viewLinesImmediate>".displayTextsLang('textShowMore',$settings->{showMore}).displayTextsLang('textCancelFilter',$settings->{cancelFilter})."</settings>\n";
   print $tmpFile "<settings><viewLinesImmediate>".$settings->{linesImmed}."</viewLinesImmediate>".displayTextsLang('textShowMore',$settings->{showMore}).displayTextsLang('textCancelFilter',$settings->{cancelFilter})."</settings>\n";

   #response - part 2 containg facet values
   foreach ( @facetCodes ) {
      my $f=$_;
      next unless ( $results->{$f} );
      my $linesCount = () = $results->{$f} =~ /<value/g;  #not display facets with just 1 line/result
      next if ( $linesCount<2 );
      print '<facet type="'.$f.'" name="'.$facetNames{$f}.'" sort="'.$facetSort{$f}.'">'."\n";
      print $tmpFile '<facet type="'.$f.'" name="'.$facetNames{$f}.'" sort="'.$facetSort{$f}.'">'."\n";
      print $results->{$f}."\n";
      print $tmpFile $results->{$f}."\n";
      print "</facet>\n";
      print $tmpFile "</facet>\n";
      } 
   print "</facetsResults>\n";
   print $tmpFile "</facetsResults>\n";
   close ($tmpFile);
   }

exec ("find $tmpDir/facetSet* -mtime +1 -delete"); #delete old tmp files


sub run_exemption {
   my $error_message = $_[0];
   print "<facetsResults><error>$error_message</error></facetsResults>\n";
   exit 0;
   }

sub xml_encode {
   my ($x)=@_;
   return '' if ($x eq '');
   $x=~s/"/&quot;/g; $x=~s/&/&amp;/g; $x=~s/'/&apos;/g; $x=~s/</&lt;/g; $x=~s/>/&gt;/g; 
   return $x;
   }

#change texts to display from osu_facets settings to xml output
sub displayTextsLang {
   my ($type,$x)=@_;
   return 0 if ( $x eq '');
   my $res='';
   my @a = split(/\s*;\s*/,$x);
   foreach (@a) {
      my $lang=$_;
      my $text=$lang;
      $lang =~ s/\s*=.*$//; $lang=xml_encode(lc($lang));
      $text =~ s/^[^=]+=\s*//; 
      $res .= "<$type lang=\"$lang\">".xml_encode( lc($text) )."</$type>";
      }
   return $res;
   }
