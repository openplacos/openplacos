
document.addEventListener('DOMContentLoaded', function () {
  document.querySelector('button').addEventListener('click', save_options);
});

document.addEventListener('DOMContentLoaded', function () {
  document.querySelector('body').addEventListener('onload', restore_options());
});

// Saves options to localStorage.
function save_options() {
  localStorage["host_url"] = document.getElementById("url").value;
  localStorage["client_id"] = document.getElementById("client_id").value;
  localStorage["client_secret"] = document.getElementById("client_secret").value;
  
  // Update status to let user know options were saved.
  var status = document.getElementById("status");
  status.innerHTML = "Options Saved.";
  setTimeout(function() {
    status.innerHTML = "";
  }, 750);
}
// Restores select box state to saved value from localStorage.
function restore_options() {
  document.getElementById("url").value = localStorage["host_url"];
  document.getElementById("client_id").value =   localStorage["client_id"];
  document.getElementById("client_secret").value =   localStorage["client_secret"];
}
