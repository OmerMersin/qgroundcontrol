import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.Palette

Rectangle {
    id:                 _linkRoot
    color:              qgcPal.window
    anchors.fill:       parent
    anchors.margins:    ScreenTools.defaultFontPixelWidth

    property string advancedModePass:    "dronetools"

    property var _currentSelection:     null
    property int _firstColumnWidth:     ScreenTools.defaultFontPixelWidth * 12
    property int _secondColumnWidth:    ScreenTools.defaultFontPixelWidth * 30
    property int _rowSpacing:           ScreenTools.defaultFontPixelHeight / 2
    property int _colSpacing:           ScreenTools.defaultFontPixelWidth / 2

    QGCPalette {
        id:                 qgcPal
        colorGroupEnabled:  enabled
    }

    //---------------------------------------------
    // Comm Settings
    Rectangle {
        id:             settingsRect
        color:          qgcPal.window
        anchors.fill:   parent
        property real   _panelWidth:    width * 0.8



        QGCFlickable {
            id:                 settingsFlick
            clip:               true
            anchors.fill:       parent
            anchors.margins:    ScreenTools.defaultFontPixelWidth
            contentHeight:      mainLayout.height
            contentWidth:       mainLayout.width

            ColumnLayout {
                id:         mainLayout
                spacing:    _rowSpacing

                QGCGroupBox {
                    //title: originalLinkConfig ? qsTr("Edit Link Configuration Settings") : qsTr("Create New Link Configuration")
                    title: "To access advanced mode, enter the code provided by Dronetools"

                    ColumnLayout {
                        spacing: _rowSpacing

                        GridLayout {
                            columns:        2
                            columnSpacing:  _colSpacing
                            rowSpacing:     _rowSpacing

                            QGCLabel { text: "Password" }


                            QGCTextField {
                                id:                     passwordField
                                Layout.preferredWidth:  _secondColumnWidth
                                Layout.fillWidth:       true
                                echoMode:               TextInput.Password
                                placeholderText:        "**********"
                            }

                        }

                    }
                }

                RowLayout {
                    Layout.alignment:   Qt.AlignHCenter
                    spacing:            _colSpacing

                    QGCButton {
                        width:      ScreenTools.defaultFontPixelWidth * 10
                        text:       qsTr("OK")
                        enabled:    passwordField.text !== ""

                        onClicked: {
                            if(passwordField.text === advancedModePass){
                                if(typeof(settingsView) !== "undefined"){
                                    settingsView.showAdvancedSettings = true
                                }

                                if(typeof(setupView) !== "undefined"){
                                    setupView.advancedModeSetup = true
                                }
                            }else{
                                passwordField.text = ""                            }
                        }
                    }
                }
            }
        }
    }

}
