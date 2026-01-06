import QtQuick 2.0
import Sailfish.Silica 1.0
import MapboxMap 1.0
import QtPositioning 5.3

Page {
  id: map_page

  property real pos_latitude: 51.50733946347199
  property real pos_longitude: -0.12764754131318562
  property real pos_accuracy: 10000

  property real node_latitude: 51.50733946347199
  property real node_longitude: -0.12764754131318562
  property real node_accuracy: 10000

  property bool stops_requested: false

  property var low_zoom_modes: ['national-rail', 'tflrail']
  property var medium_zoom_modes: ['national-rail', 'tflrail', 'overground', 'tube', 'dlr']
  property var high_zoom_modes: ['national-rail', 'tflrail', 'overground', 'tube', 'dlr', 'tram', 'bus']

  //2 = Bus Stop, 4 = Tram stop, 6 = Light Rail station, 8 = metro station, 10 = rail station
  property var low_zoom_stop_types: [10]
  property var medium_zoom_stop_types: [4, 6, 8, 10]
  property var high_zoom_stop_types: [2, 4, 6, 8, 10]

  property bool follow_location: false
  property bool page_active: true
  property var stop_point
  property var last_bounding_box

  property string mapbox_key: "pk.eyJ1IjoiYW5hcmNoeS1pbi10aGUtdWsiLCJhIjoiY2twbnRxdGVpMGYxZDJwcDRseHoyMTd5bCJ9.df75IhuH1tbEVAWOOJfCrA"

  PositionSource {
    id: position_source
    updateInterval: 1000
    active: true
    
    onPositionChanged: {
      console.log('PositionChanged:', position_source.position.coordinate.latitude, position_source.position.coordinate.longitude, position_source.position.horizontalAccuracy)
      if (isNaN(position_source.position.coordinate.latitude) || isNaN(position_source.position.coordinate.longitude) || isNaN(position_source.position.horizontalAccuracy)) {
        return
      }
      position_update(position_source.position.coordinate.latitude, position_source.position.coordinate.longitude, position_source.position.horizontalAccuracy, position_source.position.timestamp)
    }
  }

  Timer {
    id: request_stops_timer
    interval: 500
    running: false
    repeat: false
    onTriggered: {
 
    }
  }

  DockedPanel {
    id: panel_top

    width: parent.width
    height: Theme.itemSizeMedium + Theme.paddingSmall
    open: Boolean(stop_point)
    dock: Dock.Top
  }

  MouseArea {
    width: panel_top.width
    height: panel_top.height
    onClicked: {
      pageStack.push(
        Qt.resolvedUrl("PredictionsPage.qml"), {
          'stop_point': stop_point
        }
      )
    }
  }

  DockedPanel {
    id: panel_bottom

    width: parent.width
    height: Theme.itemSizeLarge

    dock: Dock.Bottom

    Row {
      anchors {
        top: parent.top
      }
    }
  }

  SilicaFlickable {
    clip: panel_top.expanded

    height: parent.height - panel_top.height - panel_bottom.height
    width: parent.width

    anchors {
      top: panel_top.bottom
      bottom: panel_bottom.top
      topMargin: panel_top.margin
      bottomMargin: panel_bottom.margin
    }

    MapboxMap {
      id: map
      width: parent.width
      anchors {
        fill: parent
      }

      center: QtPositioning.coordinate(51.50733946347199, -0.12764754131318562)
      zoomLevel: 14.0
      minimumZoomLevel: 0
      maximumZoomLevel: 20
      pixelRatio: 3.0

      accessToken: mapbox_key
      cacheDatabaseMaximalSize: 1024*1024*1024
      cacheDatabasePath: "/home/defaultuser/.local/share/app.qml/tcarint/mbgl-cache.db"

      styleUrl: "mapbox://styles/mapbox/streets-v12" //''mapbox://styles/mapbox/navigation-day-v1' mapbox://styles/mapbox/dark-v10'
    
      MapboxMapGestureArea {
        map: map

        activeClickedGeo: true
        activeDoubleClickedGeo: true
        activePressAndHoldGeo: true

        onClicked: {
          console.log("Click:", mouse.y, 't:', panel_top.height, 'b:', map.height - panel_bottom.height)

          if (mouse.y < panel_top.height) {
            stop_point = undefined
          } else if (mouse.y > map.height - panel_bottom.height) {
            //Bottom pannel disabled, left in for future use
            //panel_bottom.open = !panel_bottom.open
          }
        }
  
        onPressAndHold: console.log("Press and hold: ", mouse.x, mouse.y)

        onDoubleClicked: {
          console.log("Double click: ", mouse.x, mouse.y)
          position_marker_item.visible = !position_marker_item.visible
          if (!position_marker_item.visible) stop_point = null
        }

        onClickedGeo: {
          console.log("Click geo: " + geocoordinate + " sensitivity: " + degLatPerPixel + " " + degLonPerPixel)
          request_stop(geocoordinate.latitude, geocoordinate.longitude)
        }
        onDoubleClickedGeo: {
          console.log("DoubleClick geo: " + geocoordinate + " sensitivity: " + degLatPerPixel + " " + degLonPerPixel)
        }
        onPressAndHoldGeo: {
          
        }
      }

      onCenterChanged: {
        request_stops_timer.restart()
      }
      onZoomLevelChanged: {
        request_stops_timer.restart()
        //app.settings.history.map_zoom = map.zoomLevel
      }
    }

    Rectangle {                                                         
      id: position_marker_item                                   
      anchors {
        right: parent.right
        bottom: parent.bottom
        rightMargin: Theme.paddingLarge
        bottomMargin: Theme.paddingLarge
      }      

      color: "lightgrey"
      width: Theme.itemSizeSmall
      height: width                                                                                                                                          
      radius: width/2

      Rectangle {
        height: position_marker_item.height * 0.63
        width: height
        radius: width/2
        color: "grey"
        anchors.centerIn: parent
      }

      Rectangle {
        height: position_marker_item.height * 0.3
        width: height
        radius: width/2
        color: follow_location ? "green" : "blue"
        anchors.centerIn: parent
      }

      MouseArea {
        anchors.fill: parent
        onClicked: {
          follow_location = !follow_location
          if (follow_location) {
            map.center = QtPositioning.coordinate(pos_latitude, pos_longitude)
            map.setPaintProperty("location", "circle-color", "green")
          } else {
            map.setPaintProperty("location", "circle-color", "blue")
          }
        }
      }                                                                                                                                         
    } 
  }

  Component.onCompleted: {
    create_node_layer()
    create_position_layer()
    map.center = QtPositioning.coordinate(node_latitude, node_longitude)
  }

  Component.onDestruction: {

  }

  function create_map_circle(latitude, longitude, radius) {
    const angles = 20;
    var coordinate_pairs = [];
    for(var i=0; i<angles; i++) {
      coordinate_pairs.push([longitude + (radius/(111320 * Math.cos(latitude * Math.PI / 180)) * Math.cos((i / angles) * (2* Math.PI))), latitude + (radius/110574 * Math.sin((i/angles) * (2 * Math.PI)))]);
    }
    coordinate_pairs.push(coordinate_pairs[0]);

    return {
      "type": "geojson",
      "data": {
        "type": "FeatureCollection",
        "features": [{
          "type": "Feature",
          "geometry": {
            "type": "Polygon",
            "coordinates": [coordinate_pairs]
          }
        }]
      }
    }
  }

  function create_position_layer() {
    map.addSource("location",
    {"type": "geojson",
      "data": {
        "type": "Feature",
        "properties": { "name": "location" },
        "geometry": {
          "type": "Point",
          "coordinates": [(pos_longitude),(pos_latitude)]
        }
      }
    })

    map.addLayer("location-case", {"type": "circle", "source": "location"})
    map.setPaintProperty("location-case", "circle-radius", 10)
    map.setPaintProperty("location-case", "circle-color", "white")

    map.addLayer("location", {"type": "circle", "source": "location"})
    map.setPaintProperty("location", "circle-radius", 5)
    map.setPaintProperty("location", "circle-color", "blue")

    map.addSource("accuracy_circle", create_map_circle(pos_latitude, pos_longitude, pos_accuracy));
    map.addLayer("accuracy_layer", {"type": "fill", "source": "accuracy_circle"});
    map.setPaintProperty("accuracy_layer", "fill-color", "#87cefa")
    map.setPaintProperty("accuracy_layer", "fill-opacity", "0.25")
  }

  function create_node_layer() {
    map.addSource("node_location",
    {"type": "geojson",
      "data": {
        "type": "Feature",
        "properties": { "name": "node_location" },
        "geometry": {
          "type": "Point",
          "coordinates": [(node_longitude),(node_latitude)]
        }
      }
    })

    map.addLayer("node_location-case", {"type": "circle", "source": "node_location"})
    map.setPaintProperty("node_location-case", "circle-radius", 10)
    map.setPaintProperty("node_location-case", "circle-color", "red")

    map.addLayer("node_location", {"type": "circle", "source": "node_location"})
    map.setPaintProperty("node_location", "circle-radius", 5)
    map.setPaintProperty("node_location", "circle-color", "white")
  }

  function position_update(latitude, longitude, accuracy, timestamp) {
    pos_latitude = latitude
    pos_longitude = longitude
    pos_accuracy = accuracy

    if (page_active) draw_location();
    console.log('position_update:',latitude, longitude, accuracy, timestamp)
  }

  function bounding_box(latitude, longitude) {
    if (latitude === undefined) latitude = map.center.latitude;
    if (longitude === undefined) longitude = map.center.longitude;
    return main_handler.bounding_box(latitude, longitude, map.height * map.metersPerPixel * 1, map.width * map.metersPerPixel * 1)
  }

  function draw_location() {
    map.updateSource("location",
    {"type": "geojson",
      "data": {
        "type": "Feature",
        "properties": { "name": "location" },
        "geometry": {
          "type": "Point",
          "coordinates": [(pos_longitude),(pos_latitude)]
        }
      }
    })
    map.updateSource("accuracy_circle", create_map_circle(pos_latitude, pos_longitude, pos_accuracy));

    if (follow_location) map.center = QtPositioning.coordinate(pos_latitude, pos_longitude)
  }
}
