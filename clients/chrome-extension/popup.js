/*
 * Copyright 2011 Google Inc. All Rights Reserved.

 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

var server_url = localStorage["host_url"];

var openplacos = new OAuth2('openplacos', {
  client_id: localStorage["client_id"],
  client_secret: localStorage["client_secret"],
  api_scope: 'read write user'
});

function clearAuthorized() {
    console.log('clear');
    openplacos.clearAccessToken();
};

// read the username and put the result in the div #id
function getUsername(id) {
  $.ajax({
    type: "GET",
    url: server_url + "/me",
    dataType: 'json',
    success: function(msg) { $("#"+id).text( msg.username ); },
    headers: { 
      'Content-Type' : 'application/json',
      'Authorization' : 'OAuth ' + openplacos.getAccessToken()
    }
  });
};
// read a ressource and put the result in the div #id
function readRessource(name,iface,id) {
  $.ajax({
    type: "GET",
    url: server_url + "/ressources/" + name,
    data: { "iface" : iface},
    dataType: 'json',
    success: function(msg) { $("#"+id).text( msg.value ); },
    headers: { 
      'Content-Type' : 'application/json',
      'Authorization' : 'OAuth ' + openplacos.getAccessToken()
    }
  });
};

openplacos.authorize(function() {

  // Login
  getUsername('login')
 
  var ressources = new XMLHttpRequest();
  ressources.onreadystatechange = function(event) {
    if (ressources.readyState == 4) {
      if(ressources.status == 200) {
        // Great success: parse response with JSON
        var parsed = JSON.parse(ressources.responseText);
        var html = '';
        var k=1;
        parsed.forEach(function(item, index) {
          html += '<li>' + item.name + '</li>';
          html += '<ul>';
          for (iface in item.interfaces) {
            k=k+1;
            var id = k;
            html += '<li>' + iface + '<div id='+ id + '></div></li>';
            readRessource(item.name,iface,id);
          };
          html += '</ul>';
        });
        document.querySelector('#ressources').innerHTML = html;
        return;

      } else {
        // Request failure: something bad happened
      }
    }
  };

  // ressources
  ressources.open('GET', server_url + '/ressources', true);
  ressources.setRequestHeader('Content-Type', 'application/json');
  ressources.setRequestHeader('Authorization', 'OAuth ' + openplacos.getAccessToken());
  ressources.send();

});

