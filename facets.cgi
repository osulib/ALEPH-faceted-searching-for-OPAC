#!/bin/csh -f
#SET THIS AES VARIABLE FIRST !
set facets_dir="{{some_dir_upon_to_your_decision}}/facets/" #directory where facets.pl  perl scripts is stored
set perl_location="/exlibris/aleph/a2X_X/product/local/perl/bin/perl" #path and file to Aleph Perl. We recommend using Perl distributed with Aleph.
###


echo 'Content-type: text/xml; charset=utf-8'
echo ''
echo '<?xml version="1.0" encoding="utf-8"?>'
cd $facets_dir
$perl_location facets.pl "$WWW_searchset" "$WWW_noofrecs"
