/* The purpose of this file, intended to be run at the command line 
   using nodejs, is to take as input a large GeoJSON file containing 
   polygons for all the postal codes in Canada, and output a modified
   file in which all the polygons have been converted to points. */
   
/* The reasons for doing this are twofold:
   1. The file with polygons is huge.
   2. The polygons themselves are of dubious value, and in many 
      cases represent not much more than a point or line.
   */
   
var fs = require('fs');

//NPM package which does the gnarly work.
var polygonCenter = require('geojson-polygon-center')

//The file to process.
var inFile = process.argv[2];

//Where the results are saved.
var outFile = inFile.replace('\.json', '_points.json');

//Convenient function for writing output.
function writeLine(txt){
  process.stdout.write(txt + '\u000a');
}

writeLine('Processing this file:');
writeLine('  ' + inFile);
writeLine('to produce this file:');
writeLine('  ' + outFile);

var geoObj = JSON.parse(fs.readFileSync(inFile, 'utf8'));

writeLine('The input file contains ' + geoObj.features.length + ' features.');

for (var i=0; i<geoObj.features.length; i++){
  writeLine('...processing feature # ' + i);
  geoObj.features[i].geometry = polygonCenter(geoObj.features[i].geometry);
}

writeLine('Writing output file...');

fs.writeFile(outFile, JSON.stringify(geoObj), function(err){if (err){}return console.error(err);});

writeLine('Done!');

