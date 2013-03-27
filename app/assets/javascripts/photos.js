// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready(function(){

  // $(".modal-footer > input").click(function(){
  //   event.preventDefault();
  //   console.log("hello");
  // });

  // google.maps.event.trigger(map, "resize");

  $(".btn-primary").click(function(){
    event.preventDefault();
    console.log("hello");
  })

  google.maps.event.addListenerOnce(map, 'idle', function(){
      $(window).resize();
      map.setCenter(yourCoordinates);
  });

  $(window).resize(function() {
      if ($("#map_canvas").children().length > 0){    
          resize();
          if (map)
          google.maps.event.trigger(map, 'resize');
      }});


})