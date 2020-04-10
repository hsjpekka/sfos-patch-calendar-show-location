import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    function addMapMethod(url, name) {
        var urlList = showLocationUrl.value, labelList = showLocationName.value
        urlList.push(url)
        labelList.push(name)
        showLocationUrl.value = urlList
        showLocationName.value = labelList
        showLocationUrl.sync()
        showLocationName.sync()
        return
    }

    function addToMethodsView(url, name) {
        showMethodsList.append({"itemName": name, "itemMethod": url})//mapMethodsView.model.append({"itemName": name, "itemMethod": url})
        return
    }

    function newMethod(url, name) {
        addMapMethod(url, name)
        addToMethodsView(url, name)
        mapMethodsView.currentIndex = -1
        return
    }

    function showAllMethods() {
        var i = 0
        if (Array.isArray(showLocationUrl.value)) {
            while (i<showLocationUrl.value.length) {
                addToMethodsView(showLocationUrl.value[i], showLocationName.value[i])
                i++
            }
        } else {
            addToMethodsView(showLocationUrl.value, showLocationName.value)
        }
        mapMethodsView.currentIndex = -1

        return
    }

    function saveMethods() {
        var i = 0, urlList = [], labelList = []

        while (i<mapMethodsView.count) {
            urlList.push(showMethodsList.get(i).itemMethod)//mapMethodsView.model.get(i).itemMethod)
            labelList.push(showMethodsList.get(i).itemName)//mapMethodsView.model.get(i).itemName)
            i++
        }
        showLocationName.value = labelList
        showLocationUrl.value = urlList
        showLocationUrl.sync()
        showLocationName.sync()

        return
    }

    ConfigurationValue {
        id: showLocationUrl
        key: "/apps/patchmanager/show-event-location/url"
        defaultValue: ["http://maps.google.com/maps?f=q&q=", ""]
    }

    ConfigurationValue {
        id: showLocationName
        key: "/apps/patchmanager/show-event-location/name"
        defaultValue: ["maps.google.com", "copy to clipboard"]
    }

    RemorsePopup {
        id: remorsePU
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        VerticalScrollDecorator{}

        PullDownMenu {
            MenuItem {
                text: qsTr("reset")
                onClicked: {
                    remorsePU.execute(qsTr("resetting to defaults"), function () {
                        showLocationUrl.value = showLocationUrl.defaultValue
                        showLocationName.value = showLocationName.defaultValue
                        showAllMethods()
                        mapUrl.text = ""
                        mapLabel.text = ""
                    } )
                }
            }

        }

        /*
        PushUpMenu {
            MenuItem {
                text: enabled ? qsTr("add new method") : qsTr("give a label")
                enabled: (mapLabel.text === "" ) ? false : true
                onClicked: {
                    newMethod(mapUrl.text, mapLabel.text)
                }
            }

        } // */

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
                text: qsTr("When the location of a calendar event is tapped, opens the browser and searches for the address by default.")
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
                text: qsTr("Event location schemes")
            }

            Label {
                color: Theme.highlightColor
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                width: parent.width - 2*x
                x: Theme.horizontalPageMargin
                text: qsTr("Tapping the event location executes " +
                           " Qt.openUrlExternally(url + location). If the url is empty," +
                           " copies the location to the clipboard. The first scheme on the" +
                           " list is used by default, when the location is tapped. Press and" +
                           " hold the event location to choose from the whole list:")
            }

            SilicaListView {
                id: mapMethodsView
                width: parent.width
                height: 8*Theme.fontSizeMedium
                clip: true
                highlight: Rectangle {
                    color: Theme.highlightBackgroundColor
                    height: mapMethodsView.currentIndex >= 0 ?
                                mapMethodsView.currentItem.height : Theme.fontSizeMedium
                    radius: Theme.paddingMedium
                    border.color: Theme.highlightColor
                    border.width: 2
                    opacity: Theme.highlightBackgroundOpacity
                }

                highlightFollowsCurrentItem: true

                model: ListModel {
                    id: showMethodsList
                    // ListElement { itemName: "", itemMethod: "" }
                }

                delegate: ListItem {
                    id: mapItem
                    propagateComposedEvents: true
                    _backgroundColor: "transparent" //does not flash - listviews highlight is enough
                    ListView.onRemove: animateRemoval(mapItem)
                    onClicked: {
                        mapUrl.text = itemMethod
                        mapLabel.text = itemName
                        mapMethodsView.currentIndex = mapMethodsView.indexAt(mouseX, y + mouseY)
                    }
                    onPressAndHold: {
                        mapMethodsView.currentIndex = mapMethodsView.indexAt(mouseX, y + mouseY)
                    }

                    menu: ContextMenu {
                        MenuItem {
                            text: qsTr("set as the default action")
                            onClicked: {
                                showMethodsList.move(mapMethodsView.currentIndex, 0, 1)//mapMethodsView.model.move(mapMethodsView.currentIndex-1, 0, 1)
                                saveMethods()
                            }
                        }
                        MenuItem {
                            text: qsTr("delete")
                            onClicked: {
                                var i=mapMethodsView.currentIndex, lbl=showMethodsList.get(i).itemName
                                console.log("poista " + i)
                                remorseAction(qsTr("deleting"), function() {
                                    showMethodsList.remove(i)//mapMethodsView.model.remove(i)
                                    saveMethods()
                                    console.log("poisti " + i)
                                })
                            }
                        }
                    }

                    Label {
                        color: Theme.secondaryColor
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        width: parent.width - 2*x
                        x: Theme.horizontalPageMargin
                        text: itemName
                        font.bold: index == 0 ? true : false
                    }
                }

                VerticalScrollDecorator {}
            }

            Row {
                id: rowMapUrl
                spacing: Theme.paddingMedium
                width: parent.width

                TextField {
                    id: mapUrl
                    placeholderText: qsTr("address search query")
                    text: ""
                    label: (text === "") ? qsTr("copy to clipboard") : qsTr("full url (http://..., geo://..., ..)")
                    width: parent.width - mapUrlClear.width - 2*rowMapUrl.spacing
                    EnterKey.enabled: text.length > 0
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: mapLabel.focus = true
                }

                IconButton {
                    id: mapUrlClear
                    icon.source: "image://theme/icon-m-clear"
                    width: Theme.iconSizeMedium
                    height: width
                    onClicked: {
                        mapMethodsView.currentIndex = -1
                        mapUrl.text = ""
                    }
                }
            }

            Row {
                id: rowMapLabel
                spacing: rowMapUrl.spacing
                width: parent.width

                TextField {
                    id: mapLabel
                    placeholderText: qsTr("label")
                    text: ""
                    label: qsTr("label")
                    labelVisible: true
                    width: parent.width - mapLabelClear.width - 2*rowMapLabel.spacing
                    EnterKey.enabled: text.length > 0
                    EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                    EnterKey.onClicked: {
                        mapLabel.focus = false
                        newMethod(mapUrl.text, text)
                    }
                }

                IconButton {
                    id: mapLabelClear
                    width: Theme.iconSizeMedium
                    height: width
                    icon.source: "image://theme/icon-m-clear"
                    onClicked: {
                        mapMethodsView.currentIndex = -1
                        mapLabel.text = ""
                    }
                }
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

            Label {
                text: qsTr("To open the address in some map-app, x-scheme-handlers can be used."
                           + " But they are out of the scope of this patch.")
                color: Theme.highlightColor
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                width: parent.width - 2*x
                x: Theme.horizontalPageMargin
            }

        }
    }

    Component.onCompleted: {
        if ( Array.isArray(showLocationUrl.value) && Array.isArray(showLocationName.value)) {
            if (showLocationUrl.value.length === 0) {
                showLocationName.value = showLocationName.defaultValue
                showLocationUrl.value = showLocationUrl.defaultValue
            }

            var i=0
            showMethodsList.clear()//mapMethodsView.model.clear()
            while (i<showLocationUrl.value.length) {
                console.log("lisää " + i + "/" + (showLocationUrl.value.length-1) + " : "
                            + showLocationUrl.value[i] + " - " + showLocationName.value[i])
                addToMethodsView(showLocationUrl.value[i], showLocationName.value[i])
                i++
            }
            mapMethodsView.currentIndex = -1
        } else { // in the first version, ConfigurationValue was a string, not a list
            var strUrl = showLocationUrl.value, strName = showLocationName.value
            showMethodsList.clear()//mapMethodsView.model.clear()
            showLocationName.value = []
            showLocationUrl.value = []
            newMethod(strUrl, strName)
            newMethod("", "copy to clipboard")
        }
    }

}
