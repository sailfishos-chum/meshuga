import QtQuick 2.0
import Sailfish.Silica 1.0

Component {
  ListItem {
    id: list_item
  
    // dynamic update loader-definded l_ fields common to all widgets
    property int time_count: l_time_count
    property var updated: l_updated
    property bool receiving: l_receiving
    property string data_b: l_data_b

    property string from
    property var timestamp
    property real latitude
    property real longitude
    property real accuracy
    property string formatted_address
    property bool is_tx

    width: parent.width
    height: from_label.height + address_label.height + date_label.height + position_column.height
    contentHeight: from_label.height + address_label.height + date_label.height + position_column.height

    ConversationBubble {
      height: parent.height
    }

    Label {
      id: from_label
      text: from
      font.pixelSize: Theme.fontSizeMedium
      truncationMode: TruncationMode.Fade
      visible: !is_tx
      anchors {
        left: parent.left
        topMargin: Theme.paddingMedium
        leftMargin: is_tx ? Theme.paddingLarge * 2 : Theme.paddingLarge
        rightMargin: is_tx ? Theme.paddingLarge : Theme.paddingLarge * 2
      }
    }

    Column {
      id: position_column
      anchors {
        right: parent.right
        top: parent.top
        topMargin: Theme.paddingMedium
        leftMargin: is_tx ? Theme.paddingLarge * 2 : Theme.paddingLarge
        rightMargin: is_tx ? Theme.paddingLarge : Theme.paddingLarge * 2
      }

      Icon {
        source: 'image://theme/icon-s-task'
        anchors.right: parent.right
      }

      Label {
        id: latitude_label
        text: latitude
        font.pixelSize: Theme.fontSizeExtraSmall
        anchors.right: parent.right
      }
      Label {
        id: longitude_label
        text: longitude
        font.pixelSize: Theme.fontSizeExtraSmall
        anchors.right: parent.right
      }
    }

    Label {
      id: address_label
      text: formatted_address
      font.pixelSize: Theme.fontSizeExtraSmall
      wrapMode: Text.WordWrap
      width: parent.width
      anchors {
        top: position_column.bottom
        left: parent.left
        right: parent.right
        topMargin: Theme.paddingSmall
        leftMargin: is_tx ? Theme.paddingLarge * 2 : Theme.paddingLarge
        rightMargin: is_tx ? Theme.paddingLarge : Theme.paddingLarge * 2
      }
    }

    Label {
      id: date_label
      text: timestamp.toLocaleString(Qt.locale(), 'H:mm:ss')
      font.pixelSize: Theme.fontSizeExtraSmall
      anchors {
        bottom: parent.bottom
        right: parent.right
        leftMargin: is_tx ? Theme.paddingLarge * 2 : Theme.paddingLarge
        rightMargin: is_tx ? Theme.paddingLarge : Theme.paddingLarge * 2
      }
    }

    BusyIndicator {
      running: receiving
      size: BusyIndicatorSize.ExtraSmall
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
    }
  }
}
