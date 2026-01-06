import QtQuick 2.0
import Sailfish.Silica 1.0

Component {
  ListItem {
    id: list_item
  
    // dynamic update fields common to all widgets
    property int time_count: l_time_count
    property var updated: l_updated
    property bool receiving: l_receiving
    property string data_b: l_data_b

    property string message_from
    property string message_to

    property var timestamp
    property string message_text
    property bool is_tx

    property var from_node: app.nodes[message_from]
    property var to_node: app.nodes[message_to]

    width: parent.width
    height: contentHeight
    contentHeight: from_label.height + message_text_label.height + date_label.height + Theme.horizontalPageMargin / 2 + context_menu.height

    menu: ContextMenu {
      id: context_menu
      MenuItem {
        text: "Clear"
        onClicked: {

        }
      }
      MenuItem {
        text: "Clear all"
        enabled: true
        onClicked: {
          list_model.clear()
        }
      }
    }
    
    ConversationBubble {
      id: conversation_bubble
      height: parent.height
    }

    Label {
      id: from_label
      text: from_node && from_node.user ? from_node.user.short_name : message_from
      font.pixelSize: Theme.fontSizeMedium
      truncationMode: TruncationMode.Fade
      visible: !is_tx

      anchors {
        left: conversation_bubble.left
        topMargin: Theme.paddingSmall
        leftMargin: Theme.paddingMedium
        rightMargin: Theme.paddingMedium
      }
    }

    Icon {
      id: to_arrow_icon
      source: "image://theme/icon-m-enter-next"
      anchors {
        verticalCenter: from_label.verticalCenter
        left: conversation_bubble.horizontalCenter
        leftMargin: Theme.paddingExtraSmall
      }
      height: from_label.height * 0.7
      width: height
      visible: message_to != 'ffffffff'
      color: Theme.primaryColor
    }

    Label {
      id: to_label
      text: to_node && to_node.user ? to_node.user.short_name : message_to
      font.pixelSize: Theme.fontSizeMedium
      truncationMode: TruncationMode.Fade
      visible: message_to != 'ffffffff'

      anchors {
        left: to_arrow_icon.right
        topMargin: Theme.paddingSmall
      }
    }

    Label {
      id: date_label
      text: timestamp.toLocaleString(Qt.locale(), 'H:mm:ss')
      font.pixelSize: Theme.fontSizeExtraSmall
      anchors {
        top: conversation_bubble.top
        right: conversation_bubble.right
        leftMargin: Theme.paddingMedium
        rightMargin: Theme.paddingMedium
      }
    }

    Label {
      id: message_text_label
      text: message_text
      font.pixelSize: Theme.fontSizeExtraSmall
      wrapMode: Text.WordWrap
      width: parent.width
      color: is_tx ? Theme.highlightColor : Theme.primaryColor
      anchors {
        top: from_label.bottom
        left: conversation_bubble.left
        right: conversation_bubble.right
        topMargin: Theme.paddingSmall
        bottomMargin: Theme.paddingSmall
        leftMargin: Theme.paddingMedium
        rightMargin: Theme.paddingMedium
      }
    }
  }
}
