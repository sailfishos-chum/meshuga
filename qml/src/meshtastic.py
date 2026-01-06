import s_protobuf 
import time
import datetime

#port numbers
PORT_UNKNOWN_APP = 0
PORT_TEXT_MESSAGE_APP = 1
PORT_REMOTE_HARDWARE_APP = 2
PORT_POSITION_APP = 3
PORT_NODEINFO_APP = 4
PORT_ROUTING_APP = 5
PORT_ADMIN_APP = 6
PORT_TEXT_MESSAGE_COMPRESSED_APP = 7
PORT_WAYPOINT_APP = 8
PORT_AUDIO_APP = 9
PORT_DETECTION_SENSOR_APP = 10
PORT_REPLY_APP = 32
PORT_IP_TUNNEL_APP = 33
PORT_PAXCOUNTER_APP = 34
PORT_SERIAL_APP = 64
PORT_STORE_FORWARD_APP = 65
PORT_RANGE_TEST_APP = 66
PORT_TELEMETRY_APP = 67
PORT_ZPS_APP = 68
PORT_SIMULATOR_APP = 69
PORT_TRACEROUTE_APP = 70
PORT_NEIGHBORINFO_APP = 71
PORT_ATAK_PLUGIN = 72
PORT_MAP_REPORT_APP = 73
PORT_POWERSTRESS_APP = 74
PORT_PRIVATE_APP = 256
PORT_ATAK_FORWARDER = 257
PORT_MAX = 511

#hardware device model ID
HWMODEL_UNSET = 0
HWMODEL_TLORA_V2 = 1
HWMODEL_TLORA_V1 = 2
HWMODEL_TLORA_V2_1_1P6 = 3
HWMODEL_TBEAM = 4
HWMODEL_HELTEC_V2_0 = 5
HWMODEL_TBEAM_V0P7 = 6
HWMODEL_T_ECHO = 7
HWMODEL_TLORA_V1_1P3 = 8
HWMODEL_RAK4631 = 9
HWMODEL_HELTEC_V2_1 = 10
HWMODEL_HELTEC_V1 = 11
HWMODEL_LILYGO_TBEAM_S3_CORE = 12
HWMODEL_RAK11200 = 13
HWMODEL_NANO_G1 = 14
HWMODEL_TLORA_V2_1_1P8 = 15
HWMODEL_TLORA_T3_S3 = 16
HWMODEL_NANO_G1_EXPLORER = 17
HWMODEL_NANO_G2_ULTRA = 18
HWMODEL_LORA_TYPE = 19
HWMODEL_WIPHONE = 20
HWMODEL_WIO_WM1110 = 21
HWMODEL_RAK2560 = 22
HWMODEL_HELTEC_HRU_3601 = 23
HWMODEL_HELTEC_WIRELESS_BRIDGE = 24
HWMODEL_STATION_G1 = 25
HWMODEL_RAK11310 = 26
HWMODEL_SENSELORA_RP2040 = 27
HWMODEL_SENSELORA_S3 = 28
HWMODEL_CANARYONE = 29
HWMODEL_RP2040_LORA = 30
HWMODEL_STATION_G2 = 31
HWMODEL_LORA_RELAY_V1 = 32
HWMODEL_NRF52840DK = 33
HWMODEL_PPR = 34
HWMODEL_GENIEBLOCKS = 35
HWMODEL_NRF52_UNKNOWN = 36
HWMODEL_PORTDUINO = 37
HWMODEL_ANDROID_SIM = 38
HWMODEL_DIY_V1 = 39
HWMODEL_NRF52840_PCA10059 = 40
HWMODEL_DR_DEV = 41
HWMODEL_M5STACK = 42
HWMODEL_HELTEC_V3 = 43
HWMODEL_HELTEC_WSL_V3 = 44
HWMODEL_BETAFPV_2400_TX = 45
HWMODEL_BETAFPV_900_NANO_TX = 46
HWMODEL_RPI_PICO = 47
HWMODEL_HELTEC_WIRELESS_TRACKER = 48
HWMODEL_HELTEC_WIRELESS_PAPER = 49
HWMODEL_T_DECK = 50
HWMODEL_T_WATCH_S3 = 51
HWMODEL_PICOMPUTER_S3 = 52
HWMODEL_HELTEC_HT62 = 53
HWMODEL_EBYTE_ESP32_S3 = 54
HWMODEL_ESP32_S3_PICO = 55
HWMODEL_CHATTER_2 = 56
HWMODEL_HELTEC_WIRELESS_PAPER_V1_0 = 57
HWMODEL_HELTEC_WIRELESS_TRACKER_V1_0 = 58
HWMODEL_UNPHONE = 59
HWMODEL_TD_LORAC = 60
HWMODEL_CDEBYTE_EORA_S3 = 61
HWMODEL_TWC_MESH_V4 = 62
HWMODEL_NRF52_PROMICRO_DIY = 63
HWMODEL_RADIOMASTER_900_BANDIT_NANO = 64
HWMODEL_HELTEC_CAPSULE_SENSOR_V3 = 65
HWMODEL_HELTEC_VISION_MASTER_T190 = 66
HWMODEL_HELTEC_VISION_MASTER_E213 = 67
HWMODEL_HELTEC_VISION_MASTER_E290 = 68
HWMODEL_HELTEC_MESH_NODE_T114 = 69
HWMODEL_SENSECAP_INDICATOR = 70
HWMODEL_TRACKER_T1000_E = 71
HWMODEL_RAK3172 = 72
HWMODEL_WIO_E5 = 73
HWMODEL_RADIOMASTER_900_BANDIT = 74
HWMODEL_ME25LS01_4Y10TD = 75
HWMODEL_RP2040_FEATHER_RFM95 = 76
HWMODEL_M5STACK_COREBASIC = 77
HWMODEL_M5STACK_CORE2 = 78
HWMODEL_RPI_PICO2 = 79
HWMODEL_M5STACK_CORES3 = 80
HWMODEL_SEEED_XIAO_S3 = 81
HWMODEL_MS24SF1 = 82
HWMODEL_TLORA_C6 = 83
HWMODEL_PRIVATE_HW = 255

UINT = 'uint'

def get_value(data_map, field_number):
  try:
    return data_map[field_number]
  except Exception as err:
    return None

def get_value_i(data_map, field_number):
  try:
    if not int(data_map[field_number]) > 0:
      int(data_map[field_number])
    return int(data_map[field_number])
  except Exception as err:
    return 0

def get_value_f(data_map, field_number):
  try:
    return float(data_map['f'+field_number])
  except Exception as err:
    return -0.0

def get_value_b(data_map, field_number):
  try:
    return data_map[field_number] > 0
  except Exception as err:
    return False

def get_value_s(data_map, field_number):
  try:
    return data_map[field_number].decode()
  except Exception as err:
    return ''


def setparam(record, field_name, data_map, field_number, value_type = bytes):
  try:
    if value_type == int:
      record[field_name] = int(data_map['i%d' % field_number])
    elif value_type == UINT:
      record[field_name] = int(data_map[field_number])
    elif value_type == float:
      record[field_name] = float(data_map['f%d' %field_number])
    elif value_type == bool:
      record[field_name] = data_map[field_number] > 0
    else:
      record[field_name] = data_map[field_number]
    return True
  except Exception as err:
    #print('ERROR setparam:', err, field_name, field_number, value_type)
    return False
  
def get_port_name(port_number):
  port_names = {
    PORT_UNKNOWN_APP: "UNKNOWN_APP",
    PORT_TEXT_MESSAGE_APP: "TEXT_MESSAGE_APP",
    PORT_REMOTE_HARDWARE_APP: "REMOTE_HARDWARE_APP",
    PORT_POSITION_APP: "POSITION_APP",
    PORT_NODEINFO_APP: "NODEINFO_APP",
    PORT_ROUTING_APP: "ROUTING_APP",
    PORT_ADMIN_APP: "ADMIN_APP",
    PORT_TEXT_MESSAGE_COMPRESSED_APP: "TEXT_MESSAGE_COMPRESSED_APP",
    PORT_WAYPOINT_APP: "WAYPOINT_APP",
    PORT_AUDIO_APP: "AUDIO_APP",
    PORT_DETECTION_SENSOR_APP: "DETECTION_SENSOR_APP",
    PORT_REPLY_APP: "REPLY_APP",
    PORT_IP_TUNNEL_APP: "IP_TUNNEL_APP",
    PORT_PAXCOUNTER_APP: "PAXCOUNTER_APP",
    PORT_SERIAL_APP: "SERIAL_APP",
    PORT_STORE_FORWARD_APP: "STORE_FORWARD_APP",
    PORT_RANGE_TEST_APP: "RANGE_TEST_APP",
    PORT_TELEMETRY_APP: "TELEMETRY_APP",
    PORT_ZPS_APP: "ZPS_APP",
    PORT_SIMULATOR_APP: "SIMULATOR_APP",
    PORT_TRACEROUTE_APP: "TRACEROUTE_APP",
    PORT_NEIGHBORINFO_APP: "NEIGHBORINFO_APP",
    PORT_ATAK_PLUGIN: "ATAK_PLUGIN",
    PORT_MAP_REPORT_APP: "MAP_REPORT_APP",
    PORT_POWERSTRESS_APP: "POWERSTRESS_APP",
    PORT_PRIVATE_APP: "PRIVATE_APP",
    PORT_ATAK_FORWARDER: "ATAK_FORWARDER",
    PORT_MAX: "MAX",
  }

  return port_names[port_number]

def decode_stream_packet(envelope):
  if len(envelope) < 4:
    return None

  if envelope[0] != 0x94 or envelope[1] != 0xc3:
    return None

  packet = s_protobuf.decode_protobuf(envelope[4:])

  return packet

def decode(data):
  return s_protobuf.decode_protobuf(data)

def decode_my_node_info(data):
  packet = s_protobuf.decode_protobuf(data)

  ni = {}
  setparam(ni, 'my_node_num',     packet,  1, UINT)
  setparam(ni, 'reboot_count',    packet,  8, UINT)
  setparam(ni, 'min_app_version', packet, 11, UINT)
  setparam(ni, 'device_id',       packet, 12, bytes)
  setparam(ni, 'pio_env',         packet, 13, bytes)

  return ni

def decode_node_info(data):
  packet = s_protobuf.decode_protobuf(data)

  ni = {}
  setparam(ni, 'num',             packet,  1, UINT)
  setparam(ni, 'snr',             packet,  4, float)
  setparam(ni, 'last_heard',      packet,  5, int)
  setparam(ni, 'channel',         packet,  7, UINT)
  setparam(ni, 'via_mqtt',        packet,  8, bool)
  setparam(ni, 'hops_away',       packet,  9, UINT)
  setparam(ni, 'is_favorite',     packet, 10, bool)
  setparam(ni, 'is_ignored',      packet, 11, bool)

  if 2 in packet:
    ni['user'] = decode_user_info(get_value(packet, 2))
  
  if 3 in packet:
    ni['position'] = decode_position_info(get_value(packet, 3))

  if 6 in packet:
    ni['device_metrics'] = decode_device_metrics(get_value(packet, 6))

  return ni



def decode_user_info(data):
  packet = s_protobuf.decode_protobuf(data)

  ui = {}
  setparam(ui, 'id',          packet,  1, UINT)
  setparam(ui, 'long_name',   packet,  2, bytes)
  setparam(ui, 'short_name',  packet,  3, bytes)
  setparam(ui, 'macaddr',     packet,  4, bytes)
  setparam(ui, 'hw_model',    packet,  5, UINT)
  setparam(ui, 'is_licensed', packet,  6, bool)
  setparam(ui, 'role',        packet,  7, UINT)
  setparam(ui, 'public_key',  packet,  8, bytes)

  return ui

def decode_position_info(data):
  packet = s_protobuf.decode_protobuf(data)

  pi = {}
  setparam(pi, 'latitude_i',                  packet,  1, int)
  setparam(pi, 'longitude_i',                 packet,  2, int)
  setparam(pi, 'altitude',                    packet,  3, int)
  setparam(pi, 'time',                        packet,  4, int)
  setparam(pi, 'location_source',             packet,  5, UINT)
  setparam(pi, 'altitude_source',             packet,  6, UINT)
  setparam(pi, 'timestamp',                   packet,  7, int)
  setparam(pi, 'timestamp_millis_adjust',     packet,  8, int)
  setparam(pi, 'altitude_hae',                packet,  9, int)
  setparam(pi, 'altitude_geoidal_separation', packet, 10, UINT)
  setparam(pi, 'PDOP',                        packet, 11, UINT)
  setparam(pi, 'HDOP',                        packet, 12, UINT)
  setparam(pi, 'VDOP',                        packet, 13, UINT)
  setparam(pi, 'gps_accuracy',                packet, 14, UINT)
  setparam(pi, 'ground_speed',                packet, 15, UINT)
  setparam(pi, 'ground_track',                packet, 16, UINT)
  setparam(pi, 'fix_quality',                 packet, 17, UINT)
  setparam(pi, 'fix_type',                    packet, 18, UINT)
  setparam(pi, 'sats_in_view',                packet, 19, UINT)
  setparam(pi, 'sensor_id',                   packet, 20, UINT)
  setparam(pi, 'next_update',                 packet, 21, UINT)
  setparam(pi, 'seq_number',                  packet, 22, UINT)
  setparam(pi, 'precision_bits',              packet, 23, UINT)

  return pi

def decode_device_metrics(data):
  packet = s_protobuf.decode_protobuf(data)

  dm = {}
  setparam(dm, 'battery_level',       packet, 1, UINT)
  setparam(dm, 'voltage',             packet, 2, float)
  setparam(dm, 'channel_utilization', packet, 3, float)
  setparam(dm, 'air_util_tx',         packet, 4, float)
  setparam(dm, 'uptime_seconds',      packet, 5, UINT)

  return dm


def decode_mesh_packet(data):
  packet = s_protobuf.decode_protobuf(data)

  mp = {}
  setparam(mp, 'from',          packet,  1, UINT)
  setparam(mp, 'to',            packet,  2, UINT)
  setparam(mp, 'channel',       packet,  3, UINT)
  setparam(mp, 'encrypted',     packet,  5, bytes)
  setparam(mp, 'id',            packet,  6, UINT)
  setparam(mp, 'rx_time',       packet,  7, UINT)
  setparam(mp, 'rx_snr',        packet,  8, float)
  setparam(mp, 'hop_limit',     packet,  9, UINT)
  setparam(mp, 'want_ack',      packet, 10, bool)
  setparam(mp, 'priority',      packet, 11, UINT)
  setparam(mp, 'rx_rssi',       packet, 12, int)
  setparam(mp, 'delayed',       packet, 13, UINT)
  setparam(mp, 'via_mqtt',      packet, 14, bool)
  setparam(mp, 'hop_start',     packet, 15, UINT)
  setparam(mp, 'public_key',    packet, 16, bytes)
  setparam(mp, 'pki_encrypted', packet, 17, bool)
  setparam(mp, 'next_hop',      packet, 18, UINT)
  setparam(mp, 'relay_node',    packet, 19, UINT)

  if 4 in packet:
    mp['decoded'] = decode_data_packet(get_value(packet, 4))

  return mp

def decode_data_packet(data):
  packet = s_protobuf.decode_protobuf(data)

  dp = {}
  setparam(dp, 'portnum',       packet,  1, UINT)
  setparam(dp, 'payload',       packet,  2, bytes)
  setparam(dp, 'want_response', packet,  3, bool)
  setparam(dp, 'dest',          packet,  4, UINT)
  setparam(dp, 'source',        packet,  5, UINT)
  setparam(dp, 'request_id',    packet,  6, UINT)
  setparam(dp, 'reply_id',      packet,  7, UINT)
  setparam(dp, 'emoji',         packet,  8, UINT)
  setparam(dp, 'bitfield',      packet,  9, UINT)

  return dp


def decode_device_config(data):
  packet = s_protobuf.decode_protobuf(data)

  cf = {}
  setparam(cf, 'role',                        packet,  1, UINT)
  setparam(cf, 'serial_enabled',              packet,  2, bool)
  setparam(cf, 'button_gpio',                 packet,  4, UINT)
  setparam(cf, 'buzzer_gpio',                 packet,  5, UINT)
  setparam(cf, 'rebroadcast_mode',            packet,  6, UINT)
  setparam(cf, 'node_info_broadcast_secs',    packet,  7, UINT)
  setparam(cf, 'double_tap_as_button_press',  packet,  8, bool)
  setparam(cf, 'is_managed',                  packet,  9, bool)
  setparam(cf, 'disable_triple_click',        packet, 10, bool)
  setparam(cf, 'tzdef',                       packet, 11, bytes)
  setparam(cf, 'led_heartbeat_disabled',      packet, 12, bool)

  return cf

def decode_position_config(data):
  packet = s_protobuf.decode_protobuf(data)

  cf = {}
  setparam(cf, 'position_broadcast_secs',               packet,  1, UINT)
  setparam(cf, 'position_broadcast_smart_enabled',      packet,  2, bool)
  setparam(cf, 'fixed_position',                        packet,  3, bool)
  setparam(cf, 'gps_enabled',                           packet,  4, bool)
  setparam(cf, 'gps_update_interval',                   packet,  5, UINT)
  setparam(cf, 'gps_attempt_time',                      packet,  6, UINT)
  setparam(cf, 'position_flags',                        packet,  7, UINT)
  setparam(cf, 'rx_gpio',                               packet,  8, UINT)
  setparam(cf, 'tx_gpio',                               packet,  9, UINT)
  setparam(cf, 'broadcast_smart_minimum_distance',      packet, 10, UINT)
  setparam(cf, 'broadcast_smart_minimum_interval_secs', packet, 11, UINT)
  setparam(cf, 'gps_en_gpio',                           packet, 12, UINT)
  setparam(cf, 'gps_mode',                              packet, 13, UINT)

  return cf

def decode_queue_status(data):
  packet = s_protobuf.decode_protobuf(data)

  qs = {}
  setparam(qs, 'res',             packet,  1, int)  #Last attempt to queue status, ErrorCode 
  setparam(qs, 'free',            packet,  2, UINT) #Free entries in the outgoing queue
  setparam(qs, 'maxlen',          packet,  3, UINT) #Maximum entries in the outgoing queue
  setparam(qs, 'mesh_packet_id',  packet,  4, UINT) #Mesh packet id that generated this response

  return qs

def decode_file_info(data):
  packet = s_protobuf.decode_protobuf(data)

  fi = {}
  setparam(fi, 'file_name',   packet,  1, bytes)
  setparam(fi, 'size_bytes',  packet,  2, UINT)

  return fi

def decode_module_mqtt_config(data):
  packet = s_protobuf.decode_protobuf(data)

  mc = {}
  setparam(mc, 'enabled',                 packet,  1, bool)
  setparam(mc, 'address',                 packet,  2, bytes)
  setparam(mc, 'username',                packet,  3, bytes)
  setparam(mc, 'password',                packet,  4, bytes)
  setparam(mc, 'encryption_enabled',      packet,  5, bool)
  setparam(mc, 'json_enabled',            packet,  6, bool)
  setparam(mc, 'tls_enabled',             packet,  7, bool)
  setparam(mc, 'root',                    packet,  8, bytes)
  setparam(mc, 'proxy_to_client_enabled', packet,  9, bool)
  setparam(mc, 'map_reporting_enabled',   packet,  10, bool)

  if 11 in packet:
    mc['map_report_settings'] = decode_map_report_settings(packet[11])

  return mc

def decode_map_report_settings(data):
  packet = s_protobuf.decode_protobuf(data)

  ms = {}
  setparam(ms, 'publish_interval_secs', packet,  1, UINT)
  setparam(ms, 'position_precision',    packet,  2, UINT)

  return ms

def decode_channel_config(data):
  packet = s_protobuf.decode_protobuf(data)

  ch = {}
  setparam(ch, 'index', packet,  1, int)
  setparam(ch, 'settings', packet,  2, bytes)
  setparam(ch, 'role', packet,  3, int)

  if 2 in packet:
    ch['settings'] = decode_channel_settings(packet[2])

  return ch

def decode_channel_settings(data):
  packet = s_protobuf.decode_protobuf(data)

  cs = {}
  setparam(cs, 'channel_num', packet,  1, UINT)
  setparam(cs, 'psk', packet,  2, bytes)
  setparam(cs, 'name', packet,  3, bytes)
  setparam(cs, 'id', packet,  4, int)
  setparam(cs, 'uplink_enabled', packet,  5, bool)
  setparam(cs, 'downlink_enabled', packet,  6, bool)
  setparam(cs, 'module_settings', packet,  7, bytes)

  if 7 in packet:
    cs['module_settings'] = decode_channel_module_settings(packet[7])

  return cs

def decode_channel_module_settings(data):
  packet = s_protobuf.decode_protobuf(data)

  ms = {}
  setparam(ms, 'position_precision', packet,  1, UINT)
  setparam(ms, 'is_client_muted',    packet,  2, bool)

  return ms

def decode_telemetry_packet(data):
  packet = s_protobuf.decode_protobuf(data)
  tp = {}
  setparam(tp, 'time', packet,  1, int)
  
  if 2 in packet:
    tp['device_metrics'] = decode_device_metrics(get_value(packet, 2))

  return tp

def encode_mesh_packet(mp):
  decoded = encode([
    (1, 0, mp['decoded']['portnum']), 
    (2, 2, mp['decoded']['payload']),
  ])

  if 'channel' in mp:
    data = encode([
      (2, 5, mp['to']),
      (3, 0, mp['channel']),
      (4, 2, decoded),
      (6, 5, mp['id']),
      (9, 0, mp['hop_limit']),
      (10, 0, 1 if mp['want_ack'] else 0),
    ])

    return data

  data = encode([
    (2, 5, mp['to']),
    (4, 2, decoded),
    (6, 5, mp['id']),
    (9, 0, mp['hop_limit']),
    (10, 0, 1 if mp['want_ack'] else 0),
  ])

  return data
  
def create_stream_packet(data):
  len_b = s_protobuf.encode_varint(len(data) + 2)
  if (len(len_b)) < 2:
    len_b = b'\x00' + len_b
  return b'\x94\xc3' + len_b + s_protobuf.encode_protobuf([(1, 2, data)])

def create_stream_mesh_packet(mp):
  data = encode_mesh_packet(mp)
  payload = s_protobuf.encode_protobuf([(1, 2, data)])
  return b'\x94\xc3' + s_protobuf.encode_uint16(len(payload)) + payload

def create_stream_want_config_id(config_id):
  payload = s_protobuf.encode_protobuf([(3, 0, config_id)])
  return b'\x94\xc3' + s_protobuf.encode_uint16(len(payload)) + payload

def create_stream_heartbeat():
  payload = s_protobuf.encode_protobuf([(7, 2, b'')])
  return b'\x94\xc3' + s_protobuf.encode_uint16(len(payload)) + payload

def encode(record):
  return s_protobuf.encode_protobuf(record)

def main():
  pass
  
if __name__ == '__main__':
  main()
