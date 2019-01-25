// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require bootstrap
//= require rails-ujs
//= require_tree .
//= require flatpickr

//delete localstorage with button Delete Browser Memory
$(document).ready(function() {
  $('#delete-memory a').click(function(){ 
    if(confirm("Do you want to delete all the data of all users of this website from your browser-memory?")) {
      localStorage.clear();
    }
    else {
      return false;
    }
  });
});
