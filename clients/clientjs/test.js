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
    opos.read('/home/temperature','analog.sensor.temperature.celcuis', function(msg) { $('.temperature').html(msg.value + '<br>');});
};

function light(value){
  opos.write('/home/light','digital.order.switch',value, function(msg) { alert(msg.status);});
};
function fan(value){
  opos.write('/home/fan','digital.order.switch',value, function(msg) { alert(msg.status);});
};

$(document).ready(function() {
    setInterval('refresh();',1000);
});
