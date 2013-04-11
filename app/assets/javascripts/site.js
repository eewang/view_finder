// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready(function(){

  $('#signup').click(function(e){
    e.preventDefault();
    $.get('signup_modal', function(html, status){
      console.log(html);
      $(".back").append(html);
      $('#mySignupModal').modal('toggle');
    })
  })

  // $('#signup_submit').click(function(e){
  //   alert("hello");
  //   $('#mySignupModal').modal('toggle');
  //   $('#mySignupModal').remove();
  // })

  $('#login').click(function(e){
    e.preventDefault();
    $.get('login_modal', function(html, status){
      console.log(html);
      $(".back").append(html);
      $('#myLoginModal').modal('toggle');
    })
  })

  $('#login_submit').click(function(e){
    console.log("Hello");
    $('#myLoginModal').modal('toggle');
    $('#myLoginModal').remove();
  })

  $('#logout').click(function(e){
    e.preventDefault();
    $.get('logout', function(html, status){
      console.log(html);
    })
  })

})