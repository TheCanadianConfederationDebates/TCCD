/* General utility functions used in multiple contexts. */

"use strict";

/**
 * Method for retrieving JSON from a URL using
 * XMLHttpRequest. Stolen from:
 * https://github.com/mdn/promises-test/blob/gh-pages/index.html
 * with thanks.
 *
 * Call like this:
 *
 *  ajaxRetrieve('json/myfile.json', 'json').then(function(response) {
 *  // The first runs when the promise resolves, with the request.response
 *  // specified within the resolve() method.
 *  something.something = JSON.Parse(response);
 *  // The second runs when the promise
 *  // is rejected, and logs the Error specified with the reject() method.
 *    }, function(Error) {
 *      console.log(Error);
 *  });
 *
 * @function ajaxRetrieve
 * @description Method for retrieving JSON from a URL using
 * XMLHttpRequest. Stolen from:
 * https://github.com/mdn/promises-test/blob/gh-pages/index.html
 * with thanks.
 * @param {string} url URL from which to retrieve target file.
 * @param {string} responseType the mime type of the target document.
 * @return Promise
 */
function ajaxRetrieve(url, responseType) {
  // Create new promise with the Promise() constructor;
  // This has as its argument a function
  // with two parameters, resolve and reject
  return new Promise(function(resolve, reject) {
    // Standard XHR to load a JSON file
    var request = new XMLHttpRequest();
    request.open('GET', url);
    request.responseType = responseType;
    // When the request loads, check whether it was successful
    request.onload = function() {
      if (request.status == 200) {
      // If successful, resolve the promise by passing back the request response
        resolve(request.response);
      } else {
      // If it fails, reject the promise with a error message
        reject(Error(responseType.toUpperCase() + ' file ' + url + 'did not load successfully; error code: ' + request.statusText));
      }
    };
    request.onerror = function() {
    // Also deal with the case when the entire request fails to begin with
    // This is probably a network error, so reject the promise with an appropriate message
        reject(Error('There was a network error.'));
    };
    // Send the request
    request.send();
  });
};

/**
 * Function for parsing a URL query string. Pinched with thanks
 * from here:
 * http://stackoverflow.com/questions/2090551/parse-query-string-in-javascript
 *
 * @function getQueryParam
 * @description parses a URL query
 *         string and returns a value for a specified param name.
 * @param {string} param The name of the param name to search for.
 * @returns {string} the value of the param, or an empty string.
 */
function getQueryParam(param) {
    var i, vars, pair, query = window.location.search.substring(1);
    vars = query.split('&');
    for (i = 0; i < vars.length; i++) {
        pair = vars[i].split('=');
        if (decodeURIComponent(pair[0]) == param) {
            return decodeURIComponent(pair[1]);
        }
    }
    return '';
};


/* Function to toggle a class for an expander heading. */
function switchExpanderClass(sender){
    if (sender.className.match(/^open/)){
        sender.className = sender.className.replace(/^open/, 'closed');
    }
    else{
        sender.className = sender.className.replace(/^closed/, 'open');
    }    
}
