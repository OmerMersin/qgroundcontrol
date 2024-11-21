/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.MultiVehicleManager
import QGroundControl.ScreenTools
import QGroundControl.Controllers

Rectangle {
    id:     _root
    width:  parent.width
    height: ScreenTools.toolbarHeight
    color:  qgcPal.toolbarBackground

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property bool   _communicationLost: _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
    property color  _mainStatusBGColor: qgcPal.brandingGreen

    function dropMessageIndicatorTool() {
        toolIndicators.dropMessageIndicatorTool();
    }

    QGCPalette { id: qgcPal }

    /// Bottom single pixel divider
    Rectangle {
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
        height:         1
        color:          "black"
        visible:        qgcPal.globalTheme === QGCPalette.Light
    }

    Rectangle {
        anchors.fill: viewButtonRow
        
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0;                                     color: _mainStatusBGColor }
            GradientStop { position: currentButton.x + currentButton.width; color: _mainStatusBGColor }
            GradientStop { position: 1;                                     color: _root.color }
        }
    }

    RowLayout {
        id:                     viewButtonRow
        anchors.bottomMargin:   1
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        spacing:                ScreenTools.defaultFontPixelWidth / 2

        QGCToolBarButton {
            id:                     currentButton
            Layout.preferredHeight: viewButtonRow.height
            icon.source:            "/res/DronetoolsLogoFull"
            logo:                   true
            onClicked:              mainWindow.showToolSelectDialog()
        }

        MainStatusIndicator {
            Layout.preferredHeight: viewButtonRow.height
        }

        // QGCButton {
        //     id:                 disconnectButton
        //     text:               qsTr("Disconnect")
        //     onClicked:          _activeVehicle.closeVehicle()
        //     visible:            _activeVehicle && _communicationLost
        // }
    }

    QGCFlickable {
        id:                     toolsFlickable
        anchors.leftMargin:     !ScreenTools.isMobile? ScreenTools.defaultFontPixelWidth * ScreenTools.largeFontPointRatio * 1.5: ScreenTools.defaultFontPixelWidth * ScreenTools.largeFontPointRatio * 0.25
        anchors.left:           viewButtonRow.right
        anchors.bottomMargin:   1
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.right:          escTemperatureArea.left
        contentWidth:           toolIndicators.width
        flickableDirection:     Flickable.HorizontalFlick
        // enabled:                true

        FlyViewToolBarIndicators { id: toolIndicators }
    }

    Rectangle {
        id:                     escTemperatureArea
        color:                  "transparent"
        anchors.right:          brandingImage.left
        anchors.bottom:         parent.bottom
        anchors.rightMargin:    ScreenTools.defaultFontPixelHeight * 0.66
        visible:                escTemperatureArea.getMaxTemperature() <= 0 ? false:true

        // Dynamically adjust width and height based on content
        implicitWidth:      rowContent.implicitWidth

        // Adjust width and height dynamically based on visibility
        width:                  visible ? implicitWidth : 0
        height:                 visible ? parent.height : 0

        function getMaxTemperature() {
            const temperatures = [
                _activeVehicle?.escStatus?.temperature1?.rawValue ?? 0,
                _activeVehicle?.escStatus?.temperature2?.rawValue ?? 0,
                _activeVehicle?.escStatus?.temperature3?.rawValue ?? 0,
                _activeVehicle?.escStatus?.temperature4?.rawValue ?? 0
            ];
            return Math.max(...temperatures);
        }


        RowLayout {
            id: rowContent
            anchors.centerIn:   parent

            // Temperature indicator dot
            Rectangle {
                width:          ScreenTools.isMobile ? 20 : 30
                height:         ScreenTools.isMobile ? 20 : 30
                radius:         width / 2   // Make it circular
                color: {
                    // Change color based on max temperature
                    var maxTemp = escTemperatureArea.getMaxTemperature();
                    if (maxTemp < 10) {
                        return qgcPal.colorRed;     // High temperature
                    } else if (maxTemp <= 80) {
                        return qgcPal.colorGreen;  // Moderate temperature
                    } else if (maxTemp <= 95) {
                        return qgcPal.colorOrange;  // Moderate temperature
                    } else {
                        return qgcPal.colorRed;   // Safe temperature
                    }
                }
            }

            QGCLabel {
                text:                   ScreenTools.isMobile ? qsTr("Motor Temp:\n%1°C").arg(escTemperatureArea.getMaxTemperature().toFixed(1))
                                                       : qsTr("Motor Temp: %1°C").arg(escTemperatureArea.getMaxTemperature().toFixed(1))
                font.bold:              false
                font.pixelSize:         ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth * 1.6 : ScreenTools.defaultFontPixelWidth * 2
                color:                  qgcPal.text
                horizontalAlignment:    Text.AlignHCenter
                wrapMode:               ScreenTools.isMobile ? Text.WordWrap : Text.NoWrap
            }
        }
    }






    //-------------------------------------------------------------------------
    //-- Branding Logo
    Image {
        id:                     brandingImage
        anchors.right:          parent.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.margins:        ScreenTools.defaultFontPixelHeight * 0.66
        visible:                ScreenTools.isMobile? !(QGroundControl.multiVehicleManager.vehicles.count > 1) : true
        fillMode:               Image.PreserveAspectFit
        // source:                 _outdoorPalette ? _brandImageOutdoor : _brandImageIndoor
        source:                 "/qmlimages/Dronetools/BrandImage";
        mipmap:                 true

        property bool   _outdoorPalette:        qgcPal.globalTheme === QGCPalette.Light
        property bool   _corePluginBranding:    QGroundControl.corePlugin.brandImageIndoor.length != 0
        property string _userBrandImageIndoor:  QGroundControl.settingsManager.brandImageSettings.userBrandImageIndoor.value
        property string _userBrandImageOutdoor: QGroundControl.settingsManager.brandImageSettings.userBrandImageOutdoor.value
        property bool   _userBrandingIndoor:    QGroundControl.settingsManager.brandImageSettings.visible && _userBrandImageIndoor.length != 0
        property bool   _userBrandingOutdoor:   QGroundControl.settingsManager.brandImageSettings.visible && _userBrandImageOutdoor.length != 0
        property string _brandImageIndoor:      brandImageIndoor()
        property string _brandImageOutdoor:     brandImageOutdoor()

        function brandImageIndoor() {
            if (_userBrandingIndoor) {
                return _userBrandImageIndoor
            } else {
                if (_userBrandingOutdoor) {
                    return _userBrandImageOutdoor
                } else {
                    if (_corePluginBranding) {
                        return QGroundControl.corePlugin.brandImageIndoor
                    } else {
                        return _activeVehicle ? _activeVehicle.brandImageIndoor : ""
                    }
                }
            }
        }

        function brandImageOutdoor() {
            if (_userBrandingOutdoor) {
                return _userBrandImageOutdoor
            } else {
                if (_userBrandingIndoor) {
                    return _userBrandImageIndoor
                } else {
                    if (_corePluginBranding) {
                        return QGroundControl.corePlugin.brandImageOutdoor
                    } else {
                        return _activeVehicle ? _activeVehicle.brandImageOutdoor : ""
                    }
                }
            }
        }
    }

    // Small parameter download progress bar
    Rectangle {
        anchors.bottom: parent.bottom
        height:         _root.height * 0.05
        width:          _activeVehicle ? _activeVehicle.loadProgress * parent.width : 0
        color:          qgcPal.colorGreen
        visible:        !largeProgressBar.visible
    }

    // Large parameter download progress bar
    Rectangle {
        id:             largeProgressBar
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
        height:         parent.height
        color:          qgcPal.window
        visible:        _showLargeProgress

        property bool _initialDownloadComplete: _activeVehicle ? _activeVehicle.initialConnectComplete : true
        property bool _userHide:                false
        property bool _showLargeProgress:       !_initialDownloadComplete && !_userHide && qgcPal.globalTheme === QGCPalette.Light

        Connections {
            target:                 QGroundControl.multiVehicleManager
            function onActiveVehicleChanged(activeVehicle) { largeProgressBar._userHide = false }
        }

        Rectangle {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            width:          _activeVehicle ? _activeVehicle.loadProgress * parent.width : 0
            color:          qgcPal.colorGreen
        }

        QGCLabel {
            anchors.centerIn:   parent
            text:               qsTr("Downloading")
            font.pointSize:     ScreenTools.largeFontPointSize
        }

        QGCLabel {
            anchors.margins:    _margin
            anchors.right:      parent.right
            anchors.bottom:     parent.bottom
            text:               qsTr("Click anywhere to hide")

            property real _margin: ScreenTools.defaultFontPixelWidth / 2
        }

        MouseArea {
            anchors.fill:   parent
            onClicked:      largeProgressBar._userHide = true
        }
    }
}
