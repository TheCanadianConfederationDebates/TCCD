/*
 * This file contains general scripts for the TCCD Website content.
 */
 
window.addEventListener('load', setupPage);
 
/* The setupPage function runs on page load, and adds all the
 * interactive features that depend on the presence of script 
 * support. */
function setupPage(){
  var i, targ, ss;
/* Check whether you're in the French symlinked folder and 
 * if so, hide English and show French. */
 var reFrench = /\/fr\//;
 if (reFrench.test(document.location)){
     ss = document.createElement('style');
     ss.setAttribute('type', 'text/css')
     ss.appendChild(document.createTextNode('body *[lang="fr"]{display: block;}\u000a'));
     ss.appendChild(document.createTextNode('body span[lang="fr"]{display: inline;}\u000a'));
     ss.appendChild(document.createTextNode('body *[lang="en"]{display: none;}\u000a'));
     document.getElementsByTagName('head')[0].appendChild(ss);
 }
  
/* Find all links to appendix items and turn them into popup
 * calls. */
  var appendixLinks = document.querySelectorAll('a[href^="#"]');
  for (i=0; i< appendixLinks.length; i++){
      targ = appendixLinks[i].getAttribute('href').substring(1);
      appendixLinks[i].href = 'javascript:showInfo(\'' + targ + '\')';
  }
}

/* This function switches from no language or any given language 
 * to the language passed in as a two-letter code (en or fr) by
 * changing the document location appropriately. */
function switchLang(toLang){
    var loc, locBits, pageName, re, newUrl;
    loc = document.location.toString();
    locBits = loc.split('/');
    pageName = locBits[locBits.length-1];
    re = new RegExp('\/((en)|(fr))\/' + pageName + '$');
    if (loc.match(re)){
        newUrl = loc.replace(re, '/' + toLang + '/' + pageName);
    }
    else{
        newUrl = loc.replace('/' + pageName, '/' + toLang + '/' + pageName);
    }
    document.location = newUrl;
}
 
/* If scripting is active, we display appendix information in 
 * a popup next to the text. */
 /* Code for showing references, biblios etc. in a popup div. */
var infoPopup = null;
var infoHeader = null;
var infoContent = null;


function showInfo(sourceId) {
//Make sure we have an available popup element.
  infoPopup = document.getElementById('infoPopup');
  infoHeader = document.getElementById('infoHeader');
  infoContent = document.getElementById('infoContent');
  
  if ((infoPopup == null) ||(infoContent == null) || (infoHeader == null)) {
    return;
  }
  
//Make sure we have a source element
  var sourceEl = document.getElementById(sourceId);
  if (sourceEl == null) {
    return;
  }
  
  //Copy the content from the source to the popup
  infoContent.innerHTML = sourceEl.innerHTML;
  
  //Show the portrait
  infoHeader.style.backgroundImage = 'url(../portraits/' + sourceId + '.jpg)';
  
  //Show the popup
  infoPopup.style.display = 'block';
}

function showHideEl(el){
    if (el != null){
        if (el.style.display != 'block'){
            el.style.display = 'block';
        }
        else{
            el.style.display = 'none';
        }
    }
}
