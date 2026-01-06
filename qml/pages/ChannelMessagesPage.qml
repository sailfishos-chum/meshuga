import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
  id: messages_page

  height: parent.height /2

  property int test_test: 0

  function humanize_time(time) {   
    var hrs = ~~(time / 3600);
    var mins = ~~((time % 3600) / 60);
    var secs = ~~time % 60;

    var ret = "";

    if (hrs > 0) {
      ret += "" + hrs + ":" + (mins < 10 ? "0" : "");
    }

    ret += "" + mins + ":" + (secs < 10 ? "0" : "");
    ret += "" + secs;
    return ret;
  }

  SilicaListView {
    id: list_view

    model: list_model
    width: parent.width

    clip: true
    anchors {
      top: parent.top
      bottom: chat_input_widget.top
    }

    spacing: Theme.paddingMedium

    currentIndex: -1

    section {
      property: "section_data"
      criteria: ViewSection.FullString
      delegate: ConversationsSectionWidget {
        date:  section.split(';')[0];
        channel_name: section.split(';')[1];
      }
    }

    delegate: Loader {
      id: loader

      height: childrenRect.height
      width: parent.width
      sourceComponent: {
        switch(message_type) {
        case 'text':
          return message_text_widget;
        case 'location':
          return message_location_widget;
        }
      }

      property int    l_time_count: time_count
      property var    l_updated: updated
      property bool   l_receiving: receiving
      property string   l_data_b: data_b

      onLoaded: {
        switch(message_type) {
        case 'text':
          loader.item.message_from = message_from
          loader.item.message_to = message_to
          loader.item.timestamp = timestamp
          loader.item.message_text = message_text
          loader.item.is_tx = is_tx
          break;
        case 'location':
          loader.item.message_from = message_from
          loader.item.message_to = message_to
          loader.item.timestamp = timestamp
          loader.item.latitude = latitude
          loader.item.longitude = longitude
          loader.item.accuracy = accuracy
          loader.item.formatted_address = formatted_address
          loader.item.is_tx = is_tx
          break;
        default:
          loader.item.message_from = message_from
          loader.item.message_to = message_to
          loader.item.timestamp = timestamp
          loader.item.is_tx = is_tx
        }
      }
    }
    
    MessageTextWidget{ id: message_text_widget }
    MessageLocationWidget{ id: message_location_widget }

    VerticalScrollDecorator {}

    Component.onCompleted: {
      
    }

    onContentYChanged: {
      //console.debug(contentY)
    }

  }

  ChatInputWidget {
    visible: true
    id: chat_input_widget

    anchors {
      bottom: parent.bottom
    }
  }


  ListModel {
    id: list_model
  }

  Component {
      id: sectionHeading
      Rectangle {
          width: container.width
          height: childrenRect.height
          color: Theme.highlightColor

          Text {
            text: section
            font.bold: true
            font.pixelSize: 20
          }
      }
  }

  Component.onCompleted: {
    console.log('MessagesTab completed')
    app.signal_text_message_in.connect(handle_text_message_in)
    app.signal_text_message_out.connect(handle_text_message_out)
    list_view.positionViewAtEnd();
  }

  Component.onDestruction: {
    app.signal_text_message_in.disconnect(handle_text_message_in)
    app.signal_text_message_out.disconnect(handle_text_message_out)
  }
  
  function create_record(message_type, instance, optional_attributes) {
    var record = { 
      'message_type': message_type, 
      'instance': instance,
      'timestamp': new Date(), 
      'updated': new Date(),
      'is_tx': false,
      'stream_id': 0,
      'message_id': 0,
      'message_from': '', 
      'message_to': '', 
      'channel_name': '', 
      'time_count': 0, 
      'receiving': false, 
      'message_text': '',
      'latitude': 0, 
      'longitude': 0,
      'accuracy': 0,
      'formatted_address': '',
      'image_source': '',
      'image_format': '',
      'data_b': '',
      'section_data': '',
    };

    for (var key in optional_attributes) {
      if (key in record) {
        record[key] = optional_attributes[key];
      } else {
        console.error('ERROR no such attribute: ', key)
      }
    }

    return record;
  }

  function create_section(channel_name) {
    return new Date().toLocaleString(Qt.locale(), 'dd.MM.yyyy') + ';' + channel_name;
  }

  function handle_text_message_in(message) {
    var instance = null

    console.log("handle_text_message_in - text message - id:", message.id, "from:", message.from.toString(16), "to:", message.to.toString(16), "message_text:", message.decoded.payload, 'test:', test_test);

    if (!list_model) return;

    var channel_name = 'direct';

    if (message.channel) {
      var channel = app.channels[message.channel]
      if (channel && channel.settings) {
        channel_name = channel.settings.name || String(message.channel)
      }
    }

    list_model.append(create_record('text', instance, { 'message_id': message.id, 'message_from': message.from.toString(16), 'message_to': message.to.toString(16), 'channel_name': channel_name, 'timestamp': new Date(message.rx_time * 1000), "message_text": String(message.decoded.payload), "is_tx": false, 'section_data': create_section(channel_name) }));

    if (list_view.atYEnd) {
      list_view.positionViewAtEnd();
    }
  }

  function handle_text_message_out(message) {
    var instance = null

    console.log("handle_text_message_out - text message - id:", message.id, "from:", message.from ? message.from.toString(16) : '', "message_text:", message.text);

    if (!list_model) return;
    list_model.append(create_record('text', instance, { 'message_id': message.id, 'message_from': message.from ? message.from.toString(16) : '', 'message_to': message.to.toString(16), 'channel_name': message.channel, 'timestamp': new Date(message.tx_time * 1000), "message_text": String(message.text), "is_tx": true, 'section_data': create_section(message.channel) }));

    list_view.positionViewAtEnd();
  }

  function on_location_message(instance, message_id, channel_name, from, recipient, latitude, longitude, accuracy, formatted_address, is_tx) {
    console.log("Conversations - location message - id:", message_id, "from:", from);

    if (!list_model) return;
    list_model.append(create_record('location', instance, { 'message_id': message_id, 'from': from, 'channel_name': channel_name, 'latitude': latitude, 'longitude': longitude, 'accuracy': accuracy, 'formatted_address': formatted_address, 'is_tx': is_tx, 'section_data': create_section(channel_name) }));

    if (list_view.atYEnd) {
      list_view.positionViewAtEnd();
    }
  }

  function get_message(message_id) {
    for(var index = list_model.rowCount() -1; index >= 0; index--) {
      var message = list_model.get(index);
      if (message && message.message_id == message_id) {
        return message;
      }
    }

    return null;
  }
}