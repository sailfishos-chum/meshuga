import meshtastic
import socket


message_id = 2849068020

HOST = "192.168.8.150" 
PORT = 4403

mynode = {}
nodes = {}

def send_text(s, channel, destination, message):
  global message_id

  message_id += 1

  mp = {'to': destination, 'decoded': {'portnum': 1, 'payload': str.encode(message)}, 'id': message_id, 'hop_limit': 5, 'want_ack': True}
  if channel != None:
    mp['channel'] = channel

  sp = meshtastic.create_stream_mesh_packet(mp)
  s.sendall(sp)

  info('OUT message - ', mp, '_id', '_from', '_to', '_channel', 'text: ', message)

def send_receive():
  global mynode
  global nodes

  msg_reset = bytes.fromhex('c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3')

  s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  s.connect((HOST, PORT))
  s.sendall(msg_reset)
  s.sendall(meshtastic.create_stream_want_config_id(507381257))

  while True:
    data = s.recv(512)

    packet = meshtastic.decode_stream_packet(data)

    if packet:
      if 1 in packet:
        print('ID:', meshtastic.decode(packet[1]))

      if 2 in packet:
        mp = meshtastic.decode_mesh_packet(packet[2])
        if 'decoded' in mp and mp['decoded'] and 'portnum' in mp['decoded']:
          if mp['decoded']['portnum'] == meshtastic.PORT_TEXT_MESSAGE_APP:
            message = mp['decoded']['payload'].decode()

            info('IN message - ', mp, '_rx_time', '_from', '_to', '_channel', 'text: ', message)
            if message.startswith("/echo"):
              destination = 4294967295
              if mp['to'] != destination:
                destination = mp['from']

              if 'channel' in mp:
                send_text(s, mp['channel'], destination, message[5:])
              else:
                send_text(s, None, destination, message[5:])

        elif 'encrypted' in mp:
          info('IN message - ', mp, '_rx_time', '_from', '_to', '_channel', '_encrypted')
        else:
          print('ERROR unhandled mesh packet:', mp)

      if 3 in packet:
        ni = meshtastic.decode_my_node_info(packet[3])
        info('LOCAL node - ', ni, '_my_node_num', '_reboot_count', '_min_app_version', '_pio_env')
        mynode = ni

      if 4 in packet:
        ni = meshtastic.decode_node_info(packet[4])
        if ni['num'] not in nodes:
          nodes[ni['num']] = {}
          info('NEW node - ', ni, str(len(nodes)), ' ', '_num', '_last_heard')
        else:
          info('UPDATE node - ', ni, '_num', '_last_heard')
          
        nodes[ni['num']].update(ni)

      if 5 in packet:
        cf = meshtastic.decode(packet[5])
        if 1 in cf:
          dc = meshtastic.decode_device_config(cf[1])
          print('device config:', dc)

        if 2 in cf:
          dc = meshtastic.decode_position_config(cf[2])
          print('device config:', dc)

      if 6 in packet:
        print('log_record:', packet)  
      
      if 7 in packet:
        print('config_complete_id:', packet[7])

      if 8 in packet:
        print('rebooted:', packet)

      if 9 in packet:
        variant = meshtastic.decode(packet[9])
        if 1 in variant:
          mc = meshtastic.decode_module_mqtt_config(variant[1])
          print('MQTT Config:', mc)
        else:
          print('moduleConfig:', variant)

      if 10 in packet:
        ch = meshtastic.decode_channel_config(packet[10])
        print('channel:', ch)

      if 11 in packet:
        qs = meshtastic.decode_queue_status(packet[11])
        info('queue status - ', qs, '_res', '_free', '_maxlen', '_mesh_packet_id')

      if 12 in packet:
        print('xmodemPacket:', packet)
        
      if 13 in packet:
        print('metadata:', packet)

      if 14 in packet:
        print('mqttClientProxyMessage:', packet)

      if 15 in packet:
        fi = meshtastic.decode_file_info(packet[15])
        print('fileInfo:', fi)

      if 16 in packet:
        print('clientNotification:', packet)

      if 17 in packet:
        print('deviceuiConfig:', packet) 


def info(text, data_map, *fields):
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
def main():
  #send_receive()

  sp = meshtastic.decode_stream_packet(bytes.fromhex('94c30011520f120b120101280130013a020820180194c3003e523c0801123612203878ef61247455b274fa526fceb447055f6938eee56f314e15f485b40623f06b1a0a676f6c77656e2e6e6574280130013a020820180294c3000652040802120094c3000652040803120094c3000652040804120094c3000652040805120094c30006520408061200'))

  ch = meshtastic.decode_channel_config(b'\x08\x01\x126\x12 8x\xefa$tU\xb2t\xfaRo\xce\xb4G\x05_i8\xee\xe5o1N\x15\xf4\x85\xb4\x06#\xf0k\x1a\ngolwen.net(\x010\x01:\x02\x08 \x18\x02')
  print(ch)

  for entry in sp['repeated']:
    if 10 in entry:
      ch = meshtastic.decode_channel_config(entry[10])
      print(ch)
    
if __name__ == '__main__':
  main()



