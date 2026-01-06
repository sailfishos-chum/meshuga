import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.3
import "pages"

ApplicationWindow {
  id: app

  signal signal_error(string module_id, string method_id, string description)
  signal signal_ui_complete()
  signal signal_config_complete()
  signal signal_node_update(var node)
  signal signal_my_node_update(var node)
  signal signal_telemetry_update(var packet)
  signal signal_position_update(var packet)
  signal signal_text_message_in(var text_message)
  signal signal_text_message_out(var text_message)

  property string version: '0.2'
  property var settings: {'created_at': null, 'last_message_id_out': 0}
  property int node_number: 0
  property var my_node: new Object()
  property var nodes: new Object()
  property var channels: new Object()
  property var messages: new Object()

  PythonHandler {
    id: python
  }

  NotificationsHandler {
    id: notifications_handler
  }

  initialPage: Component { 
    id: initial_page

    MainPage {
      id: main_page
    }
  }
  
  cover: Component { 
    id: cover_component

    CoverPage {
      id: cover_page
    } 
  }

  Component.onCompleted: {
    Qt.application.name = "meshuga";
    Qt.application.organization = "app.qml";
  }
}
