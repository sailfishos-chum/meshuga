import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

Dialog {
  id: settings_dialog

  property string device_address
  property int device_port
  
  RemorseItem { id: remorse_item }  


  SilicaFlickable {
    anchors.fill: parent

    contentHeight: main_column.height

    VerticalScrollDecorator {}

    DialogHeader {
      id: header
      title: "Settings"
    }

    Column {
      id: main_column

      width: parent.width
      
      anchors {
        top: header.bottom
      }

      SectionHeader {
        text: "Settings"
      }

      TextField {
        id: device_address_field
        width: parent.width
        text: device_address
        label: "Device Address"
        placeholderText: "Device Address or Domain Name"
        inputMethodHints: Qt.ImhNoAutoUppercase
        validator: RegExpValidator { regExp: /.{1,}/ }
        Keys.onReturnPressed: {

        }
        //onTextChanged: device_address = device_address_field.text
      }

      TextField {
        id: device_port_field
        width: parent.width
        text: device_port
        label: "Device Port"
        placeholderText: "Device Port"
        inputMethodHints: Qt.ImhDigitsOnly
        //validator: IntValidator {bottom: 0; top: 65534;}
        Keys.onReturnPressed: {

        }
        //onTextChanged: device_port = parseInt(device_port_field.text) || 4403
      }
    }
  }

  onOpened: {
    console.log("SettingsDialog opened")
    device_address = app.settings.device_address || 'meshtastic.local'
    device_port = parseInt(app.settings.device_port)

    if (device_port < 1) {
      device_port = 4403;
    }
  }

  onAccepted: {
    console.log("SettingsDialog accepted")
    app.settings.device_address = device_address_field.text
    app.settings.device_port = parseInt(device_port_field.text) || 4403

    app.signal_error('main', 'startup', 'Please restart Meshuga for settings to take effect!');
  }

  onRejected: {
    console.log("SettingsDialog rejected")
  }

  onDone: {
    console.log("SettingsDialog done")
  }

  onStatusChanged: {
    
  }
}
