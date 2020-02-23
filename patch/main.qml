import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    function verifyAddress(address) {
        var result = ""
        if (checkHttp(address) === 0) {
            result = "http://" + address
        } else {
            result = address
        }

        return result
    }

    function checkHttp(address) {
        var start = /^http[s]*:\/\//i, matches, result
        matches = address.match(start)
        if (matches !== null)
            result = matches.length
        else
            result = 0

        return result
    }

    ConfigurationValue {
        id: showLocationUrl
        key: "/apps/patchmanager/show-event-location/url"
        defaultValue: "http://maps.google.com/maps?f=q&q="
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        VerticalScrollDecorator{}

        PullDownMenu {
            MenuItem {
                text: qsTr("read")
                onClicked: {
                    mapUrl.text = showLocationUrl.value
                }
            }
            MenuItem {
                text: qsTr("reset")
                onClicked: {
                    showLocationUrl.value = showLocationUrl.defaultValue
                    mapUrl.text = showLocationUrl.defaultValue
                }
            }
            MenuItem {
                text: qsTr("save")
                onClicked: {
                    showLocationUrl.value = verifyAddress(mapUrl.text)
                    mapUrl.text = showLocationUrl.value
                }
            }
        }

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: "Show calendar event location"
            }

            SectionHeader {
                text: qsTr("Description")
            }

            Label {
                text: qsTr("When the location of a calendar event is tapped, opens the browser and searches for the address (Qt.openUrlExternally()).")
                color: Theme.highlightColor
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                width: parent.width - 2*x
                x: Theme.horizontalPageMargin
            }

            Label {
                text: qsTr("Modifies CalendarEventView.qml.")
                color: Theme.highlightColor
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                width: parent.width - 2*x
                x: Theme.horizontalPageMargin
            }

            SectionHeader {
                text: qsTr("settings")
            }

            TextField {
                id: mapUrl
                placeholderText: qsTr("address search query")
                text: showLocationUrl.value
                label: qsTr("www-page")
                width: parent.width - 2*x
                x: Theme.horizontalPageMargin
            }

            TextArea {
                text: qsTr("%1 claims to be incompatible with the native browser, and %2 doesn't show the map.").arg("wego.here.com/directions/drive/").arg("www.bing.com/maps?where1=")
                color: Theme.secondaryColor
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                width: parent.width - 2*x
                //x: Theme.horizontalPageMargin
                readOnly: true
                focusOnClick: true
            }

            SectionHeader {
                text: qsTr("to do")
            }

            Label {
                id: todoLabel
                text: qsTr("Find a way to send the address to some map-program.\nMaep, OSM Scout, weGo, for example.")
                color: Theme.highlightColor
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                width: parent.width - 2*x
                x: Theme.horizontalPageMargin
            }

        }
    }

    Component.onDestruction: {
        if (showLocationUrl.value != mapUrl.text) {
            showLocationUrl.value = verifyAddress(mapUrl.text)
        }
    }

}
