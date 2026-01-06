import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
  id: messages_tab_item

  //height: parent.height /2

  property alias channel_index_ob: chat_input_widget.channel_index_ob
  property alias reply_to: chat_input_widget.message_to

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

  function humanize_date(timestamp) {
    var date = new Date(timestamp);

    var days = "0" + date.getDate();
    var months = "0" + (date.getMonth() + 1);
    var years = date.getFullYear();
    var hours = date.getHours();
    var minutes = "0" + date.getMinutes();
    var seconds = "0" + date.getSeconds();

   return days.substr(-2) + '-' + months.substr(-2) + '-' + years + ' ' + hours + ':' + minutes.substr(-2) + ':' + seconds.substr(-2);
  }

  function humanize_date_only(timestamp) {
    if (isNaN(timestamp)) {
      return "01.01.1970";
    }

    var date = new Date(timestamp);

    var days = "0" + date.getDate();
    var months = "0" + (date.getMonth() + 1);
    var years = date.getFullYear();

   return days.substr(-2) + '-' + months.substr(-2) + '-' + years;
  }

  SilicaListView {
    id: list_view

    model: list_model
    width: parent.width

    //height: 500

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

    ViewPlaceholder {
      enabled: list_model.count == 0
      text: "Messages"
      hintText: ""
    }

    onContentYChanged: {
      //console.debug(contentY)
    }
  }

  ChatInputWidget {
    id: chat_input_widget

    visible: true
    
    anchors {
      bottom: parent.bottom
    }
  }


  ListModel {
    id: list_model
  }

  Timer {
    id: sort_timer
    interval: 500
    repeat: false
    triggeredOnStart: false
    onTriggered: {
      sort_messages()
    }
  }

  Timer {
    id: scroll_timer
    interval: 500
    repeat: false
    triggeredOnStart: false
    onTriggered: {
      list_view.scrollToBottom();
    }
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
    load_messages(app.messages)
    scroll_timer.restart()
  }

  Component.onDestruction: {
    app.signal_text_message_in.disconnect(handle_text_message_in)
    app.signal_text_message_out.disconnect(handle_text_message_out)
  }
  
  function create_record(message_type, instance, optional_attributes) {
    var record = { 
      'message': null,
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

  function create_section(section_name, timestamp) {
    return humanize_date_only(timestamp) + ';' + section_name;
  }

  function handle_text_message_in(message) {
    var instance = null

    console.log("handle_text_message_in - text message - id:", message.id, "from:", message.from.toString(16), "to:", message.to.toString(16), "message_text:", message.decoded.payload, 'rx_time:', humanize_date(message.rx_time * 1000));

    var node = app.nodes[message.from.toString(16)]
    var channel_name = 'direct';

    if (message.channel) {
      var channel = app.channels[message.channel]
      if (channel && channel.settings) {
        channel_name = String(channel.settings.name) || String(message.channel)
        chat_input_widget.update_channel_name(channel_name)
        channel_index_ob = message.channel
        reply_to = 4294967295
      }
    } else {
      reply_to = message.from
      channel_name = node && node.user ?  String(node.user.short_name) : message.from.toString(16)
      chat_input_widget.update_channel_name(channel_name)
      channel_index_ob = -1
      console.log('reply_to set to:', reply_to)
    }

    list_model.append(create_record('text', instance, {'message': message, 'message_id': message.id, 'message_from': message.from.toString(16), 'message_to': message.to.toString(16), 'channel_name': channel_name, 'timestamp': new Date(message.rx_time * 1000), "message_text": String(message.decoded.payload), "is_tx": false, 'section_data': create_section(channel_name, message.rx_time * 1000) }));

    if (list_view.atYEnd) {
      list_view.scrollToBottom();
      scroll_timer.restart()
    }
  }

  function handle_text_message_out(message) {
    var instance = null

    var node = app.nodes[message.to.toString(16)]

    console.log('handle_text_message_out - node:', node)
    var channel_name = node && node.user ? String(node.user.short_name) : message.to.toString(16)
    console.log('handle_text_message_out - 1 channel_name:', channel_name)

    if (message.channel) {
      var channel = app.channels[message.channel]
      if (channel && channel.settings) {
        channel_name = String(channel.settings.name) || String(message.channel)
      }
    }

    console.log('handle_text_message_out - 2 channel_name:', channel_name)

    console.log("handle_text_message_out - text message - id:", message.id, "from:", message.from ? message.from.toString(16) : '', "message_text:", message.text);

    if (!list_model) return;
    list_model.append(create_record('text', instance, { 'message_id': message.id, 'message_from': message.from ? message.from.toString(16) : '', 'message_to': message.to.toString(16), 'channel_name': channel_name, 'timestamp': new Date(message.tx_time * 1000), "message_text": String(message.text), "is_tx": true, 'section_data': create_section(channel_name, message.tx_time * 1000) }));

    list_view.scrollToBottom();
    scroll_timer.restart()
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

  function place_timestamp(messages_a, timestamp) {
    for (var i = 0; i < 1024; i++) {
      if (!messages_a[timestamp + i]) return timestamp
      if (!messages_a[timestamp - i]) return timestamp
    } 
  }

  function load_messages(messages) {
    var messages_a = []

    for (var message_id in messages) {
      if (messages.hasOwnProperty(message_id)) {
        var timestamp = place_timestamp(messages_a, messages[message_id].tx_time || messages[message_id].rx_time || 0)
        if (messages[message_id].tx_time) {
          messages_a[messages[message_id].tx_time] = messages[message_id]
        } else {
          messages_a[messages[message_id].rx_time] = messages[message_id]
        }
      }
    }
    

    for (var index in messages_a) {
      console.log('MESSAGE index:', index)
      if (messages_a[index].tx_time) {
        handle_text_message_out(messages_a[index])
      } else {
        handle_text_message_in(messages_a[index])
      }
    }
  }

  function sort_messages() {
    for (var index = 0; index < list_model.rowCount(); index++) {
      var found_index = find_newest(index)
      if (found_index > index) {
        list_model.move(found_index, index, 0)
      } 
    }
  }

  function find_newest(start_index) {
    var new_time = 0
    var new_index = 0
    
    for (var index = start_index; index < list_model.rowCount(); index++) {
      var list_item = list_model.get(index);
      if (list_item.timestamp > new_time) {
        new_time = list_item.timestamp
        new_index = index
      }
    }

    return new_index
  }
}
