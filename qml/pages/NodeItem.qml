import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
  id: device_item

  property int max_index: 1

  menu: Component {
    ContextMenu {
      MenuItem {
        text: "Show on map"
        enabled: latitude != 0.0
        visible: latitude != 0.0
        onClicked: {
          pageStack.push(Qt.resolvedUrl("MapPage.qml"), {node_latitude: latitude, node_longitude: longitude})
        }
      }
      MenuItem {
        text: "Messages"
        enabled: true
        onClicked: {
          pageStack.push(Qt.resolvedUrl("ChannelMessagesPage.qml"), {})
        }
      }
    }
  }

  Rectangle {
    x: 2
    y: 2
    width: parent.width-4
    height: parent.height-4
    color: Theme.highlightBackgroundColor
    opacity: Theme.highlightBackgroundOpacity
  }

  Label {
    id: node_short_name_label
    y: Theme.paddingSmall
    anchors {
      top: parent.top
      left: parent.left
      leftMargin: Theme.paddingMedium
      rightMargin: Theme.paddingMedium
      topMargin: Theme.paddingSmall
    }
    font.pixelSize: Theme.fontSizeSmall

    text: short_name
    color: Theme.primaryColor
  }

  Label {
    id: node_long_name_label
    y: Theme.paddingSmall
    anchors {
      bottom: parent.bottom
      left: parent.left
      leftMargin: Theme.paddingMedium
      rightMargin: Theme.paddingMedium
      bottomMargin: Theme.paddingSmall
    }
    font.pixelSize: Theme.fontSizeExtraSmall

    maximumLineCount: 1
    elide: Text.ElideRight

    text: long_name
    color: Theme.primaryColor
  }

  Label {
    id: snr_label
    y: Theme.paddingSmall
    anchors {
      top: parent.top
      right: parent.right
      leftMargin: Theme.paddingMedium
      rightMargin: Theme.paddingMedium
      topMargin: Theme.paddingSmall
    }
  
    font.pixelSize: Theme.fontSizeExtraSmall

    visible: hops_away == 0 && local == false

    text: 'snr: ' + snr + 'dB'
    color: Theme.primaryColor
  }

  Label {
    id: hops_label
    y: Theme.paddingSmall
    anchors {
      top: parent.top
      right: parent.right
      leftMargin: Theme.paddingMedium
      rightMargin: Theme.paddingMedium
      topMargin: Theme.paddingSmall
    }
  
    font.pixelSize: Theme.fontSizeExtraSmall

    visible: hops_away >= 0 && !snr_label.visible

    text: hops_away == 0 ? 'direct' : 'hops: ' + parseInt(hops_away)
    color: Theme.primaryColor
  }

  Label {
    id: last_heard_minutes_label
    y: Theme.paddingSmall
    anchors {
      bottom: parent.bottom
      right: parent.right
      leftMargin: Theme.paddingMedium
      rightMargin: Theme.paddingMedium
      bottomMargin: Theme.paddingSmall
    }
  
    font.pixelSize: Theme.fontSizeExtraSmall

    visible: last_heard > 0

    text: (updated_at > 0) ? last_heard_s(last_heard) : last_heard_s(last_heard)
    color: Theme.primaryColor
  }

  Icon {
    id: public_key_present_icon
    source: "image://theme/icon-m-keys"
    anchors {
      verticalCenter: node_short_name_label.verticalCenter
      left: parent.horizontalCenter
      leftMargin: Theme.paddingExtraSmall
    }
    height: node_short_name_label.height * 0.7
    width: height
    visible: public_key_present
    color: Theme.primaryColor
  }

  Icon {
    id: position_icon
    source: "image://theme/icon-m-gps"
    anchors {
      verticalCenter: public_key_present_icon.verticalCenter
      left: public_key_present_icon.right
      leftMargin: Theme.paddingExtraSmall
    }
    height: node_short_name_label.height * 0.8
    width: height
    visible: latitude != 0.0
    color: Theme.primaryColor
  }

  Icon {
    id: telemetry_icon
    source: "image://theme/icon-m-diagnostic"
    anchors {
      verticalCenter: public_key_present_icon.verticalCenter
      left: position_icon.right
      leftMargin: Theme.paddingExtraSmall
    }
    height: node_short_name_label.height * 0.8
    width: height
    visible: uptime_seconds != 0
    color: Theme.primaryColor
  }

  Icon {
    id: role_icon
    source: role_image_source(role)
    anchors {
      verticalCenter: public_key_present_icon.verticalCenter
      left: telemetry_icon.right
      leftMargin: Theme.paddingExtraSmall
    }
    height: node_short_name_label.height * 0.8
    width: height
    visible: role >= 0
    color: Theme.primaryColor
  }

  SequentialAnimation {
    id: busy_animation
    loops: Animation.Infinite
    running: false
    //PropertyAnimation {target: status_icon; property: "opacity"; from: 1.0; to: 0.0; duration: 500 }
    //PropertyAnimation {target: status_icon; property: "opacity"; from: 0.0; to: 1.0; duration: 500 }

    onStopped: {
      //status_icon.opacity = 1.0
    }
  }

  onClicked: {
   
  }

  Component.onCompleted: {
    
  }

  function last_heard_s(timestamp) {
    var seen_minutes = Math.round((new Date().getTime()/1000-timestamp)/60)

    if (seen_minutes == 0) {
      return 'now'
    } else if (seen_minutes < 60) {
      return seen_minutes + ' min'
    } else {
      return Math.floor(seen_minutes/60) + ' h'
    }
  }

  function role_image_source(role_id) {
    switch(role_id) {
      case 0: //client
        return "image://theme/icon-m-media-radio"
      case 1: //client mute
        return "image://theme/icon-m-mic-mute"
      case 2:
      case 3: //router
        return "image://theme/icon-m-global-proxy"
      case 4: //repeater
        return "image://theme/icon-m-sync"
      case 5: //tracker
        return "image://theme/icon-m-browser-location"
      case 6: //sensor 
        return "image://theme/icon-m-home"
      case 7: //tak 
        return "image://theme/icon-m-browser-permissions"
      case 8: //client hidden 
        return "image://theme/icon-splus-hide-password"
      case 9: //lost and found 
        return "image://theme/icon-m-browser-location-template"
      case 10: //tak tracker
        return "image://theme/icon-m-browser-permissions"
      default:
        return "image://theme/icon-m-share"
    } 
   
  }
}
