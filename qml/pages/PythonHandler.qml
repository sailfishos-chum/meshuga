import QtQuick 2.0
import io.thp.pyotherside 1.5

Python {
  id: python

  property bool ui_started: false
  property int start_sequence: 0

  Component.onCompleted: {
    setHandler('error', error_handler);
    setHandler('start_sequence', handle_start_sequence);
    setHandler('config_complete_id', handle_config_complete_id);
    setHandler('node_update', handle_node_update);
    setHandler('my_node_update', handle_my_node_update);
    setHandler('telemetry_update', handle_telemetry_update);
    setHandler('position_update', handle_position_update);
    setHandler('new_text_message', handle_text_message_in);
    setHandler('channel_config', handle_channel_config);

    addImportPath(Qt.resolvedUrl('../src'));
    
    importModule('settings', function () {
      app.settings = call_sync('settings.settings_object.load_settings', [])
      app.nodes = call_sync('settings.settings_object.load_nodes', [])
      app.messages = call_sync('settings.settings_object.load_messages', [])
    });

    importModule('meshuga', function () {
      var settings = {
        'device_address': app.settings.device_address,
        'device_port': app.settings.device_port,
      }
      call('meshuga.meshuga_object.start', [settings]);
    });

    app.signal_ui_complete.connect(handle_ui_complete)
    app.signal_text_message_out.connect(handle_text_message_out)
  }

  Component.onDestruction: {
    app.signal_ui_complete.disconnect(handle_ui_complete)
    app.signal_text_message_out.disconnect(handle_text_message_out)

    call('meshuga.meshuga_object.stop', []);
    save_settings(app.settings)
    save_nodes(app.nodes)
    save_messages(app.messages)
  }

  onError: {
    console.log('ERROR - unhandled error received:', traceback);
  }

  onReceived: {
    console.log('ERROR - unhandled data received:', data);  
  }

  function error_handler(module_id, method_id, description) {
    console.log('Module ERROR - source:', module_id, method_id, 'error:', description);
    app.signal_error(module_id, method_id, description);
  }

  function handle_start_sequence(sequence) {
    console.log("handle_start_sequence:", sequence)
    start_sequence = sequence
    if (sequence == 2 && ui_started) {
      call('meshuga.meshuga_object.want_config', []);
    }
  }

  function handle_ui_complete() {
    console.log("handle_ui_complete")
    ui_started = true
    if (start_sequence >= 2) {
      call('meshuga.meshuga_object.want_config', []);
    }
  }

  function handle_config_complete_id(config_complete_id) {
    console.log("config_complete_id:", config_complete_id)
    app.signal_config_complete()
  }

  function handle_node_update(node) {
    app.nodes[node.num.toString(16)] = node
    app.signal_node_update(node)
  }

  function handle_my_node_update(node) {
    app.node_number = node.my_node_num
    console.log("handle_my_node_update - node number:", node.my_node_num)
    app.signal_my_node_update(node)
  }

  function handle_channel_config(channel) {
    // {'index': 1, 'settings': {'psk': b'8x\xefa$tU\xb2t\xfaRo\xce\xb4G\x05_i8\xee\xe5o1N\x15\xf4\x85\xb4\x06#\xf0k', 'name': b'golwen.net', 'uplink_enabled': True, 'downlink_enabled': True, 'module_settings': {'position_precision': 32}}, 'role': 2}

    var channel_index = channel.index || 0
    app.channels[channel_index] = channel
    console.log("handle_channel_config - channel index:", channel.index || 0, 'role:', channel.role, 'name:', channel.settings.name)

  }

  function handle_telemetry_update(packet) {
    console.log("handle_telemetry_update - node number:", packet.from)
    app.signal_telemetry_update(packet)
  }

  function handle_position_update(packet) {
    console.log("handle_position_update - node number:", packet.from)
    app.signal_position_update(packet)
  }

  function handle_text_message_in(text_message) {
    console.log("handle_text_message_in - from:", text_message.from, 'channel:', text_message.channel, 'text:', text_message.decoded.payload)
    app.messages[text_message.id] = text_message
    app.signal_text_message_in(text_message)
  }

  function handle_text_message_out(text_message) {
    console.log("handle_text_message_out - from:", text_message.from, 'channel:', text_message.channel, 'text:', text_message.text)
    app.messages[text_message.id] = text_message
    call('meshuga.meshuga_object.text_message_send', [text_message]);
  }

  function save_settings(settings) {
    call_sync('settings.settings_object.save_settings', [settings])
  }

  function save_nodes(nodes) {
    call_sync('settings.settings_object.save_nodes', [nodes])
  }

  function save_messages(messages) {
    call_sync('settings.settings_object.save_messages', [messages])
  }
}

