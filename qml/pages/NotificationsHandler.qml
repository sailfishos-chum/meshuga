import QtQuick 2.0
import Nemo.Notifications 1.0
import Sailfish.Silica 1.0

Item {
  id: notifications_handler

  property var notifications_by_file_name: {'_null': null}
  property int cache_progress_id

  Notice {
    id: system_notice
    duration: Notice.Long
    text: "Info"
  }

  Notification {
    id: download_notification
    appIcon: "harbour-musicex"
    appName: "Music Explorer"
    expireTimeout: 30000
    urgency: Notification.Low
    onClosed: {
      console.log('download notification closed - reason:', reason, 'id:', replacesId);
    }
  }

  Component.onCompleted: {
    app.signal_error.connect(error_handler)
  }

  Component.onDestruction: {
    app.signal_error.disconnect(error_handler)
  }

  function error_handler(module_id, method_id, description) {
    console.log('error_handler - source:', module_id, method_id, 'error:', description);
    system_notice.text = description
    system_notice.show()
  }
}
