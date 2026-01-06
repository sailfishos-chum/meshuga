import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

Item {
  id: chat_input_widget
  width: parent.width
  height: send_icon.height

  property int channel_index_ob: -1
  property var message_to: 4294967295

  IconButton {
    id: send_icon
    icon.source: "image://theme/icon-m-send"
    anchors {
      right: parent.right
      top: parent.top
    }
    onClicked: send_message();
  }

  TextField {
    id: input_field

    width: parent.width * 0.8

    placeholderText: "Message"
    inputMethodHints: Qt.ImhNoAutoUppercase

    anchors {
      left: parent.left
      right: parent.right
      top: parent.top
      topMargin: Theme.paddingSmall
      rightMargin: send_icon.width
      leftMargin: 0
    }

    onTextChanged: {
      
    }
    
    onClicked: {
      forceActiveFocus()            
      visible = true
      readOnly = false
    }

    EnterKey.onClicked: {
      input_field.focus = false
    }
  }

  function send_message() {
    app.settings.last_message_id_out = parseInt(app.settings.last_message_id_out) + 1
    var message_text = input_field.text.trim();

    if (message_text.length > 0) { 
      console.log('sending text message:', message_text)
      var message = {'to': message_to, 'text': message_text, 'id': app.settings.last_message_id_out, 'tx_time': Math.floor(new Date().getTime() / 1000)}
      if (channel_index_ob > -1) {
        message['channel'] = channel_index_ob
      }
      app.signal_text_message_out(message)
    }

    input_field.text = '';
  }

  function update_channel_name(channel_name) {
    input_field.placeholderText = channel_name
  }
}
