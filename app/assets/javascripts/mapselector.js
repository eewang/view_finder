// google.maps.event.addDomListener(window, "load", function() {
//   //
//   // initialize map
//   //
//   var latlong;
//   var map;

//   var locallat;
//   var locallon;

//   var currentPhoto = "/photos/" + photo_id + ".json"
//   $.get(currentPhoto, function(data) {
//     latlong = data
//     var map = new google.maps.Map(document.getElementById("mapdiv"), {
//       center: new google.maps.LatLng(latlong.locale_lat, latlong.locale_lon),
//       zoom: 14,
//       mapTypeId: google.maps.MapTypeId.ROADMAP
//     });
//     //
//     // initialize marker
//     //
//     var marker = new google.maps.Marker({
//       position: map.getCenter(),
//       draggable: true,
//       map: map
//     });
//     //
//     // intercept map and marker movements
//     //
//     google.maps.event.addListener(map, "idle", function() {
//       marker.setPosition(map.getCenter());
//       locallat = map.getCenter().lat().toFixed(6);
//       locallon = map.getCenter().lng().toFixed(6);
//       // document.getElementById("mapoutput").innerHTML = "<a href=\"https://maps.google.com/maps?q=" + encodeURIComponent(map.getCenter().toUrlValue()) + "\" target=\"_blank\" style=\"float: right;\">Go to maps.google.com</a>Latitude: " + map.getCenter().lat().toFixed(6) + "<br>Longitude: " + map.getCenter().lng().toFixed(6);
//     });    

//     google.maps.event.addListener(marker, "dragend", function(mapEvent) {
//       map.panTo(mapEvent.latLng);
//     });
//     //
//     // initialize geocoder
//     //
//     var geocoder = new google.maps.Geocoder();
//     google.maps.event.addDomListener(document.getElementById("mapform"), "submit", function(domEvent) {
//       if (domEvent.preventDefault){
//         domEvent.preventDefault();
//       } else {
//         domEvent.returnValue = false;
//       }
//       geocoder.geocode({
//         address: document.getElementById("mapinput").value
//       }, function(results, status) {
//         if (status == google.maps.GeocoderStatus.OK) {
//           var result = results[0];
//           document.getElementById("mapinput").value = result.formatted_address;
//           if (result.geometry.viewport) {
//             map.fitBounds(result.geometry.viewport);
//           }
//           else {
//             map.setCenter(result.geometry.location);
//           }
//         } else if (status == google.maps.GeocoderStatus.ZERO_RESULTS) {
//           alert("Sorry, the geocoder failed to locate the specified address.");
//         } else {
//           alert("Sorry, the geocoder failed with an internal error.");
//         }
//       });
//     });



//   })

//   var guess = document.getElementById("submit_guess");
//   guess.addEventListener("click", function(){
//     console.log("click works");

//     // locallat = map.getCenter().lat().toFixed(6);
//     // locallon = map.getCenter().lng().toFixed(6);

//     $.ajax({
//       url: '/guesses',
//       data: { "latitude": locallat, "longitude":locallon, "photo_id":photo_id },
//       dataType: 'json',
//       type: "POST",
//       success: function(){
//         alert('you know');
//       }
//     });

//   });

// });
