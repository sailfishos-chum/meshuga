import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
  property string date
  property string channel_name

  width: parent.width
  height: name_label.height

  Label {
    id: name_label
    text: channel_name
    font.pixelSize: Theme.fontSizeMedium
    truncationMode: TruncationMode.Fade
    color: Theme.highlightColor
    anchors {
      bottom: parent.bottom
      left: parent.left
      leftMargin: Theme.paddingLarge
      rightMargin: Theme.paddingLarge
    }
  }

  Label {
    id: date_label
    text: date
    font.pixelSize: Theme.fontSizeExtraSmall
    anchors {
      bottom: parent.bottom
      right: parent.right
      leftMargin: Theme.paddingLarge
      rightMargin: Theme.paddingLarge
    }
  }
}
