import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0                                                                                              
 
Item {
  id: item

  property bool isCurrentItem

  anchors.fill: parent

  SilicaListView {
    id: list_view

    anchors.fill: parent

    VerticalScrollDecorator {}

    model: nodes_model

    delegate: NodeItem {
      max_index:  nodes_model.rowCount()
    }

    ViewPlaceholder {
      enabled: nodes_model.count == 0
      text: "Nodes"
      hintText: "Meshuga"
    }
  }

  ListModel {
    id: nodes_model
  }

  Timer {
    id: sort_timer
    interval: 500
    repeat: false
    triggeredOnStart: false
    onTriggered: {
      sort_nodes()
    }
  }

  Timer {
    id: update_last_heard_timer
    interval: 30000
    repeat: true
    triggeredOnStart: false
    onTriggered: {
      update_last_heard()
    }
  }

  Component.onCompleted: {
    app.signal_config_complete.connect(handle_config_complete)
    app.signal_node_update.connect(handle_node_update)
    app.signal_my_node_update.connect(handle_my_node_update)
    app.signal_telemetry_update.connect(handle_telemetry_update)
    app.signal_position_update.connect(handle_position_update)

    load_nodes()
    app.signal_ui_complete()
  }

  Component.onDestruction: {
    app.signal_config_complete.disconnect(handle_config_complete)
    app.signal_node_update.disconnect(handle_node_update)
    app.signal_my_node_update.disconnect(handle_my_node_update)
    app.signal_telemetry_update.disconnect(handle_telemetry_update)
    app.signal_position_update.disconnect(handle_position_update)
  }

  function load_nodes() {
    nodes_model.insert(0, {
      "updated_at": Math.round((new Date().getTime()/1000)),
      "local": true,
      "node": new Object(),
      "num": 0,
      "num_h": '',
      "last_heard": 0,
      "hops_away": -1,
      "snr": 0.0,
      "public_key_present": false,
      "short_name": 'local',
      "long_name": "",
      "latitude": 0.0,
      "longitude": 0.0,
      "altitude": 0.0,
      "position_updated": 0,
      "battery_level": 0.0,
      "voltage": 0.0,
      "channel_utilization": 0.0,
      "air_util_tx": 0.0,
      "uptime_seconds": 0,
      "role": -1,
    })

    for (var node_number in app.nodes) {
      if (nodes.hasOwnProperty(node_number)) {
        if (nodes[node_number].local) {
          var node = nodes[node_number]
          var list_item = nodes_model.get(0)
          list_item.updated_at = Math.round((new Date().getTime()/1000))
          list_item.node = node
          list_item.last_heard = node.last_heard
          list_item.last_heard = node.last_heard
          list_item.hops_away = node.hops_away != null ? node.hops_away : -1
          list_item.snr = parseFloat(node.snr) || 0.0
          list_item.public_key_present = node.user && node.user.public_key
          list_item.short_name = node.user ? String(node.user.short_name) : node.num.toString(16)
          list_item.long_name = node.user ? String(node.user.long_name) : ""
          list_item.role = node.user && node.user.role ? parseInt(node.user.role) : -1
        } else {
          add_node(nodes[node_number])
        }
      }
    }
  }

  function handle_config_complete() {
    sort_timer.stop()
    sort_nodes()
    update_last_heard_timer.restart()
  }

  function handle_node_update(node) {
    var list_item = null;

    if (is_local(node)) {
      list_item = nodes_model.get(0)
      node.local = true
    } else {
      list_item = item_by_node_num(node.num)
    }

    if (!list_item || list_item.num != node.num) {
      add_node(node)
    } else {
      list_item.updated_at = Math.round((new Date().getTime()/1000))
      list_item.node = node
      list_item.last_heard = node.last_heard
      list_item.last_heard = node.last_heard
      list_item.hops_away = node.hops_away != null ? node.hops_away : -1
      list_item.snr = parseFloat(node.snr) || 0.0
      list_item.public_key_present = node.user && node.user.public_key
      list_item.short_name = node.user ? String(node.user.short_name) : node.num.toString(16)
      list_item.long_name = node.user ? String(node.user.long_name) : ""
      list_item.role = node.user && node.user.role ? parseInt(node.user.role) : -1
    }

    sort_timer.restart()
  }

  function handle_my_node_update(node) {
    console.log('NodesPage handle_my_node_update:', node.my_node_num)

    app.my_node = node

    var list_item = nodes_model.get(0)

    if (!list_item || !list_item.local) {
      list_item = item_by_node_num(node.my_node_num)
    }

    if (!list_item) {
      nodes_model.insert(0, {
        "updated_at": Math.round((new Date().getTime()/1000)),
        "local": true,
        "node": node,
        "num": node.my_node_num,
        "num_h": node.my_node_num.toString(16),
        "last_heard": node.last_heard || 0,
        "hops_away": -1,
        "snr": 0.0,
        "public_key_present": false,
        "short_name": 'local',
        "long_name": "",
        "latitude": 0.0,
        "longitude": 0.0,
        "altitude": 0.0,
        "position_updated": 0,
        "battery_level": 0.0,
        "voltage": 0.0,
        "channel_utilization": 0.0,
        "air_util_tx": 0.0,
        "uptime_seconds": 0,
        "role": -1,
      })
    } else {
      list_item.node = node
      list_item.num = node.my_node_num
      list_item.num_h = node.my_node_num.toString(16)
      list_item.last_heard = node.last_heard
    }
  }

  function add_node(node) {
    nodes_model.append({
      "updated_at": Math.round((new Date().getTime()/1000)),
      "local": false,
      "node": node,
      "num": node.num,
      "num_h": node.num.toString(16),
      "last_heard": node.last_heard || 0,
      "hops_away": node.hops_away != null ? node.hops_away : -1,
      "snr": parseFloat(node.snr) || 0.0,
      "public_key_present": node.user && node.user.public_key && node.user.public_key != null,
      "short_name": node.user ? String(node.user.short_name) : node.num.toString(16),
      "long_name": node.user ? String(node.user.long_name) : "",
      "latitude": node.position && node.position.latitude_i ? node.position.latitude_i/10000000 : 0.0,
      "longitude": node.position && node.position.longitude_i ? node.position.longitude_i/10000000 : 0.0,
      "altitude": node.position && node.position.altitude ? node.position.altitude : 0,
      "position_updated": node.position && node.position.time ? node.position.time : 0,
      "battery_level": node.device_metrics && node.device_metrics.battery_level ? node.device_metrics.battery_level : 0.0,
      "voltage": node.device_metrics && node.device_metrics.voltage ? node.device_metrics.voltage : 0.0,
      "channel_utilization": node.device_metrics && node.device_metrics.channel_utilization ? node.device_metrics.channel_utilization : 0.0,
      "air_util_tx": node.device_metrics && node.device_metrics.air_util_tx ? node.device_metrics.air_util_tx : 0.0,
      "uptime_seconds": node.device_metrics && node.device_metrics.uptime_seconds ? node.device_metrics.uptime_seconds : 0.0,
      "role": node.user && node.user.role ? parseInt(node.user.role) : -1
    })
  }

  function item_by_node_num(node_num) {
    for (var index = 0; index < nodes_model.rowCount(); index++) {
      var list_item = nodes_model.get(index);
      if (list_item.num_h == node_num.toString(16)) return list_item;
    }

    return null
  }

  function sort_nodes() {
    for (var index = 1; index < nodes_model.rowCount(); index++) {
      var found_index = find_newest(index)
      if (found_index > index) {
        nodes_model.move(found_index, index, 1)
      } 
    }
  }

  function find_newest(start_index) {
    var new_time = 0
    var new_index = 0
    
    for (var index = start_index; index < nodes_model.rowCount(); index++) {
      var list_item = nodes_model.get(index);
      if (list_item.last_heard > new_time) {
        new_time = list_item.last_heard
        new_index = index
      }
    }

    return new_index
  }

  function update_last_heard() {
    for (var index = 0; index < nodes_model.rowCount(); index++) {
      var list_item = nodes_model.get(index);
      if (!list_item) {
        continue;
      }
      
      list_item.updated_at = Math.round((new Date().getTime()/1000))
    }
  }

  function handle_telemetry_update(packet) {
    var list_item = item_by_node_num(packet.from)
    if (!list_item) {
      return
    }

    if (packet.decoded && packet.decoded.payload) {
      if (app.nodes[packet.from]) {
        app.nodes[packet.from].device_metrics = packet.decoded.payload
      }

      list_item.node.device_metrics = packet.decoded.payload

      list_item.battery_level = list_item.node.device_metrics && list_item.node.device_metrics.battery_level ? list_item.node.device_metrics.battery_level : 0.0
      list_item.voltage = list_item.node.device_metrics && list_item.node.device_metrics.voltage ? list_item.node.device_metrics.voltage : 0.0
      list_item.channel_utilization = list_item.node.device_metrics && list_item.node.device_metrics.channel_utilization ? list_item.node.device_metrics.channel_utilization : 0.0
      list_item.air_util_tx = list_item.node.device_metrics && list_item.node.device_metrics.air_util_tx ? list_item.node.device_metrics.air_util_tx : 0.0
      list_item.uptime_seconds = list_item.node.device_metrics && list_item.node.device_metrics.uptime_seconds ? list_item.node.device_metrics.uptime_seconds : 0.0
    }

    

    list_item.last_heard = packet.rx_time
    sort_timer.restart()
  }

  function handle_position_update(packet) {
    var list_item = item_by_node_num(packet.from)
    if (!list_item) {
      return
    }

    if (packet.decoded && packet.decoded.payload) {
      if (app.nodes[packet.from]) {
        app.nodes[packet.from].position = packet.decoded.payload
      }

      list_item.node.position = packet.decoded.payload

      list_item.latitude = list_item.node.position.latitude_i ? list_item.node.position.latitude_i/10000000 : 0.0
      list_item.longitude = list_item.node.position.longitude_i ? list_item.node.position.longitude_i/10000000 : 0.0
      list_item.altitude = list_item.node.position.altitude ? list_item.node.position.altitude : 0
      list_item.position_updated = list_item.node.position.time ? list_item.node.position.time : 0
    }

    list_item.last_heard = packet.rx_time
    sort_timer.restart()
  }

  function is_local(node) {
    if (!app.my_node || !app.my_node.my_node_num) {
      return false
    }

    return node.num === app.my_node.my_node_num
  }
}
