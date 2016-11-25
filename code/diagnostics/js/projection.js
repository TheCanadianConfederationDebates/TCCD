/* Quick-and-dirty JS lib for determining whether we have any chance of completing our goals. */

/* stats object contains parsed JSON from diagnostics process. */
var stats = null;

/* Loading the object. */
function getStats(){
  var xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function(){
    if (xhr.readyState === XMLHttpRequest.DONE){
      stats = JSON.parse(xhr.responseText);
      doProjection();
    }
  };
  xhr.open('GET', 'metadiagnostics.json');
  xhr.send();
}

window.addEventListener('load', getStats);

function doProjection(){
  var proj = new projectionObj(stats);
}

function projectionObj(stats){
  this.stats = stats;
}