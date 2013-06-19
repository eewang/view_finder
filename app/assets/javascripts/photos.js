$(function(){
  $('.carousel-index').carousel('pause');
  $(".zoom-in").imageLens();

});

google.maps.event.addDomListener(window, "load", function() {
  //
  // initialize map
  //

  var latlong;
  var map;
  var locallat;
  var locallon;
  var photo_id = <%= @photo.id.to_s %>;
  var game = "<%= @game %>";
  var currentPhoto = "/photos/" + photo_id + ".json";
  var style = [
   {
    stylers: [
      { hue: "#00ffe6" },
      { saturation: -20 }
    ]
   },{
    featureType: "road",
    elementType: "geometry",
    stylers: [
      { lightness: 100 },
      { visibility: "simplified" }
    ]
   },{
    featureType: "road",
    elementType: "labels",
    stylers: [
      { visibility: "on" }
    ]
   }
  ];


  var styledMap = new google.maps.StyledMapType(style,
        {name: "Jazzy Jeff"});

  $.get(currentPhoto, function(data) {
    console.log(data);
    latlong = data;
    map = new google.maps.Map(document.getElementById("mapdiv"), {
      center: new google.maps.LatLng(latlong.locale_lat, latlong.locale_lon),
      zoom: 15,
      mapTypeControlOptions: {
        mapTypeIds: [google.maps.MapTypeId.ROADMAP, 'map_style']
      }
    }
    );
    //
    // initialize marker
    //

    map.mapTypes.set('map_style', styledMap);
    map.setMapTypeId('map_style');

    var marker = new google.maps.Marker({
      position: map.getCenter(),
      draggable: true,
      map: map
    });

    marker.setIcon('<%= asset_path 'guessmarker.png' %>')
    
    // intercept map and marker movements
    
    google.maps.event.addListener(map, "idle", function() {
      marker.setPosition(map.getCenter());
      locallat = map.getCenter().lat().toFixed(6);
      locallon = map.getCenter().lng().toFixed(6);
      console.log(locallat);
      console.log(locallon);
    });    

    google.maps.event.addListener(marker, "dragend", function(mapEvent) {
      map.panTo(mapEvent.latLng);
    });
    //
    // initialize geocoder
    //
    console.log(map);

    var geocoder = new google.maps.Geocoder();
    google.maps.event.addDomListener(document.getElementById("mapform"), "submit", function(domEvent) {
      if (domEvent.preventDefault){
        domEvent.preventDefault();
      } else {
        domEvent.returnValue = false;
      }
      geocoder.geocode({
        address: document.getElementById("mapinput").value
      }, function(results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
          var result = results[0];
          document.getElementById("mapinput").value = result.formatted_address;
          if (result.geometry.viewport) {
            map.fitBounds(result.geometry.viewport);
          }
          else {
            map.setCenter(result.geometry.location);
          }
        } else if (status == google.maps.GeocoderStatus.ZERO_RESULTS) {
          alert("Sorry, the geocoder failed to locate the specified address.");
        } else {
          alert("Sorry, the geocoder failed with an internal error.");
        }
      });
    });
    
  });



  // This happens when you click the guess button.
  $("#submit_guess").click(function(){

  // This is the data you need in order to create a guess.
    var parameters = {
      "latitude":locallat,
      "longitude":locallon,
      "photo_id":photo_id,
    }

    console.log(parameters);

    // POST(where?, what?, on success?)
    $.post('/guesses', parameters, function(json){

      console.log(json);

      // Redirect to '/guesses/59', for example.
      window.location.href = json.redirect_url;
    }, 'json');

  });



});



