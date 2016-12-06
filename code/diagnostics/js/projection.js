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

/* Object which parses the stats data and does calculations 
 * and projections.
 * */
function projectionObj(stats){
  var strDate = '', i = 0, d = null, h2 = null, ul = null;
  this.diag = stats.diagnostics;
  
/* First we turn all the dates into actual dates. */
  for (i=0; i<this.diag.length; i++){
    strDate = this.diag[i].date.split('-');
    this.diag[i].date = new Date(parseInt(strDate[0]), parseInt(strDate[1])-1, parseInt(strDate[2]));
  }
  
/* Now our overall ranges. */
  this.startDate = this.diag[0].date;
  this.latestDate = this.diag[this.diag.length-1].date;
  this.endDate = new Date(2017, 6, 1);
  this.timeLeft = this.endDate - this.latestDate;
  this.elapsedTime = this.latestDate - this.startDate;
  
/* Our target page-count, based on the raw pages in the repo. */
  this.rawPageCount = this.diag[this.diag.length-1].hocr_orig;
  
/* A quick readout of names tagged so far. */
  d = document.createElement('div');
  d.setAttribute('class', 'projections');
  h2=document.createElement('h2')
  h2.appendChild(document.createTextNode('Total names tagged so far: ' + this.diag[this.diag.length-1]['names_tagged']));
  d.appendChild(h2);
  document.getElementsByTagName('body')[0].appendChild(d);
  
  d = document.createElement('div');
  d.setAttribute('class', 'projections');
  h2=document.createElement('h2')
  h2.appendChild(document.createTextNode('Problematic "unspecified" names: ' + this.diag[this.diag.length-1]['unspecified_names_tagged']));
  d.appendChild(h2);
  document.getElementsByTagName('body')[0].appendChild(d);
  
/* Now we figure out projections for each of the data types
 * we care about. */

  d = document.createElement('div');
  d.setAttribute('class', 'projections');
  h2=document.createElement('h2')
  h2.appendChild(document.createTextNode('Projected completion dates'));
  d.appendChild(h2);
  
  ul = document.createElement('ul');
  d.appendChild(ul);
  
  ul.appendChild(this.createPara('hocr_edited', 'edited HOCR pages'));
  ul.appendChild(this.createPara('tei_pages', 'pages in TEI'));
  ul.appendChild(this.createPara('nametagged_pages', 'fully-name-tagged pages in TEI'));
 
  document.getElementsByTagName('body')[0].appendChild(d);
}

/* Member function which calculates the projected finish 
 * date for a specific document type. */
function projectionObjCalcFinishDate(id){
  var doneSoFar, leftToDo, rateSoFar, timeToComplete, projectedFinish;
  doneSoFar = this.diag[this.diag.length-1][id];
  leftToDo = this.rawPageCount - doneSoFar;
  rateSoFar = doneSoFar / this.elapsedTime;
  timeToComplete = Math.round(leftToDo / rateSoFar);
  projectedFinish = this.latestDate.valueOf() + timeToComplete;
  return new Date(projectedFinish);
}

projectionObj.prototype.calcFinishDate = projectionObjCalcFinishDate;

/* Member function to generate a paragraph with a projection in it. */
function projectionObjCreatePara(id, caption){
  var li = null, t = null, endDate = null;
  endDate = this.calcFinishDate(id);
  li = document.createElement('li');
  t = document.createTextNode(caption + ': ' + endDate.toLocaleDateString('en-ca'));
  li.appendChild(t);
  return li;
}

projectionObj.prototype.createPara = projectionObjCreatePara;
