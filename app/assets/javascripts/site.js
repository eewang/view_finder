// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(function(){
  $('#login').click(function(e){
    e.preventDefault();
    $.get('login_modal', function(html, status){
      console.log(html);
      $(".back").append(html);
      $('#myModal').modal('toggle');
    })
  })

  $('#signup').click(function(e){
    e.preventDefault();
    $.get('signup_modal', function(html, status){
      console.log(html);
      $(".back").append(html);
      $('#myModal').modal('toggle');
    })
  })

  $('#login_submit').click(function(e){
    console.log("Hello");
    $('#myModal').modal('toggle');
    $('#myModal').remove();
  })

  $('#logout').click(function(e){
    e.preventDefault();
    $.get('logout', function(html, status){
      console.log(html);
    })
  })

})