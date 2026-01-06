import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
  id: cover

  Label {
    id: temp_outside
    anchors {
      verticalCenter: parent.verticalCenter
      horizontalCenter: parent.horizontalCenter
    }
    opacity: 0.4
    text: "Meshuga"
    font.pixelSize: Theme.fontSizeSmall
  }

  Component.onCompleted: {

  }

  Component.onDestruction: {

  }
}
