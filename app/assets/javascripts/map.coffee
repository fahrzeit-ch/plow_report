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

isFormEmpty = () ->
  empty = true
  for component of componentForm
    if !!document.getElementById(component).value
      empty = false
  return empty

onAutocompleteChanged = (autocomplete, map) ->
  place = autocomplete.getPlace()
  alignMap(place, map)
  if isFormEmpty()
    fillInAddress(place)

alignMap = (place, map) ->
  bounds = new google.maps.LatLngBounds()
  bounds.extend(place.geometry.location)
  map.fitBounds(bounds)

fillInAddress = (place) ->
  # Get the place details from the autocomplete object.
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

$(document).on 'turbolinks:load', ->
  countries = {
    'ch': {
      center: {lat: 47.124492, lng: 8.738277},
      zoom: 10
    },
  };
  mapStyles = [
    {
      featureType: "poi",
      elementType: "labels",
      stylers: [
        { visibility: "off" }
      ]
    }
  ];

  marker = null;
  polyLine = null;
  map = null;

  mode = modes.none;
  geoJson = {}

  jsonData = {}

  country = 'ch';

  mapDiv = $('#map')
  return unless mapDiv.length

  addMarkerBtn = $('#addMarker')
  addLineBtn = $('#addLine')
  finishEditBtn = $('#finishEdit')
  infoTextArea = $('#toolInfo')
  mapDataInput = $('#mapData')

  loadMapData = () ->
    try
      geoJson = JSON.parse(mapDataInput.val())
    catch e
      # Do something

  storeMapData = () ->
    mapDataInput.val(JSON.stringify(jsonData))

  resetMarkers = () ->
    map.data.forEach (feature) ->
      map.data.remove(feature)
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
    coordinates = path.getArray().map (seg) ->
      [seg.lng(), seg.lat()]
    jsonData = {type: "Feature", geometry: {type:"LineString", coordinates: coordinates}}


  setMarker = (event) ->
    if(marker != null)
      marker.setPosition(event.latLng)
    else
      marker = new google.maps.Marker({
        position: event.latLng,
        map: map
      });
    jsonData = {type: "Feature", geometry: {type:"Point", coordinates: [event.latLng.lng(), event.latLng.lat()]}}

  handleMapClick = (event) ->
    if mode == modes.addPolyline
      addPolylinePoint(event)
    else if mode == modes.addMarker
      setMarker(event)
    else

  finishEditMode = () ->
    infoTextArea.css 'display', 'none'
    addMarkerBtn.css 'display', 'inline'
    addLineBtn.css 'display', 'inline'
    finishEditBtn.css 'display', 'none'

  setEditInfoText = (text) ->
    infoTextArea.css 'display', 'inline'
    infoTextArea.text(text)

  setEditMode = () ->
    addMarkerBtn.css 'display', 'none'
    addLineBtn.css 'display', 'none'
    finishEditBtn.css 'display', 'inline'

  finishEditBtn.on 'click', ->
    mode = modes.none;
    finishEditMode()
    storeMapData()

  addMarkerBtn.on 'click', ->
    if mode != modes.addMarker
      resetMarkers()
      mode = modes.addMarker
      setEditMode()
      setEditInfoText(addMarkerBtn.data('infotext'))

  addLineBtn.on 'click', ->
    if mode != modes.addPolyline
      resetMarkers()
      mode = modes.addPolyline
      setEditMode()
      setEditInfoText(addLineBtn.data('infotext'))

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
    bounds: defaultBounds
  };

  autocomplete = new google.maps.places.Autocomplete(input, options);

  mapOptions = {
    zoom: countries['ch'].zoom,
    center: countries['ch'].center,
    mapTypeControl: true,
    panControl: true,
    zoomControl: true,
    streetViewControl: true
    styles: mapStyles
  }
  map = new google.maps.Map(document.getElementById('map'), mapOptions)
  loadMapData()
  map.data.addGeoJson(geoJson)

  bounds = new google.maps.LatLngBounds()
  if geoJson.geometry
    coords = geoJson.geometry.coordinates
    for a in coords
      if typeIsArray(a)
        bounds.extend(new google.maps.LatLng(a[1], a[0]))
      else
        bounds.extend(new google.maps.LatLng(coords[1], coords[0]))
        break
    map.fitBounds(bounds)

  map.addListener('click', handleMapClick);

  autocomplete.setComponentRestrictions({'country': country});
  autocomplete.addListener('place_changed', () -> onAutocompleteChanged(autocomplete, map));