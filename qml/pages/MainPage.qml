import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0                                                                                              
 
Page {
  id: main_page

  TabView {
    id: tabs

    anchors.fill: parent
    currentIndex: 1

    header: TabBar {
      id: tab_bar
      model: tab_model
    }

    model: [channel_messages_tab, nodes_tab, channel_tab, map_tab]
    
    Component {
      id: channel_messages_tab
      TabItem {
        MessagesTab {
          height: main_page.height - 200
          width: main_page.width
          id: messages_tab_item
        }
      }
    }

    Component {
      id: nodes_tab
      TabItem {
        NodesTab {
          height: main_page.height
          width: main_page.width
          id: nodes_tab_item
        }
      }
    }

    Component {
      id: channel_tab
      TabItem {
        flickable: channel_tab_item.flickable
        ChannelsTab {
          height: main_page.height
          width: main_page.width
          id: channel_tab_item
        }
      }
    }

    Component {
      id: map_tab
      TabItem {
        MapTab {
          height: main_page.height
          width: main_page.width
          id: map_tab_item
        }
      }
    }
  }


  ListModel {
    id: tab_model

    ListElement {
      title: "Messages"
    }
    ListElement {
      title: "Nodes"
    }
    ListElement {
      title: "Channels"
    }
    ListElement {
      title: "Map"
    }
  }

  Timer {
    id: startup_timer
    interval: 20
    repeat: false
    running: true
    triggeredOnStart: false
    onTriggered: {
      if (!app.settings.device_address || !app.settings.device_port) {
        pageStack.push(Qt.resolvedUrl("SettingsDialog.qml"), {})
      }
    }
  }

  Component.onCompleted: {

  }

  Component.onDestruction: {

  }

}



    