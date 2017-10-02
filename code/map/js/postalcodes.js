"use strict";
 
/**
 * @fileOverview Functions for handling postal code navigation.
 *               These depend on the existence of a global object 
 *               "map", which is an OpenLayers 4 map, and on some
 *               functions in utilities.js.
 * @author <a href="mailto:mholmes@uvic.ca">Martin Holmes</a>
 * @version 0.1.0
*/
 

/** 
 * @function checkPostalCode
 * @description Provided with a Canadian postal code, this function
 *              first cleans it up and checks whether it's valid; if
 *              not, it shows an error message and returns false.
 *              If valid, it navigates the map to that location, and
 *              returns true. 
 * @param {string} postalCode The user-supplied postal code.
 * @returns {boolean}
 */ 
function jumpToPostalCode(postalCode){
    var i, maxi, first, three, jsonUri, cleanCode, feat, coords, point, mapSize;
    cleanCode = postalCode.replace(/[\s\.,:;]+/g, '').toUpperCase();
    console.log('Cleaned up: ' + cleanCode);
    if (!(cleanCode.match(/^[A-Z]\d[A-Z]\d[A-Z]\d$/))){
        alert('Your postal code is not correct. Please enter it in the form A9A9A9.');
        return false;
    }
    else{
        first = cleanCode.substring(0, 1);
        three = cleanCode.substring(0, 3);
        jsonUri = 'js/postalcodes/' + first + '/' + three + '.json';
        ajaxRetrieve(jsonUri, 'json').then(function(response){
            for (i=0, maxi=response.features.length; i<maxi; i++){
                if (response.features[i].properties.ZIP === cleanCode){
                    return addPostalCodeFeatureAndJump(response.features[i]);
                }
            }
            console.log('Exact match not found. Looking for nearest match.');
            if (findNearestPostalCode(cleanCode, response.features, 5) === false){   
                alert('The postal code ' + cleanCode + ' was not found. Please try a nearby one.');
                return false;
            }
            return true;
        }, function(Error){
            console.log(Error);
            alert('The postal code ' + cleanCode + ' was not found. Please try a nearby one.');
            return false;
        })
    }
}

/** 
 * @function addPostalCodeFeatureAndJump
 * @description Provided with a feature in JSON format, this function
 *              creates a new feature on the vector layer for postal
 *              codes, then gets the map to jump to it. Returns true
 *              for success and false for failure.
 * @param {object} postalCodeFeature The JSON-derived feature object.
 * @returns {boolean}
 */ 
function addPostalCodeFeatureAndJump(postalCodeFeature){
    var coords, point, feat;
    try{
       coords = postalCodeFeature.geometry.coordinates;
       point = new ol.geom.Point(ol.proj.fromLonLat(coords));
       feat = new ol.Feature(point);
       feat.set('id', postalCodeFeature.properties.ZIP);
       srcPostalCodes.addFeature(feat);
       map.getView().animate({
           center: ol.proj.fromLonLat(coords),
           zoom: 8,
           duration: 2000
       });
       return true;
    }
    catch(e){
       console.error(e.message);
       return false;
    }
}

/** 
 * @function findNearestPostalCode
 * @description Provided with a missing postal code and a feature collection
 *              in JSON format, this recursive function tries to match
 *              the code to the features in the collection based on substring
 *              matches. If it fails to match on four letters, it defaults to
 *              using the first code in the collection. The function then 
 *              calls addPostalCodeFeatureAndJump to send the map there.
 * @param {string} postalCode The missing postal code
 * @param {object} featureColl The feature collection to search
 * @param {number} len The number of initial letters/digits to search.
 * @returns {boolean}
 */
function findNearestPostalCode(postalCode, featureColl, len){
    var i, maxi, reCode;
    try{
       if (length <= 3){
          return addPostalCodeFeatureAndJump(featureColl[0]);
       }
       else{
          reCode = new RegExp('^' + postalCode.substring(0, len));
          console.log(reCode);
          for (i=0, maxi=featureColl.length; i<maxi; i++){
              if (featureColl[i].properties.ZIP.match(reCode)){
                  return addPostalCodeFeatureAndJump(featureColl[i]);
              }
          }
          findNearestPostalCode(postalCode, featureColl, len-1);
       }
       return false;
    }
    catch(e){
       console.error(e.message);
       return false;
    }
}
