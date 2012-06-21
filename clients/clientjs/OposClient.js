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

// Get method (with correct oauth2 header)
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

/***********************************
 *
 * PUBLIC API
 *
 ***********************************/

/**
 * Set the token 
 * 
 *  @ params {String} token : The token string
 */
OposClient.prototype.set_token = function(token) {
  this.token = token;
};

/**
 * Return the username
 * 
 *  @ params {function} callback : execute the callback if success
 */
OposClient.prototype.me = function(callback) {
  this.get('/me',{},function(msg) { callback(msg.username); } )
};

/**
 * Return the ressources list
 * 
 *  @ params {function} callback : execute the callback if success
 */
OposClient.prototype.ressources = function(callback) {
  this.get('/ressources',{},callback)
};

/**
 * Read a ressource
 * 
 *  @ params  {function}  callback  : execute the callback if success
 *            {String}    name      : the name of the ressource
 *            {String}    iface     : the name of the iface
 */
OposClient.prototype.read = function(name,iface,callback) {
  this.get('/ressources' + name,{'iface' : iface},callback)
};

/**
 * Write a value on a ressource
 * 
 *  @ params  {function}  callback  : execute the callback if success
 *            {String}    name      : the name of the ressource
 *            {String}    iface     : the name of the iface
 *            {Hash}      value     : the value to write
 */
OposClient.prototype.write = function(name,iface,value,callback) {
  parameters = {
            'iface' : iface,
            'value' : JSON.stringify([value])
            };
  this.post('/ressources' + name,parameters,callback)
};

