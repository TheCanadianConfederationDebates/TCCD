/* The purpose of this file, intended to be run at the command line 
   using nodejs, is to take as input a large GeoJSON file containing 
   points for all the postal codes in Canada, and output a large number
   of much smaller files in a specific folder structure. Each output 
   file will contain all the postal codes beginning with a specific 
   alphanumeric sequence. */
   
/* The reason for doing this is that the file with points is much too 
   large to use for AJAX live operation.   */
   
var fs = require('fs');

//The file to process.
var inFile = process.argv[2];

//Convenient function for writing output.
function writeLine(txt){
  process.stdout.write(txt + '\u000a');
}


writeLine('Processing this file:');
writeLine('  ' + inFile);

var geoObj = JSON.parse(fs.readFileSync(inFile, 'utf8'));

//We might as well predict the first three alphanumerics.
var az = [];

for (var i = 65; i <= 90; i++) {
  az[i-65] = String.fromCharCode(i);
}

var strNums = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

for (var a1=0; a1<26; a1++){
  for (var n=0; n<10; n++){
    for (var a2=0; a2<26; a2++){
      var prefix = az[a1] + strNums[n] + az[a2];
      writeLine('Processing ' + prefix + '...');
      
/* Create a basic JS object to which we can add any features that fall into 
   this prefix. */
      var prefObj = JSON.parse('{"type": "FeatureCollection", "crs": { "type": "name", "properties": { "name": "urn:ogc:def:crs:OGC:1.3:CRS84" } },"features": []}');
      
      for (var f=0; f<geoObj.features.length; f++){
        if (geoObj.features[f].properties.ZIP.substring(0,3) === prefix){
          prefObj.features.push(geoObj.features[f]);
        }
      }
      if (prefObj.features.length > 0){
        if (!fs.existsSync(az[a1])){
          fs.mkdirSync(az[a1]);
        }
        var outFile = az[a1] + '/' + prefix + '.json';
        fs.writeFileSync(outFile, JSON.stringify(prefObj));
      }
    }
  }
}

writeLine('Done!');

