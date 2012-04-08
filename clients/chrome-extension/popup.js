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

var openplacos = new OAuth2('openplacos', {
  client_id: '1skcr98ezqz080c4vf8d38dpd',
  client_secret: 'coiqj7jp0rou1dyd35v1va8yv',
  api_scope: 'read write user'
});

function clearAuthorized() {
    console.log('clear');
    openplacos.clearAccessToken();
};

openplacos.authorize(function() {

  // Login
  // Make an XHR that creates the task
  var xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function(event) {
    if (xhr.readyState == 4) {
      if(xhr.status == 200) {
        // Great success: parse response with JSON
        var parsed = JSON.parse(xhr.responseText);
        var html = parsed.username;
        document.querySelector('#login').innerHTML = html;
        return;

      } else {
        // Request failure: something bad happened
      }
    }
  };
  xhr.open('GET', 'http://localhost:4567/me', true);
  xhr.setRequestHeader('Content-Type', 'application/json');
  xhr.setRequestHeader('Authorization', 'OAuth ' + openplacos.getAccessToken());

  xhr.send();
  
  var ressources = new XMLHttpRequest();
  ressources.onreadystatechange = function(event) {
    if (ressources.readyState == 4) {
      if(ressources.status == 200) {
        // Great success: parse response with JSON
        var parsed = JSON.parse(ressources.responseText);
        var html = '';
        parsed.forEach(function(item, index) {
          html += '<li>' + item.name + '</li>';
        });
        document.querySelector('#ressources').innerHTML = html;
        return;

      } else {
        // Request failure: something bad happened
      }
    }
  };

  // ressources
  ressources.open('GET', 'http://localhost:4567/ressources', true);
  ressources.setRequestHeader('Content-Type', 'application/json');
  ressources.setRequestHeader('Authorization', 'OAuth ' + openplacos.getAccessToken());
  ressources.send();

});

