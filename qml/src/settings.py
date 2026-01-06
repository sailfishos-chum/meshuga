# -*- coding: utf-8 -*-
import os
import time
import json
import pyotherside

class Settings:
  SETTINGS_FILE = "settings.json"
  NODES_FILE = "nodes.json"
  MESSAGES_FILE = "messages.json"

  def __init__(self):
    self.data_directory = os.environ['HOME'] + "/.local/share/app.qml/meshuga/"
    print('Settings init - data directory: ', self.data_directory)

    try:
      os.makedirs(self.data_directory)
    except FileExistsError:
      pass
    except Exception as err:
      print('Settings init - error: ', err)
      pyotherside.send("error", "settings", "init", self.format_error(err))
      return False

  def format_error(self, err):
    return 'ERROR: %s' % err

  def load_settings(self):
    settings = {}
    try:
      with open(self.data_directory + self.SETTINGS_FILE) as settings_file:
        settings = json.load(settings_file)
    except Exception as err:
      print('Settings load_settings - error: ', err)
      pyotherside.send("error", "settings", "load_settings", self.format_error(err))
      settings = {'created_at': int(time.time())}

    self.settings_defaults(settings)

    return settings

  def save_settings(self, settings):
    try:
      with open(self.data_directory + self.SETTINGS_FILE, 'w') as settings_file:
        json.dump(settings, settings_file, indent=2)
    except Exception as err:
      print('Settings save_settings - error: ', err)
      pyotherside.send("error", "settings", "save_settings", self.format_error(err))
      return False
  
  def load_nodes(self):
    nodes = {}
    try:
      with open(self.data_directory + self.NODES_FILE) as nodes_file:
        nodes = json.load(nodes_file)
        self.recursive_unalign_types(nodes)
    except Exception as err:
      print('Settings load_nodes - error: ', err)
      pyotherside.send("error", "settings", "load_nodes", self.format_error(err))

    return nodes

  def load_messages(self):
    messages = {}
    try:
      with open(self.data_directory + self.MESSAGES_FILE) as messages_file:
        messages = json.load(messages_file)
        self.recursive_unalign_types(messages)
    except Exception as err:
      print('Settings load_messages - error: ', err)
      pyotherside.send("error", "settings", "load_messages", self.format_error(err))

    return messages
   
  def recursive_align_types(self, array):
    for parameter in array:
      if isinstance(array[parameter], float) and array[parameter].is_integer():
        array[parameter] = int(array[parameter])
      elif isinstance(array[parameter], bytes):
        array[parameter] = 'hex:' + array[parameter].hex()
      elif isinstance(array[parameter], dict):
        self.recursive_align_types(array[parameter])

  def recursive_unalign_types(self, array):
    for parameter in array:
      if isinstance(array[parameter], str) and array[parameter].startswith("hex:"):
        array[parameter] = bytes.fromhex(array[parameter][4:])
      elif isinstance(array[parameter], dict):
        self.recursive_unalign_types(array[parameter])

  def save_nodes(self, nodes):
    #clean up floats
    for message_id in nodes:
      self.recursive_align_types(nodes[message_id])

    try:
      with open(self.data_directory + self.NODES_FILE, 'w') as nodes_file:
        json.dump(nodes, nodes_file, indent=2)
    except Exception as err:
      print('Settings save_nodes - error: ', err)
      pyotherside.send("error", "settings", "save_nodes", self.format_error(err))
      return False

  def save_messages(self, messages):
    #clean up floats
    for message_id in messages:
      self.recursive_align_types(messages[message_id])
      #for parameter in messages[message_id]:
      #  if isinstance(messages[message_id][parameter], float):
      #    messages[message_id][parameter] = int(messages[message_id][parameter])

    try:
      with open(self.data_directory + self.MESSAGES_FILE, 'w') as messages_file:
        json.dump(messages, messages_file, indent=2)
    except Exception as err:
      print('Settings save_messages - error: ', err)
      pyotherside.send("error", "settings", "save_messages", self.format_error(err))
      return False
    
  def settings_defaults(self, settings):
    defaults = {
      'last_message_id_out': 1100
    }

    for key, value in defaults.items():
      if not key in settings:
        settings[key] = value


settings_object = Settings()
