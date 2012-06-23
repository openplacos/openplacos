var opos = new OposClient("http://localhost:4567","salut",['read','write']);

opos.set_token(" ");

opos.ressources(
  function(msg) { 
    msg.forEach(
      function(item, index) {
        $('.ressources').append('<li>' + item.name + '</li>'); 
      }
    );
  }
);

function refresh(){
    opos.get('/ressources/home/temperature',{'iface' :'analog.sensor.temperature.celcuis'}, function(msg) { $('.temperature').html(msg.value + '<br>');});
};

function light(value){
    opos.post('/ressources/home/light',{'iface' :'digital.order.switch', 'value':JSON.stringify([value])}, function(msg) { alert(msg.status);});
};
function fan(value){
    opos.post('/ressources/home/fan',{'iface' :'digital.order.switch', 'value':JSON.stringify([value])}, function(msg) { alert(msg.status);});
};

$(document).ready(function() {
    setInterval('refresh();',1000);
});
