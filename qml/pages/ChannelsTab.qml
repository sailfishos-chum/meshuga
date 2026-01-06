import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0                                                                                              
 
Item {
  id: item

  property bool isCurrentItem
  property alias flickable: flickable

  anchors.fill: parent

  SilicaFlickable {
    id: flickable

    width: item.width
    height: item.height

    PullDownMenu {
      MenuLabel {
        text: "Meshuga"
      }
      MenuItem {
        text: "Settings"
        onClicked: {
          pageStack.push("SettingsDialog.qml", {})
        }
      }
    }
  }
}
