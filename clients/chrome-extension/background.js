chrome.omnibox.onInputChanged.addListener(
  function(text, suggest) {
    console.log('inputChanged: ' + text);
    suggest([
      {content: "read " + text, description: "read a ressource"},
      {content: "write " + text, description: "write a ressource"}
    ]);
  });

// This event is fired with the user accepts the input in the omnibox.
chrome.omnibox.onInputEntered.addListener(
  function(text) {
    console.log('inputEntered: ' + text);
    alert('You just typed "' + text + '"');
  });
