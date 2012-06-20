var opos = new OposClient("http://localhost:4567","salut",['read','write']);

opos.set_token(" ");

opos.ressources(
  function(msg) { 
    msg.forEach(
      function(item, index) {
        $('.inner').append('<li>' + item.name + '</li>'); 
      }
    );
  }
);
