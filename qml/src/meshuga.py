# -*- coding: utf-8 -*-
import pyotherside
import threading
import time
import socket
import meshtastic

HOST = "meshtastic.local" 
PORT = 4403

class Meshuga:
  def __init__(self):
    print('meshuga init')
    self.run_loop = False
    self.mynode = {}
    self.nodes = {}
    self.conn = None
    self.last_message_id_sent = 1000
    self.device_address = HOST
    self.device_port = PORT
    pyotherside.send("start_sequence", 1)
    
  def start(self, settings):
    if (not settings['device_port'] or not settings['device_address']):
      return
      
    self.device_address = settings['device_address']
    self.device_port = int(settings['device_port'])
    print('meshuga start - using device: %s:%d' % (self.device_address, self.device_port))
    self.run_loop = True
    self.bg_loop = threading.Thread(target=self.listener)
    self.bg_loop.start()
    pyotherside.send("start_sequence", 2)

  def stop(self):
    print('meshuga stop')
    self.run_loop = False
    if self.bg_loop:
      self.bg_loop.join()

  def send(self, data):
    try:
      self.conn.sendall(data)
    except Exception as err:
      pyotherside.send("error", "meshuga", "send", str(err))

  def want_config(self):
    print('meshuga get_config')
    if self.conn:
      self.send(meshtastic.create_stream_want_config_id(507381257))

  def listener(self):
    msg_reset = bytes.fromhex('c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3')

    self.conn = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    self.conn.connect((self.device_address, self.device_port))
    self.send(msg_reset)
    self.conn.settimeout(1.0)

    hb_time = time.time()
    while self.run_loop:
      if time.time() - hb_time > 30:
        print('SEND heartbeat:', meshtastic.create_stream_heartbeat())
        self.send(meshtastic.create_stream_heartbeat())
        hb_time = time.time()
        
      try:
        data = self.conn.recv(512)
      except socket.timeout:
        continue

      if not data:
        continue

      packet = meshtastic.decode_stream_packet(data)
      if not packet:
        continue
      
      #print('packet:', packet)

      for rt in packet:
        if type(rt) == int:
          self.handle_stream_packet(rt, packet[rt])
        elif rt == 'repeated':
          for record in packet[rt]:
            for rtr in record:
              if type(rtr) == int:
                self.handle_stream_packet(rtr, record[rtr])
  
  
  def handle_stream_packet(self, rt, packet):
    if rt == 1:
      print('PACKET id:', packet)
    
    elif rt == 2:
      mp = meshtastic.decode_mesh_packet(packet)
      if 'decoded' in mp and mp['decoded'] and 'portnum' in mp['decoded']:
        if mp['decoded']['portnum'] == meshtastic.PORT_TEXT_MESSAGE_APP:
          message = mp['decoded']['payload'].decode()
          self.info('IN message - ', mp, '_rx_time', '_from', '_to', '_channel', 'text: ', message)
          print(mp)
          pyotherside.send("new_text_message", mp)
        elif mp['decoded']['portnum'] == meshtastic.PORT_TELEMETRY_APP:
          self.info('TELEMETRY packet - ', mp, '_rx_time', '_from', '_to', '_channel', 'payload: ', mp['decoded']['payload'])
          mp['decoded']['payload'] = meshtastic.decode_telemetry_packet(mp['decoded']['payload'])
          pyotherside.send("telemetry_update", mp)
        elif mp['decoded']['portnum'] == meshtastic.PORT_NODEINFO_APP:
          self.info('NODEINFO packet - ', mp, '_rx_time', '_from', '_to', '_channel', 'payload: ', mp['decoded']['payload'])
          print(mp)
        elif mp['decoded']['portnum'] == meshtastic.PORT_POSITION_APP:
          self.info('POSITION packet - ', mp, '_rx_time', '_from', '_to', '_channel', 'payload: ', mp['decoded']['payload'])
          mp['decoded']['payload'] = meshtastic.decode_position_info(mp['decoded']['payload'])
          pyotherside.send("position_update", mp)
        elif mp['decoded']['portnum'] == meshtastic.PORT_ROUTING_APP:
          self.info('ROUTING packet - ', mp, '_rx_time', '_from', '_to', '_channel', 'payload: ', mp['decoded']['payload'])
          print(meshtastic.decode(mp['decoded']['payload']))
        else:
          self.info('DATA packet - ', mp, 'port: ', str(mp['decoded']['portnum']), ' ', '_rx_time', '_from', '_to', '_channel', 'payload: ', mp['decoded']['payload'])
      elif 'encrypted' in mp:
        self.info('IN message - ', mp, '_rx_time', '_from', '_to', '_channel', '_encrypted')
      else:
        print('ERROR unhandled mesh packet:', mp)

    elif rt == 3:
      ni = meshtastic.decode_my_node_info(packet)
      if not 'my_node_num' in ni or not ni['my_node_num'] or not 'reboot_count' in ni or not 'min_app_version' in ni:
        return False

      self.info('LOCAL node - ', ni, '_my_node_num', '_reboot_count', '_min_app_version', '_pio_env')
      self.mynode = ni
      pyotherside.send("my_node_update", ni)
      print(ni)

    elif rt == 4:
      ni = meshtastic.decode_node_info(packet)
      if 'num' in ni:
        if ni['num'] not in self.nodes:
          self.nodes[ni['num']] = {}
          #self.info('NEW node - ', ni, str(len(self.nodes)), ' ', '_num', '_last_heard')
        else:
          self.info('UPDATE node - ', ni, '_num', '_last_heard')
        
        self.nodes[ni['num']].update(ni)
        pyotherside.send("node_update", ni)
        #print(ni)

    elif rt == 5:
      cf = meshtastic.decode(packet)
      if 1 in cf:
        dc = meshtastic.decode_device_config(cf[1])
        print('device config:', dc)

      if 2 in cf:
        dc = meshtastic.decode_position_config(cf[2])
        print('device config:', dc)

    elif rt == 6:
      print('log_record:', packet)  
    
    elif rt == 7:
      print('config_complete_id:', packet)
      pyotherside.send("config_complete_id", packet)
      
    elif rt == 8:
      print('rebooted:', packet)

    elif rt == 9:
      variant = meshtastic.decode(packet)
      if 1 in variant:
        mc = meshtastic.decode_module_mqtt_config(variant[1])
        print('MQTT Config:', mc)
      else:
        print('moduleConfig:', variant)

    elif rt == 10:
      ch = meshtastic.decode_channel_config(packet)
      pyotherside.send("channel_config", ch)

    elif rt == 11:
      qs = meshtastic.decode_queue_status(packet)
      self.info('queue status - ', qs, '_res', '_free', '_maxlen', '_mesh_packet_id')

    elif rt == 12:
      print('xmodemPacket:', packet)
      
    elif rt == 13:
      print('metadata:', packet)

    elif rt == 14:
      print('mqttClientProxyMessage:', packet)

    elif rt == 15:
      fi = meshtastic.decode_file_info(packet)
      print('fileInfo:', fi)

    elif rt == 16:
      print('clientNotification:', packet)

    elif rt == 17:
      print('deviceuiConfig:', packet) 

    else:
      print('unhandled packet - type:', rt, 'payload:', packet) 


  def text_message_send(self, message):
    print('text_message_send:', message)

    mp = {'to': int(message['to']), 'decoded': {'portnum': 1, 'payload': str.encode(message['text'])}, 'id': int(message['id']), 'hop_limit': 5, 'want_ack': True}
    if 'channel' in message:
      mp['channel'] = int(message['channel'])
    elif mp['to'] == 4294967295:
      print('SEND message ERROR - no channel specified but message to:', mp['to'])
      return False

    self.info('SEND message - ', message, '_to', '_channel', '_text')

    sp = meshtastic.create_stream_mesh_packet(mp)
    self.send(sp)


  def info(self, text, data_map, *fields):
    print(text, end='', sep='')
    for field in fields:
      if len(field) < 1:
        continue

      if field[0] == '_':
        value = 'NULL'
        try:
          value = data_map[field[1:]]
        except Exception as err:
          #print('info - err:', err, 'key:', field)
          pass

        print(field[1:], ': ', value, ', ', end='', sep='')
      else:
        print(field, end='', sep='')

    print('')







meshuga_object = Meshuga()
