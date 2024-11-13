/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.MultiVehicleManager
import QGroundControl.ScreenTools
import QGroundControl.Palette
import QGroundControl.FactSystem
import QGroundControl.FactControls
import MAVLink

//-------------------------------------------------------------------------
//-- Battery Indicator
Item {
    id:             control
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    width:          batteryIndicatorRow.width

    property bool       showIndicator:      true
    property bool       waitForParameters:  false   // UI won't show until parameters are ready
    property Component  expandedPageComponent

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property Fact   _indicatorDisplay:  QGroundControl.settingsManager.batteryIndicatorSettings.display
    property bool   _showBoth:          _indicatorDisplay.rawValue === 2

    // Fetch battery settings
    property var batterySettings: QGroundControl.settingsManager.batteryIndicatorSettings

    // Properties to hold the thresholds
    property int threshold1: batterySettings.threshold1.rawValue
    property int threshold2: batterySettings.threshold2.rawValue

    // Control visibility based on battery state display setting
    property bool batteryState: batterySettings.battery_state_display.rawValue
    property bool threshold1visible: batterySettings.threshold1visible.rawValue
    property bool threshold2visible: batterySettings.threshold2visible.rawValue

    Row {
        id:             batteryIndicatorRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom

        Repeater {
            model: _activeVehicle ? _activeVehicle.batteries : 0

            Loader {
                anchors.top:        parent.top
                anchors.bottom:     parent.bottom
                sourceComponent:    batteryVisual

                property var battery: object
            }
        }
    }
    MouseArea {
        anchors.fill:   parent
        onClicked: {
            mainWindow.showIndicatorDrawer(batteryPopup, control)
        }
    }

    Component {
        id: batteryPopup

        ToolIndicatorPage {
            showExpand:         expandedComponent ? true : false
            waitForParameters:  control.waitForParameters
            contentComponent:   batteryContentComponent
            expandedComponent:  batteryExpandedComponent
        }
    }

    Component {
        id: batteryVisual

        Row {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom

            // function getBatteryColor() {
            //     switch (battery.chargeState.rawValue) {
            //         case MAVLink.MAV_BATTERY_CHARGE_STATE_OK:
            //             if (!isNaN(battery.percentRemaining.rawValue)) {
            //                 if (battery.percentRemaining.rawValue > threshold1) {
            //                     return qgcPal.colorGreen
            //                 } else if (battery.percentRemaining.rawValue > threshold2) {
            //                     return qgcPal.colorYellowGreen
            //                 } else {
            //                     return qgcPal.colorYellow
            //                 }
            //             } else {
            //                 return qgcPal.text
            //             }
            //         case MAVLink.MAV_BATTERY_CHARGE_STATE_LOW:
            //             return qgcPal.colorOrange
            //         case MAVLink.MAV_BATTERY_CHARGE_STATE_CRITICAL:
            //         case MAVLink.MAV_BATTERY_CHARGE_STATE_EMERGENCY:
            //         case MAVLink.MAV_BATTERY_CHARGE_STATE_FAILED:
            //         case MAVLink.MAV_BATTERY_CHARGE_STATE_UNHEALTHY:
            //             return qgcPal.colorRed
            //         default:
            //             return qgcPal.text
            //     }
            // }

            // function getBatterySvgSource() {
            //     switch (battery.chargeState.rawValue) {
            //         case MAVLink.MAV_BATTERY_CHARGE_STATE_OK:
            //             if (!isNaN(battery.percentRemaining.rawValue)) {
            //                 if (battery.percentRemaining.rawValue > threshold1) {
            //                     return "/qmlimages/BatteryGreen.svg"
            //                 } else if (battery.percentRemaining.rawValue > threshold2) {
            //                     return "/qmlimages/BatteryYellowGreen.svg"
            //                 } else {
            //                     return "/qmlimages/BatteryYellow.svg"
            //                 }
            //             }
            //         case MAVLink.MAV_BATTERY_CHARGE_STATE_LOW:
            //             return "/qmlimages/BatteryOrange.svg" // Low with orange svg
            //         case MAVLink.MAV_BATTERY_CHARGE_STATE_CRITICAL:
            //             return "/qmlimages/BatteryCritical.svg" // Critical with red svg
            //         case MAVLink.MAV_BATTERY_CHARGE_STATE_EMERGENCY:
            //         case MAVLink.MAV_BATTERY_CHARGE_STATE_FAILED:
            //         case MAVLink.MAV_BATTERY_CHARGE_STATE_UNHEALTHY:
            //             return "/qmlimages/BatteryEMERGENCY.svg" // Exclamation mark
            //         default:
            //             return "/qmlimages/Battery.svg" // Fallback if percentage is unavailable
            //     }
            // }

            function getBatteryColor() {
                var percentageText = getBatteryPercentageText();
                var percentage = parseInt(percentageText.replace("%", ""));

                if (!isNaN(percentage)) {
                    if (percentage >= 75) {
                        return qgcPal.colorGreen;
                    } else if (percentage >= 50) {
                        return qgcPal.colorYellowGreen;
                    } else if (percentage >= 25) {
                        return qgcPal.colorYellow;
                    } else if (percentage >= 10) {
                        return qgcPal.colorOrange;
                    } else {
                        return qgcPal.colorRed;
                    }
                }
                return qgcPal.text; // Default color if percentage is unavailable
            }

            function getBatterySvgSource() {
                var percentageText = getBatteryPercentageText();
                var percentage = parseInt(percentageText.replace("%", ""));

                if (!isNaN(percentage)) {
                    if (percentage >= 75) {
                        return "/qmlimages/BatteryGreen.svg";
                    } else if (percentage >= 50) {
                        return "/qmlimages/BatteryYellowGreen.svg";
                    } else if (percentage >= 25) {
                        return "/qmlimages/BatteryYellow.svg";
                    } else if (percentage >= 10) {
                        return "/qmlimages/BatteryOrange.svg";
                    } else {
                        return "/qmlimages/BatteryCritical.svg"; // Critical with red SVG
                    }
                }
                return "/qmlimages/Battery.svg"; // Fallback if percentage is unavailable
            }


            // function getBatteryPercentageText() {
            //     if (!isNaN(battery.percentRemaining.rawValue)) {
            //         if (battery.percentRemaining.rawValue > 98.9) {
            //             return qsTr("100%")
            //         } else {
            //             return battery.percentRemaining.valueString + battery.percentRemaining.units
            //         }
            //     }
            //     return qsTr("n/a")
            // }

            function getBatteryPercentageText(){
                var voltage = battery.voltage.rawValue
                var cellVoltage, percentage = "n/a"

                function interpolate(minVoltage, maxVoltage, minPercentage, maxPercentage, voltage) {
                    return ((voltage - minVoltage) / (maxVoltage - minVoltage)) * (maxPercentage - minPercentage) + minPercentage
                }

                if(!isNaN(voltage)){
                    if (voltage > 25) {
                        cellVoltage = voltage / 12
                    } else if (voltage < 25) {
                        cellVoltage = voltage / 6
                    } else {
                        return battery.chargeState.enumStringValue
                    }

                    if(cellVoltage > 3.9166){
                        percentage = 100
                    } else if(cellVoltage > 3.75) {
                        percentage = interpolate(3.75, 3.9166, 75, 100, cellVoltage)
                    } else if(cellVoltage > 3.5583) {
                        percentage = interpolate(3.5583, 3.75, 50, 75, cellVoltage)
                    } else if(cellVoltage > 3.4166) {
                        percentage = interpolate(3.4166, 3.5583, 30, 50, cellVoltage)
                    } else if(cellVoltage > 3.3333) {
                        percentage = interpolate(3.3333, 3.4166, 25, 30, cellVoltage)
                    } else if(cellVoltage > 3.25) {
                        percentage = interpolate(3.25, 3.3333, 10, 25, cellVoltage)
                    } else {
                        percentage = 0
                    }

                    return `${Math.round(percentage)}%`
                }
                return qsTr("n/a")
            }


            function getBatteryVoltageText() {
                if (!isNaN(battery.voltage.rawValue)) {
                    return battery.voltage.valueString + battery.voltage.units
                }
                return qsTr("n/a")
            }

            function getBatteryConsumedText() {
                if (!isNaN(battery.mahConsumed.rawValue)) {
                    return battery.mahConsumed.valueString + " " + battery.mahConsumed.units
                }
                return qsTr("n/a")
            }

            QGCColoredImage {
                anchors.top:        parent.top
                anchors.bottom:     parent.bottom
                width:              height
                sourceSize.width:   width
                source:             getBatterySvgSource()
                fillMode:           Image.PreserveAspectFit
                color:              getBatteryColor()
            }

            ColumnLayout {
                id:                     batteryInfoColumn
                anchors.top:            parent.top  // Aligns the column to the top of the toolbar
                anchors.topMargin:      -ScreenTools.defaultFontPixelHeight * 0.5  // Adds some padding from the top
                spacing:                0     // Reduces space between elements

                // Percentage
                QGCLabel {
                    Layout.alignment:       Qt.AlignHCenter
                    verticalAlignment:      Text.AlignVCenter
                    color:                  qgcPal.text
                    text:                   getBatteryPercentageText()
                    font.pointSize:         ScreenTools.smallFontPointSize
                }

                // Voltage
                QGCLabel {
                    Layout.alignment:       Qt.AlignHCenter
                    verticalAlignment:      Text.AlignVCenter
                    color:                  qgcPal.text
                    text:                   getBatteryVoltageText()
                    font.pointSize:         ScreenTools.smallFontPointSize
                }

                // mAh Consumed
                QGCLabel {
                    Layout.alignment:       Qt.AlignHCenter
                    verticalAlignment:      Text.AlignVCenter
                    color:                  qgcPal.text
                    text:                   getBatteryConsumedText()
                    font.pointSize:         ScreenTools.smallFontPointSize
                }
            }
        }
    }

    Component {
        id: batteryContentComponent

        ColumnLayout {
            spacing: ScreenTools.defaultFontPixelHeight / 2

            property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

            Component {
                id: batteryValuesAvailableComponent

                QtObject {
                    property bool functionAvailable:         battery.function.rawValue !== MAVLink.MAV_BATTERY_FUNCTION_UNKNOWN
                    property bool temperatureAvailable:      !isNaN(battery.temperature.rawValue)
                    property bool currentAvailable:          !isNaN(battery.current.rawValue)
                    property bool mahConsumedAvailable:      !isNaN(battery.mahConsumed.rawValue)
                    property bool timeRemainingAvailable:    !isNaN(battery.timeRemaining.rawValue)
                    property bool percentRemainingAvailable: !isNaN(battery.percentRemaining.rawValue)
                    property bool chargeStateAvailable:      battery.chargeState.rawValue !== MAVLink.MAV_BATTERY_CHARGE_STATE_UNDEFINED
                }
            }

            Repeater {
                model: _activeVehicle ? _activeVehicle.batteries : 0

                SettingsGroupLayout {
                    heading:        qsTr("Battery %1").arg(_activeVehicle.batteries.length === 1 ? qsTr("Status") : object.id.rawValue)
                    contentSpacing: 0
                    showDividers:   false

                    property var batteryValuesAvailable: batteryValuesAvailableLoader.item

                    Loader {
                        id:                 batteryValuesAvailableLoader
                        sourceComponent:    batteryValuesAvailableComponent

                        property var battery: object
                    }

                    LabelledLabel {
                        label:  qsTr("Charge State")
                        labelText:  object.chargeState.enumStringValue
                        visible:    batteryValuesAvailable.chargeStateAvailable
                    }

                    LabelledLabel {
                        label:      qsTr("Remaining")
                        labelText:  object.timeRemainingStr.value
                        visible:    batteryValuesAvailable.timeRemainingAvailable
                    }

                    LabelledLabel {
                        label:      qsTr("Remaining")
                        labelText:  object.percentRemaining.valueString + " " + object.percentRemaining.units
                        visible:    batteryValuesAvailable.percentRemainingAvailable
                    }

                    LabelledLabel {
                        label:      qsTr("Voltage")
                        labelText:  object.voltage.valueString + " " + object.voltage.units
                    }

                    LabelledLabel {
                        label:      qsTr("Consumed")
                        labelText:  object.mahConsumed.valueString + " " + object.mahConsumed.units
                        visible:    batteryValuesAvailable.mahConsumedAvailable
                    }
                }
            }
        }
    }
}
