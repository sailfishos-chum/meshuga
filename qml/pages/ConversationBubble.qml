import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
  id: bubble_item
  width: parent.width - Theme.horizontalPageMargin
  color: Theme.rgba(Theme.primaryColor, Theme.opacityHigh)
  radius: Theme.paddingSmall

  opacity: {
      //Theme.opacityHigh
    Theme.opacityFaint
  }

  anchors {
    left: is_tx ? parent.left : undefined
    right: !is_tx ? parent.right : undefined
    top: parent.top

    leftMargin: is_tx ? Theme.paddingLarge : 0
    rightMargin: is_tx ? 0 : Theme.paddingLarge
    topMargin: Theme.paddingSmall
    bottomMargin: Theme.paddingSmall
  }
}
