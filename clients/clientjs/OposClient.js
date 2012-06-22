// Constructor
var OposClient = function(host,name,scopes) {
  this.host = host;
  this.name = name;
  this.scopes = scopes;
  var that = this;
  //this.register();
};

// register the client
OposClient.prototype.register = function() {
  var that = this;
  $.ajax({
    type: "POST",
    url: this.host + "/oauth/apps.json",
    data: {
      "redirect_uri" : "http://localhost:2000",
      "name" : this.name 
    },
    dataType: "json",
    success: function(msg) {
      that.client_id = msg.client_id;
      that.client_secret = msg.client_secret;
    }
  });  
};

/**
 * Post method (with correct oauth2 header)
 * @params {String}   url     : url of opos server
 * @params {String}   data    : params to pass to ressource (according to OpenplacOS REST api)
 * @params {function} callback: callback method if request succeed
 */
OposClient.prototype.get = function(url_,data_,callback_) {
  $.ajax({
    type: "GET",
    url: this.host + url_,
    data: data_,
    dataType: 'json',
    success: callback_,
    headers: { 
      'Authorization' : 'OAuth ' + this.token
    }
  });
};

/**
 * Post method (with correct oauth2 header)
 * @params {String}   url     : url of opos server
 * @params {String}   data    : params to pass to ressource (according to OpenplacOS REST api)
 * @params {function} callback: callback method if request succeed
 */
OposClient.prototype.post = function(url_,data_,callback_) {
  $.ajax({
    type: "POST",
    url: this.host + url_,
    data: data_,
    dataType: 'json',
    success: callback_,
    headers: { 
      'Authorization' : 'OAuth ' + this.token
    }
  });
};
