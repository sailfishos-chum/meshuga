# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-meshuga

CONFIG += sailfishapp_qml

DISTFILES += qml/harbour-meshuga.qml \
    qml/cover/CoverPage.qml \
    qml/pages/ChannelMessagesPage.qml \
    qml/pages/ChannelsTab.qml \
    qml/pages/ChatInputWidget.qml \
    qml/pages/ConversationBubble.qml \
    qml/pages/ConversationsSectionWidget.qml \
    qml/pages/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/MainPage.qml \
    qml/pages/MapPage.qml \
    qml/pages/MapTab.qml \
    qml/pages/MessageLocationWidget.qml \
    qml/pages/MessagesTab.qml \
    qml/pages/MessageTextWidget.qml \
    qml/pages/NodeItem.qml \
    qml/pages/NodesTab.qml \
    qml/pages/NotificationsHandler.qml \
    qml/pages/PythonHandler.qml \
    qml/pages/SecondPage.qml \
    qml/pages/SettingsDialog.qml \
    rpm/harbour-meshuga.changes.in \
    rpm/harbour-meshuga.changes.run.in \
    rpm/harbour-meshuga.spec \
    translations/*.ts \
    harbour-meshuga.desktop \
    src/*.py


SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-meshuga-de.ts
