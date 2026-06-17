import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../../services"
import "../../../config"
import "../../../components"

PillSurface {
    id: root

    property int pillHeight: ThemeService.sideCapsuleHeight
    property int closePopupsToken: 0

    signal popupOpened()

    height: pillHeight
    width: wifiRow.implicitWidth + ThemeService.radiusLarge
    onClicked: wifiPopup.toggle()

    Row {
        id: wifiRow
        anchors.centerIn: parent
        spacing: ThemeService.spacingSmall

        Text {
            text: NetworkService.wifiIcon
            font.family: ThemeService.iconFont
            font.pixelSize: 13
            color: NetworkService.wifiConnected ? ThemeService.secondary : ThemeService.textDim
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: NetworkService.wifiConnected ? NetworkService.wifiSignal + "%" : "Off"
            font.family: ThemeService.fontName
            font.pixelSize: 11
            font.weight: Font.DemiBold
            color: NetworkService.wifiConnected ? ThemeService.foreground : ThemeService.textDim
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    PopupSurface {
        id: wifiPopup

        property int popupWidth: 280
        property int popupMaxHeight: 360
        property int popupPadding: 10
        property bool passwordMode: false
        property var passwordNetwork: null
        property string passwordText: ""
        property string passwordError: ""

        anchor.item: root
        anchor.rect.x: root.width - implicitWidth
        anchor.rect.y: root.height + ThemeService.spacingMedium
        anchor.rect.width: 0
        anchor.rect.height: 0

        implicitWidth: popupWidth
        implicitHeight: Math.min(wifiColumn.implicitHeight + popupPadding * 2, popupMaxHeight)

        onOpening: {
            OverlayService.closeIsland(false);
            root.popupOpened();
            clearPasswordState();
            NetworkService.refresh();
            if (NetworkService.wifiEnabled) NetworkService.rescan();
        }

        onClosing: clearPasswordState()

        Flickable {
            anchors.fill: parent
            contentWidth: width
            contentHeight: wifiColumn.implicitHeight
            clip: true

            Column {
                id: wifiColumn
                width: parent.width
                spacing: 6

                Row {
                    width: parent.width
                    height: 30
                    spacing: ThemeService.spacingSmall

                    Text {
                        text: "󰤨"
                        font.family: ThemeService.iconFont
                        font.pixelSize: 15
                        color: ThemeService.secondary
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        width: parent.width - wifiToggle.width - 30
                        text: "Wi-Fi"
                        color: ThemeService.textBright
                        font.family: ThemeService.fontName
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledRect {
                        id: wifiToggle
                        width: 34
                        height: 18
                        radius: height / 2
                        rectColor: NetworkService.wifiEnabled ? ThemeService.primary : ThemeService.surfaceBright
                        rectOpacity: NetworkService.wifiEnabled ? 0.95 : (toggleMouse.containsMouse ? 0.6 : 0.35)
                        borderOpacityValue: 0.0

                        Rectangle {
                            width: 14
                            height: 14
                            radius: 7
                            x: NetworkService.wifiEnabled ? parent.width - width - 2 : 2
                            anchors.verticalCenter: parent.verticalCenter
                            color: NetworkService.wifiEnabled ? ThemeService.background : ThemeService.textDim
                            Behavior on x { NumberAnimation { duration: 160; easing.type: Easing.OutQuad } }
                            Behavior on color { ColorAnimation { duration: 160 } }
                        }

                        MouseArea {
                            id: toggleMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: NetworkService.setWifiEnabled(!NetworkService.wifiEnabled)
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: ThemeService.surfaceBright; opacity: 0.8 }

                    Text {
                        visible: NetworkService.wifiConnected
                        width: parent.width
                        text: "Connected to " + NetworkService.wifiName
                        color: ThemeService.textDim
                        font.family: ThemeService.fontName
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }

                    Text {
                        visible: NetworkService.connecting
                        width: parent.width
                        text: "Connecting to " + NetworkService.connectingSsid + "..."
                        color: ThemeService.textDim
                        font.family: ThemeService.fontName
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }

                    Text {
                        visible: NetworkService.connectionError.length > 0 && !wifiPopup.passwordMode
                        width: parent.width
                        text: NetworkService.connectionError
                        color: ThemeService.danger
                        font.family: ThemeService.fontName
                        font.pixelSize: 11
                        wrapMode: Text.WordWrap
                    }

                    Column {
                        visible: wifiPopup.passwordMode
                        width: parent.width
                        spacing: 8

                        Text {
                            width: parent.width
                            text: "Password for " + (wifiPopup.passwordNetwork ? wifiPopup.passwordNetwork.ssid : "")
                            color: ThemeService.textBright
                            font.family: ThemeService.fontName
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            width: parent.width
                            height: 36
                            radius: ThemeService.radiusSmall
                            color: ThemeService.surface
                            border.width: 1
                            border.color: passwordInput.activeFocus
                                ? Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.75)
                                : Qt.rgba(ThemeService.border.r, ThemeService.border.g, ThemeService.border.b, 0.16)

                            TextInput {
                                id: passwordInput
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                verticalAlignment: TextInput.AlignVCenter
                                color: ThemeService.foreground
                                selectionColor: Qt.rgba(ThemeService.primary.r, ThemeService.primary.g, ThemeService.primary.b, 0.35)
                                selectedTextColor: ThemeService.textBright
                                font.family: ThemeService.fontName
                                font.pixelSize: 12
                                echoMode: TextInput.Password
                                clip: true
                                text: wifiPopup.passwordText
                                onTextChanged: {
                                    wifiPopup.passwordText = text;
                                    if (text.length > 0) wifiPopup.passwordError = "";
                                }
                                Keys.onPressed: event => {
                                    if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                                        wifiPopup.submitPassword();
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Escape) {
                                        wifiPopup.cancelPassword();
                                        event.accepted = true;
                                    }
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Enter password"
                                    color: ThemeService.textDim
                                    font.family: ThemeService.fontName
                                    font.pixelSize: 12
                                    visible: parent.text.length === 0
                                }
                            }
                        }

                        Text {
                            visible: wifiPopup.passwordError.length > 0
                            width: parent.width
                            text: wifiPopup.passwordError
                            color: ThemeService.danger
                            font.family: ThemeService.fontName
                            font.pixelSize: 11
                            wrapMode: Text.WordWrap
                        }

                        Row {
                            width: parent.width
                            height: 30
                            spacing: 8

                            StyledRect {
                                width: (parent.width - parent.spacing) / 2
                                height: parent.height
                                radius: ThemeService.radiusSmall
                                rectColor: ThemeService.surfaceBright
                                rectOpacity: cancelMouse.containsMouse ? 0.55 : 0.32
                                borderOpacityValue: 0.0

                                Text {
                                    anchors.centerIn: parent
                                    text: "Cancel"
                                    color: ThemeService.foreground
                                    font.family: ThemeService.fontName
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                }

                                MouseArea {
                                    id: cancelMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: wifiPopup.cancelPassword()
                                }
                            }

                            StyledRect {
                                width: (parent.width - parent.spacing) / 2
                                height: parent.height
                                radius: ThemeService.radiusSmall
                                rectColor: ThemeService.primary
                                rectOpacity: NetworkService.connecting ? 0.45 : (connectMouse.containsMouse ? 0.95 : 0.78)
                                borderOpacityValue: 0.0

                                Text {
                                    anchors.centerIn: parent
                                    text: NetworkService.connecting ? "Connecting" : "Connect"
                                    color: ThemeService.background
                                    font.family: ThemeService.fontName
                                    font.pixelSize: 12
                                    font.weight: Font.DemiBold
                                }

                                MouseArea {
                                    id: connectMouse
                                    anchors.fill: parent
                                    enabled: !NetworkService.connecting
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: wifiPopup.submitPassword()
                                }
                            }
                        }
                    }

                    Repeater {
                        model: NetworkService.wifiEnabled && !wifiPopup.passwordMode ? NetworkService.wifiNetworks : []

                        StyledRect {
                            id: wifiItem
                            required property var modelData
                            width: wifiColumn.width
                            height: 36
                            radius: ThemeService.radiusSmall
                            rectColor: modelData.active ? ThemeService.primary : ThemeService.surfaceBright
                            rectOpacity: modelData.active ? 0.22 : (wifiItemMouse.containsMouse ? 0.55 : 0.2)
                            borderOpacityValue: 0.0

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 9
                                anchors.rightMargin: 9
                                spacing: ThemeService.spacingSmall

                                Text {
                                    text: modelData.signal >= 75 ? "󰤨" : (modelData.signal >= 50 ? "󰤥" : (modelData.signal >= 25 ? "󰤢" : "󰤟"))
                                    font.family: ThemeService.iconFont
                                    font.pixelSize: 13
                                    color: modelData.active ? ThemeService.primary : ThemeService.foreground
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    width: parent.width - 72
                                    text: modelData.ssid
                                    color: modelData.active ? ThemeService.textBright : ThemeService.foreground
                                    font.family: ThemeService.fontName
                                    font.pixelSize: 12
                                    font.weight: modelData.active ? Font.DemiBold : Font.Medium
                                    elide: Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: modelData.secured ? "󰌾" : ""
                                    font.family: ThemeService.iconFont
                                    font.pixelSize: 12
                                    color: ThemeService.textDim
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: modelData.active ? "✓" : modelData.signal + "%"
                                    font.pixelSize: 11
                                    color: modelData.active ? ThemeService.success : ThemeService.textDim
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: wifiItemMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    NetworkService.connectToNetwork(modelData);
                                    if (!modelData.secured) wifiPopup.close();
                                }
                            }
                        }
                    }

                    Text {
                        visible: !wifiPopup.passwordMode && (!NetworkService.wifiEnabled || NetworkService.wifiNetworks.length === 0)
                        width: parent.width
                        text: !NetworkService.wifiEnabled ? "Wi-Fi is off" : (NetworkService.scanning ? "Scanning..." : "No networks found")
                        color: ThemeService.textDim
                        font.family: ThemeService.fontName
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        padding: 10
                    }
                }
            }

        function clearPasswordState() {
            passwordMode = false;
            passwordNetwork = null;
            passwordText = "";
            passwordError = "";
        }

        function requestPassword(network) {
            if (!visible) open();
            passwordNetwork = network;
            passwordText = "";
            passwordError = "";
            passwordMode = true;
            Qt.callLater(() => passwordInput.forceActiveFocus());
        }

        function cancelPassword() {
            clearPasswordState();
        }

        function submitPassword() {
            if (!passwordNetwork || passwordText.length === 0 || NetworkService.connecting) {
                passwordError = "Password is required";
                return;
            }
            NetworkService.connectToNetworkWithPassword(passwordNetwork, passwordText);
        }

        function closePasswordIfConnected(ssid) {
            if (passwordMode && passwordNetwork && ssid === passwordNetwork.ssid) {
                close();
            }
        }
    }

    Connections {
        target: NetworkService

        function onPasswordRequired(network) {
            wifiPopup.requestPassword(network);
        }

        function onWifiConnectedChanged() {
            if (NetworkService.wifiConnected) wifiPopup.closePasswordIfConnected(NetworkService.wifiName);
        }

        function onWifiNameChanged() {
            wifiPopup.closePasswordIfConnected(NetworkService.wifiName);
        }

        function onConnectionSucceeded(ssid) {
            wifiPopup.closePasswordIfConnected(ssid);
        }

        function onConnectionErrorChanged() {
            if (wifiPopup.passwordMode && NetworkService.connectionError.length > 0) {
                wifiPopup.passwordError = NetworkService.connectionError;
                wifiPopup.passwordText = "";
                Qt.callLater(() => passwordInput.forceActiveFocus());
            }
        }
    }

    onClosePopupsTokenChanged: wifiPopup.close()
}
