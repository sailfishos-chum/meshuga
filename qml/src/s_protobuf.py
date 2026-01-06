import struct
import math

WT_VARINT = 0
WT_I64	  = 1
WT_LEN	  = 2
WT_SGROUP	= 3
WT_EGROUP = 4
WT_I32	  = 5


def print_type(data):
  wire_types = ["VARINT", "I64", "LEN", "SGROUP", "EGROUP", "I32"]
  wire_type = data[0] & (1 + 2 + 4)

  print("%d. %s (%d)" % (data[0] >> 3, wire_types[wire_type], wire_type), end="")

  if wire_type == 2:
    print(" len: %d" % (data[1]), end="")

  print()
  return

  print("{:08b}".format(data[0]))
  print("{:08b}".format(data[0] >> 3))
  print("{:08b}".format(data[0] & (1 + 2 + 4)))


def ui_to_f(integer_value):
  return struct.unpack("<f", struct.pack('<I', integer_value))[0]

def ui_to_i(uint_value):
  return struct.unpack("<q", struct.pack('<Q', uint_value))[0]

def ui_to_h(uint_value):
  return uint_value.to_bytes(4, byteorder='big')

def varint_to_signed(uint_value):
  try:
    return struct.unpack("<q", struct.pack('<Q', uint_value))[0]
  except Exception:
    return None

def chop_int32(data):
  index = 0
  while index < len(data):
    value = struct.unpack("<i", data[index:index+4])
    print('chop:', index, value)
    index += 4

def chop_uint32(data):
  index = 0
  while index < len(data):
    value = struct.unpack("<I", data[index:index+4])
    print('chop:', index, value)
    index += 4

def decode_varint(data):
  index = 0
  blen = 1
  buffer = bytearray(b'')
  for digit in data:
    #print("VARINT d: {:08b} {:08b} {:d}".format(digit, digit ^ 0b10000000, digit ^ 0b10000000))
    index += 1
    if digit & 0b10000000:
      #print('+')
      buffer.append(digit ^ 0b10000000)
    else:
      #print('-')
      buffer.append(digit)
      break

  if len(buffer) == 0:
    return 0, 0

  #print('v index:', index, buffer[0])

  res = 0
  for i in range(len(buffer) * 7):
    if buffer[math.floor(i / 7)] & pow(2, i % 7):
      res += pow(2, i)

    #print(i, pow(2, i), i % 7, math.floor(i / 7), res)

  return res, len(buffer), varint_to_signed(res)

def encode_varint(value):  
  bw = math.ceil(value.bit_length() / 7)
  buf = bytearray(bw)

  for index in range(0, bw):
    vm = ((value >> (index * 7)) & 0b01111111)
    if index < bw-1:
      buf[index] = vm + 0b10000000
    else:
      buf[index] = vm
    
    

  return buf


  buf = bytearray(math.ceil(value / 128))

  vm = (value & 0b01111111)
  for i in range(0, math.ceil(value / 128)):
    
    if i < math.ceil(value / 128)-1:
      buf[i] = vm + 0b10000000
    else:
      buf[i] = vm

    sq = math.sqrt()

    print("{:d}. {:08b}".format(i, vm))
    vm = math.floor(value / ((i+1) * 128)) & 0b01111111

    

  print(buf)


  return buf

def decode_type(data):
  hl = 1
  wt = data[0] & (1 + 2 + 4)
  fn = data[0] >> 3
  value = None
  value_int = None
  value_float = None
  ln = 0

  try:
    if wt == WT_VARINT:
      hl = 1
      value, blen, value_int = decode_varint(data[1:])
      ln = blen + hl
    elif wt == WT_I64:
      hl = 1
      ln = 4 + hl
      value = struct.unpack("<I", data[hl:ln])[0]
      value_int = struct.unpack("<i", data[hl:ln])[0]
      value_float = struct.unpack("<f", data[hl:ln])[0]
    elif wt == WT_LEN:
      value, blen, _ = decode_varint(data[1:])
      hl = 1 + blen
      ln = value + hl 
      value = data[hl:data[1]+hl]
    elif wt == WT_I32:
      hl = 1
      ln = 4 + hl
      value = struct.unpack("<I", data[hl:ln])[0]
      value_int = struct.unpack("<i", data[hl:ln])[0]
      value_float = struct.unpack("<f", data[hl:ln])[0]
    else:
      ln = hl

  except Exception as err:
    print("ERROR decode_type:", err, 'return:', fn, wt, ln, value, data)

  return fn, wt, ln, value, value_int, value_float

def decode_protobuf(data):
  pb = {}

  if not data or not isinstance(data, bytes):
    return pb

  index = 0
  while index < len(data):    
    if len(data[index:]) > 1:
      fn, wt, ln, value, value_int, value_float = decode_type(data[index:])
    
      #print('i:', index, hex(index), "fn:", fn, 'wt:', wt, 'ln:', ln, 'value:', value)
    else:
      return pb
      
    if fn not in pb:
      pb[fn] = value
      if isinstance(value_int, int):
        pb["i%d" % fn] = value_int
      if isinstance(value_float, float) and not math.isnan(value_float):
        pb["f%d" % fn] = value_float
    else:
      if value != None:
        if not 'repeated' in pb:
          pb['repeated'] = []

        pr = {
          fn: value
        }
        if isinstance(value_int, int):
          pr["i%d" % fn] = value_int
        if isinstance(value_float, float) and not math.isnan(value_float):
          pr["f%d" % fn] = value_float

        pb['repeated'].append(pr)
      
    index += ln

    if wt > 5:
      break

  return pb


def encode_protobuf(record):
  buf = b''

  for rc in record:
    fn, wt, value = rc

    if wt == WT_VARINT:
      xfn = fn << 3
      xfn += wt & (1 + 2 + 4)
      buf += struct.pack("B", xfn) + encode_varint(value)
    elif wt == WT_I64:
      xfn = fn << 3
      xfn += wt & (1 + 2 + 4)      
      buf += struct.pack("B", xfn) + struct.pack('<I', value)
    elif wt == WT_LEN:
      xfn = fn << 3
      xfn += wt & (1 + 2 + 4)  
      buf += struct.pack("B", xfn) + encode_varint(len(value)) + value
    elif wt == WT_I32:
      xfn = fn << 3
      xfn += wt & (1 + 2 + 4)      
      buf += struct.pack("B", xfn) + struct.pack('<I', value)

  return buf

def encode_uint16(value):
  return struct.pack(">H", value)

def main():
  ui_to_h(1127200072)
  pass

if __name__ == '__main__':
  main()