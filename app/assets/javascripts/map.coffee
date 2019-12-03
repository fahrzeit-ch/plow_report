
componentForm = {
  street_number: 'short_name',
  route: 'long_name',
  locality: 'long_name',
  postal_code: 'short_name'
};

modes = {
  none: 'none'
  addMarker: 'add-marker',
  addPolyline: 'add-polyline'
}

fillInAddress = (autocomplete, map) ->
  # Get the place details from the autocomplete object.
  place = autocomplete.getPlace()
  for component of componentForm
    document.getElementById(component).value = ''
    document.getElementById(component).disabled = false
  # Get each component of the address from the place details,
  # and then fill-in the corresponding field on the form.
  i = 0
  while i < place.address_components.length
    addressType = place.address_components[i].types[0]
    if componentForm[addressType]
      val = place.address_components[i][componentForm[addressType]]
      document.getElementById(addressType).value = val
    i++

  bounds = new google.maps.LatLngBounds()
  bounds.extend(place.geometry.location)
  map.fitBounds(bounds)

$(document).on 'turbolinks:load', ->
  countries = {
    'ch': {
      center: {lat: 47.124492, lng: 8.738277},
      zoom: 10
    },
  };

  marker = null;
  polyLine = null;
  map = null;

  mode = modes.none;

  country = 'ch';

  mapDiv = $('#map')
  addMarkerBtn = $('#addMarker')
  addLineBtn = $('#addLine')
  finishEditBtn = $('#finishEdit')

  resetMarkers = () ->
    if(marker != null)
      marker.setMap(null)
      marker = null;
    if(polyLine != null)
      polyLine.setMap(null)
      polyLine = null

  addPolylinePoint = (event) ->
    if(polyLine == null)
      polyLine = new google.maps.Polyline({
        strokeColor: '#000000',
        strokeOpacity: 1.0,
        strokeWeight: 3
      })
      polyLine.setMap(map)

    path = polyLine.getPath()
    path.push(event.latLng)

  setMarker = (event) ->
    if(marker != null)
      marker.setPosition(event.latLng)
    else
      marker = new google.maps.Marker({
        position: event.latLng,
        map: map
      });

  handleMapClick = (event) ->
    if mode == modes.addPolyline
      addPolylinePoint(event)
    else if mode == modes.addMarker
      setMarker(event)
    else

  finishEditMode = () ->
    addMarkerBtn.css 'display', 'inline'
    addLineBtn.css 'display', 'inline'
    finishEditBtn.css 'display', 'none'

  setEditMode = () ->
    addMarkerBtn.css 'display', 'none'
    addLineBtn.css 'display', 'none'
    finishEditBtn.css 'display', 'inline'

  finishEditBtn.on 'click', ->
    mode = modes.none;
    finishEditMode()

  addMarkerBtn.on 'click', ->
    if mode != modes.addMarker
      resetMarkers()
      mode = modes.addMarker
      setEditMode()

  addLineBtn.on 'click', ->
    if mode != modes.addPolyline
      resetMarkers()
      mode = modes.addPolyline
      setEditMode()

  siteId = mapDiv.data('site-id')
  companyId = mapDiv.data('company-id')
  customerId = mapDiv.data('customer-id')

  myCoords = new google.maps.LatLng(47.8, 8.4)

  defaultBounds = new google.maps.LatLngBounds(
    new google.maps.LatLng(46.8, 8.5)
    new google.maps.LatLng(47.8, 8.3)
  )

  input = document.getElementById('searchTextField')
  options = {
    bounds: defaultBounds,
    types: ['address']
  };

  autocomplete = new google.maps.places.Autocomplete(input, options);

  mapOptions = {
    zoom: countries['ch'].zoom,
    center: countries['ch'].center,
    mapTypeControl: true,
    panControl: true,
    zoomControl: true,
    streetViewControl: true
  }
  map = new google.maps.Map(document.getElementById('map'), mapOptions)
  map.data.loadGeoJson('/companies/'+ companyId + '/customers/' + customerId + '/sites/' + siteId + '/area.json')
  map.addListener('click', handleMapClick);

  autocomplete.setComponentRestrictions({'country': country});
  autocomplete.addListener('place_changed', () -> fillInAddress(autocomplete, map));