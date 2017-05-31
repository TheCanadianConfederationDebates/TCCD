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
    //console.log('Cleaned up: ' + cleanCode);
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
                    console.log(response.features[i]);
                    coords = response.features[i].geometry.coordinates;
                    point = new ol.geom.Point(ol.proj.fromLonLat(coords));
                    feat = new ol.Feature(point);
                    feat.set('id', response.features[i].properties.ZIP);
                    
                    //alert(response.features[i].geometry.coordinates);
                    srcPostalCodes.addFeature(feat);
                    //point = (feat.getGeometry());
                    //mapSize = (map.getSize());
                    //map.getView().fit(point.getCoordinates(), {size: mapSize});
                    //map.getView().setCenter(point.getCoordinates());
                    //map.getView().setCenter(ol.proj.fromLonLat(coords));
                    //map.render();
                    //map.getView().setZoom(8);
                    map.getView().animate({
                        center: ol.proj.fromLonLat(coords),
                        zoom: 8,
                        duration: 2000
                    });
                    return true;
                }
            }
            console.log(srcPostalCodes.getFeatures().length);
        }, function(Error){
            console.log(Error);
        })
    }
}
