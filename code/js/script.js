/*
 * This file contains general scripts for the TCCD Website content.
 */
 
window.addEventListener('load', setupPage);
 
/* The setupPage function runs on page load, and adds all the
 * interactive features that depend on the presence of script 
 * support. */
function setupPage(){
  var i, targ;
  var appendixLinks = document.querySelectorAll('a[href^="#"]');
  for (i=0; i< appendixLinks.length; i++){
      targ = appendixLinks[i].getAttribute('href').substring(1);
      appendixLinks[i].href = 'javascript:showInfo(\'' + targ + '\')';
  }
}
 
/* If scripting is active, we display appendix information in 
 * a popup next to the text. */
 /* Code for showing references, biblios etc. in a popup div. */
var infoPopup = null;
var infoContent = null;

function showInfo(sourceId) {
//Make sure we have an available popup element.
  infoPopup = document.getElementById('infoPopup');
  infoContent = document.getElementById('infoContent');
  if ((infoPopup == null) ||(infoContent == null)) {
    return;
  }
  
//Make sure we have a source element
  var sourceEl = document.getElementById(sourceId);
  if (sourceEl == null) {
    return;
  }
  
  //Copy the content from the source to the popup
  infoContent.innerHTML = sourceEl.innerHTML;
  
  //Show the popup
  infoPopup.style.display = 'block';
}