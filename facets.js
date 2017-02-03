var facets = facets || new Object();
facets.ask = function () {
   if (typeof facets.serverSideScriptPath === 'undefined') {console.error ('Facets - the value facets.serverSideScriptPath standing for path to cgi script has not been set.'); return; }
   if (typeof XMLHttpRequest === "undefined") {console.warn('Your browser does not support object XMLHttpRequest, I cannot call Facets'); return; }
   var getSearchSet4facets =  ( ( ( document.getElementById('getSearchSet4facets') || document.createElement('span') ).innerHTML.match(/set_number=[0-9]+/) ) || []);
   facets.searchSet = Number( ( getSearchSet4facets.length>0 ? getSearchSet4facets[0] : '' ).replace('set_number=','') );
   if ( ! facets.searchSet ) { console.error ('Facets - html element with id="getSearchSet4facets" not found, or this el. does not contain placeholder $2200, or this placeholder does not contain URL with parametr "set_number" containg the current search set.'); return; }
   if ( typeof facets.noOfRecs === 'undefined' || ! facets.noOfRecs ) { console.error("Facets - value 'facets.noOfRecs' has not been set properly in short-2-head web template"); return; }
   if ( typeof facets.serverFurl === 'undefined' || ! facets.serverFurl ) { console.error("Facets - value 'facets.serverFurl' has not been set properly in short-2-head web template"); return; }
   xhr = new XMLHttpRequest();
   xhr.open('GET', facets.serverSideScriptPath+'?searchset='+facets.searchSet+'&noofrecs='+facets.noOfRecs, true); 
   xhr.send(null);
   xhr.onreadystatechange=function () {
      if (this.readyState==4 && this.status >= 200 && this.status < 400 ) { facets.show(this.responseXML); }
      }
   }
facets.show = function (res) {
   if ( res.getElementsByTagName('error').length > 0 ) { console.error ('Facets - ' + res.getElementsByTagName('error')[0].childNodes[0].nodeValue); return; }
   if ( res.getElementsByTagName('parsererror').length > 0 ) { console.error ('Facets - error parsing XML : ' + res.getElementsByTagName('parsererror')[0].childNodes[0].nodeValue); return; }
   if ( typeof facets.lang === 'undefined' ) { console.error ('Facets - value "facets.lang" in short-2-head opac template not set.'); return; }
   facets.lang=facets.lang.toLowerCase();
   facets.showLinesImmediatly=5;
   facets.showLinesTotal=25;
   if (  res.getElementsByTagName('viewLinesImmediate').length > 0 ) { facets.showLinesImmediatly=res.getElementsByTagName('viewLinesImmediate')[0].childNodes[0].nodeValue; }
   if (  res.getElementsByTagName('viewLinesTotal').length > 0 ) { facets.showLinesTotal=res.getElementsByTagName('viewLinesTotal')[0].childNodes[0].nodeValue; }
   facets.textShowMore='Show more';
   tsm=res.getElementsByTagName('textShowMore') || document.createElement('x');
   for (var i=0; i<tsm.length; i++) { if ( tsm[i].getAttribute('lang') == facets.lang ) { facets.textShowMore=tsm[i].childNodes[0].nodeValue; } }
   facets.textCancelFilter='Cancel filter';
   tcf=res.getElementsByTagName('textCancelFilter') || document.createElement('x');
   for (i=0; i<tsm.length; i++) { if ( tcf[i].getAttribute('lang') == facets.lang ) { facets.textCancelFilter=tcf[i].childNodes[0].nodeValue; } }
   if ( ! document.getElementById( (facets.targetElementID || '' ) ) ) { console.error('HTML element for displaying facets with attribut id=";'+facets.targetElementID+'" not found, or value facets.targetElementID has not been set in  in short-2-head opac template'); return; }

   targetEl=document.getElementById( facets.targetElementID );
   for (var i=0; i<targetEl.children.length; i++) {targetEl.children[i].style.display=''; }
   if ( window.location.href.match(/facets_orig_set=[0-9]+/) )  { //erase facet filter - show all results
      var ee = document.createElement('a');
      ee.appendChild ( document.createTextNode( facets.textCancelFilter ) ); 
      ee.setAttribute('href',facets.serverFurl+'?func=find-c&CCL_TERM=SET=' + window.location.href.match(/facets_orig_set=[0-9]+/)[0].match(/[0-9]+/)[0] );
      targetEl.appendChild(ee);	
      }
   var fSearchMade = decodeURIComponent( ( window.location.href.match(/facet_search=[^&]*/) || new Array(' ') )[0].replace('facet_search=','') );
   for ( var i=0; i<res.getElementsByTagName('facet').length ; i++ ) {
      var fs=res.getElementsByTagName('facet')[i];
      var fnr1=new RegExp( facets.lang+'\s*=[^;$]+'); var fnr2=new RegExp( facets.lang+'\s*=\s*');
      var fname= ( fs.getAttribute('name').match(fnr1) || [''])[0].replace(fnr2,'').replace(/^\s+|\s+$/g, '');
      var fcode= fs.getAttribute('type');
      var fsort= (fs.getAttribute('sort') || '');
      var fresults = new Array();
      for ( var j=0; j<fs.getElementsByTagName('value').length  ; j++ ) {
	 if ( fs.getElementsByTagName('value')[j].childNodes.length>0 ) {
	    fresults.push( [fs.getElementsByTagName('value')[j].childNodes[0].nodeValue, fs.getElementsByTagName('value')[j].getAttribute('count') ] );}
	 }
      if ( fsort=='A') { 
	 fresults.sort( function(a, b) { return a[0].localeCompare(b[0]); } ); 
	 }
      else if ( fsort=='D') { 
	 fresults.sort( function(a, b) { return a[0].localeCompare(b[0]); } ); 
	 fresults.reverse(); 
	 }
      var head=document.createElement('h3'); 
      head.appendChild( document.createTextNode(fname) );
      targetEl.appendChild(head);
      var ul=document.createElement('ul');
      for ( var j=0; j<fresults.length && j<facets.showLinesTotal ; j++ ) {
	 var li=document.createElement('li');
         if ( fresults[j][0] == fSearchMade ) { //this facet has been searched now
            li.innerHTML='<strong>'+fresults[j][0]+' ('+fresults[j][1]+')</strong>'; }
         else { li.innerHTML='<a href="'+facets.serverFurl+'?func=find-c&CCL_TERM=SET='+facets.searchSet+'%20and%20'+fcode+'=' + encodeURIComponent(fresults[j][0])+'&facets_orig_set='+facets.searchSet+'&facet_search='+encodeURIComponent(fresults[j][0])+'">'+fresults[j][0]+' ('+fresults[j][1]+')</a>'; }
         if ( (j+1)==facets.showLinesTotal ) { li.innerHTML = li.innerHTML+"<br>... ..."; }
	 if ( (j+1) > facets.showLinesImmediatly ) {
	    li.setAttribute('class','showMore'+fcode); li.style.display='none';
	    }
	 ul.appendChild(li);
	 }
      if ( fresults.length > facets.showLinesImmediatly ) {
	 var showMore=document.createElement('a'); showMore.setAttribute('style','text-align: center;'); showMore.appendChild ( document.createTextNode( facets.textShowMore ) );
         showMore.href='javascript: void();'; showMore.setAttribute('onclick','facets.showMore(\'showMore'+fcode+'\'); this.style.display=\'none\';' );
         ul.appendChild( showMore ); 
	 }
      targetEl.appendChild(ul)
      }
   }
facets.showMore=function(x) {
   var y=document.getElementById( facets.targetElementID ).getElementsByClassName(x);
   for (var i=0; i<y.length; i++) { y[i].style.display=''; }
   }
