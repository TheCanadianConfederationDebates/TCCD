 

//Create a reliable path to the project root, for constructing URLs.
    //We need this because we may be in either the /en/ or /fr/ subfolders.
    //We may also be in a folder root, missing the filename.
    var projectRoot = location.href.replace(/((\/en\/)|(\/fr\/))/, '/').replace(/\/([^\.\/]+\.html)?(\?.*)*$/, '/');
    console.log(projectRoot);
    
    //Pointer to the currently selected feature, if there is one.
    var currFeat = null;
    
    //Create default style for riding points.
    var strokeRiding = new ol.style.Stroke({color: 'black', width: 2});
    var fillRiding = new ol.style.Fill({color: 'rgba(255, 204, 51, 0.5)'});
    /* Federal riding icon is offset to the left; provincial is offset to 
       the right; and treaty is centred. This is so that where two types
       of location have the same point, they don't appear on top of each
       other. */
    var iconFedRiding = new ol.style.Icon({
                                            src:    projectRoot + 'js/placemarkRed.png',
                                            anchor: [0,0.5],
                                            size:   [25,25]
                                          });
    //console.log(iconFedRiding.getSrc());
    var iconProvRiding = new ol.style.Icon({
                                            src:    projectRoot + 'js/placemarkBlue.png',
                                            anchor: [1,0.5],
                                            size:   [25,25]
                                          });
    var iconTreatyRiding = new ol.style.Icon({
                                            src:    projectRoot + 'js/placemarkGreen.png',
                                            anchor: [0.5,0.5],
                                            size:   [25,25]
                                          });
    var strokePostalCode = new ol.style.Stroke({color: '#00ff00', width: 2});
    var fillPostalCode = new ol.style.Fill({color: 'rgba(0, 255, 0, 0.2)'});
    
    var strokeSelectedRiding = new ol.style.Stroke({color: '#ff0000', width: 10});
    var fillSelectedRiding = new ol.style.Fill({color: 'rgba(255, 127, 127, 0.5)'});
    
    var ridingStyle = new ol.style.Style({
      image: new ol.style.Circle({
        fill: fillRiding,
        stroke: strokeRiding,
        radius: 7
      })
    });
    
    var getRidingStyle = function (feat, resolution){
      if (feat.getProperties().type === 'federal'){
        return new ol.style.Style({
          image: iconFedRiding
        });
      }
      else{
        if (feat.getProperties().type === 'treaty'){
          return new ol.style.Style({
            image: iconTreatyRiding
          });
        }else {
          return new ol.style.Style({
            image: iconProvRiding
          });
        }
      }
    };
    
    var getSelectedStyle = function(resolution){
      var anchor = [1,0.5]; //provincial
      if (this.getProperties().type === 'federal'){
        anchor = [0,0.5];
      }
      else if (this.getProperties().type === 'treaty'){
        anchor = [0.5,0.5];
      }
      console.log(anchor.toString());
      return new ol.style.Style({
        image: new ol.style.Icon({
          src:    projectRoot + 'js/placemarkSelected.png',
          anchor: anchor,
          size:   [25,25]
        })
      });
    };
    
    var getPostalCodeStyle = function (feat, resolution){
      return new ol.style.Style({
        image: new ol.style.RegularShape({
          fill: fillPostalCode,
          stroke: strokePostalCode,
          points: 5,
          radius: 10,
          radius2: 4,
          angle: 0
        }),
        text: new ol.style.Text({
          text: feat.get('id'),
          align: center,
          offsetY: -20,
          stroke: new ol.style.Stroke({color: 'white', width: 4}),
          font: 'bold 16px Georgia'
        })
      });
    };
    
    function parseSearch(){
      var i, maxi, feat;
      var targPlace = getQueryParam('place');
      //console.log(targPlace);
      var targPostalCode = getQueryParam('postalCode');
      if (targPlace.length > 0){
         feat = srcRidings.getFeatureById(targPlace);
         if (feat !== null){
            setupMapPopup();
            //document.getElementById('mapPopup').innerHTML = featureToHtml(feat);
            //mapPopup.setPosition(feat.getGeometry().getCoordinates());
            placePopup(feat);
            zoomToFeature(feat);
            if (currFeat !== null){
              currFeat.setStyle(null);
            }
            currFeat = feat;
            //console.log(targPlace);
            currFeat.setStyle(getSelectedStyle);
         }
      }
      if (targPostalCode.length > 0){
         jumpToPostalCode(targPostalCode);
      }
    };
                
    //Create a vector layer for the ridings.
    var srcRidings = new ol.source.Vector({
    //We need to make sure this works whether we're in the /en/ or /fr/ subfolders.
      //url: 'js/places.json',
      url: projectRoot + 'js/places.json',
      format:  new ol.format.GeoJSON()
    });
    
    var ridingsLoadedFunc = function(){
      if (srcRidings.getState() == 'ready'){
        srcRidings.un('change', ridingsLoadedFunc);
        parseSearch();
      }
    }
    
    srcRidings.on('change', ridingsLoadedFunc);
    
    var layerRidings = new ol.layer.Vector({
      source: srcRidings,
      /* style: ridingStyle */
      style: getRidingStyle
    });
    
    //Create another unsourced layer for the user-entered postal codes.
    var srcPostalCodes = new ol.source.Vector({
      format:  new ol.format.GeoJSON()
    });
    var layerPostalCodes = new ol.layer.Vector({
      source: srcPostalCodes,
      style: getPostalCodeStyle
    });
    
    //Standard OSM layer.
    var layerOSM = new ol.layer.Tile({
      source: new ol.source.OSM({
        numZoomLevels: 20,
        maxZoom: 19
      })
    });
    
    var key = APIKey || null;
    
    //MapBox layer used for development only.
    var layerMapBox = new ol.layer.VectorTile({
      source: new ol.source.VectorTile({
        crossOrigin: 'anonymous',
        attributions: '© <a href="https://www.mapbox.com/map-feedback/">Mapbox</a> ' +
          '© <a href="https://www.openstreetmap.org/copyright">' +
          'OpenStreetMap contributors</a>',
        format: new ol.format.MVT(),
        tileGrid: ol.tilegrid.createXYZ({maxZoom: 17}),
        tilePixelRatio: 16,
        url: 'https://{a-d}.tiles.mapbox.com/v4/mapbox.mapbox-streets-v6/' +
            '{z}/{x}/{y}.vector.pbf?access_token=' + key
      }),
      style: createMapboxStreetsV6Style()
    });
    
    //Longitudinal centre of Canada per https://en.wikipedia.org/wiki/Centre_of_Canada;
    //latitudinal adjusted by me.
    var center = [-96.8097,56.6277];
    var bounds = [-141.9903, 76.1156, -49.1778, 44.2580];

    var map = new ol.Map({
      layers: [
        layerOSM,
        layerRidings,
        layerPostalCodes
      ],
      target: 'map',
      view: new ol.View({
        bounds: bounds,
        center: ol.proj.fromLonLat(center),
        //projection: 'EPSG:3857',
        zoom: 4,
        maxZoom: 16,
        minZoom: 4
      })
    });
    
    map.on('pointermove', function(e){
      var pixel = map.getEventPixel(e.originalEvent);
      var hit = map.hasFeatureAtPixel(pixel);
      map.getViewport().style.cursor = hit ? 'pointer' : '';
    });
    
    var mapPopup = null;
    
    //Add a crude click event so you can see the info on a riding.
    //Later this will show whatever it is we want to show.
    map.on("click", function(e) {
      var found = false;
      map.forEachFeatureAtPixel(e.pixel, function (feature, layer) {
        if (found === false){
          found = true;
          setupMapPopup();
          if (feature.getProperties().notBefore){
            //document.getElementById('mapPopup').innerHTML = featureToHtml(feature);
            placePopup(feature);
            //mapPopup.setPosition(e.coordinate);
          }
          if (currFeat !== null){
            currFeat.setStyle(null);
          }
          currFeat = feature;
          currFeat.setStyle(getSelectedStyle);
        }
      })
    });
    
    function reqLoad(){
      //var ret = '<div class="popupCloser" onclick="mapPopup.setPosition([-2000,-2000])">✕</div>';
      var ret = '<div class="popupCloser" onclick="mapPopup.style.display = \'none\';">✕</div>';
      ret += this.responseText;
      mapPopup.innerHTML = ret;
      mapPopup.style.display = 'block';
    }
    
    function placePopup(feature){
      var id = feature.getId();
      //console.log(id);
      //THIS FAILS. Don't know why.
      /*var url = 'ajax/' + id + '.xml';
        ajaxRetrieve(url).then(function(response) {
            var ret = '<div class="popupCloser" onclick="mapPopup.setPosition([-2000,-2000])">✕</div>';
            ret += response.responseXml;
            document.getElementById('mapPopup').innerHTML = ret;
        }, function(Error) {
            console.log(Error);
      });*/
      
      //Doing it the simple way.
      var oReq = new XMLHttpRequest();
      oReq.addEventListener('load', reqLoad);
      oReq.open('GET', 'ajax/' + id + '.xml');
      oReq.send();
    }
    
    function setupMapPopup(){
      if (mapPopup == null){
        mapPopup = document.getElementById('mapPopup');
             /*mapPopup = new ol.Overlay({
                element: document.getElementById('mapPopup'),
                positioning: 'bottom-center',
                offset: [0, -5]
              });
             map.addOverlay(mapPopup);*/
          }
    }
    
    function zoomToFeature(feat){
      map.getView().animate({
        //center: ol.proj.fromLonLat(feat.getGeometry().getCoordinates()),
        center: feat.getGeometry().getCoordinates(),
        zoom: 8,
        duration: 2000
      });
    }
