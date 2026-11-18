import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "../controls" as RMControls
import "../../code/formatter.js" as Formatter
import "../../components/sensors" as RMSensors

/**
 * Settings format: {@link ../../code/graphs.js:35}
 */
BaseForm {
    id: root
    colorsType: ["series", "series", false]

    readonly property var unit: Formatter.getUnitInfo(item.sensorsType[1], i18nc)
    readonly property var speedOptions: [
        {
            "label": i18n("Custom"),
            "value": -1
        },
        {
            "label": i18n("Automatic"),
            "value": 0.0
        },
        // Kilo options (pow 1)
        _getOption(100, 1),
        // Mega options (pow 2)
        _getOption(1, 2), _getOption(10, 2), _getOption(100, 2),
        // Giga options (pow 3)
        _getOption(1, 3), _getOption(2.5, 3), _getOption(5, 3), _getOption(10, 3)]

    // List network interfaces known to ksystemstats
    RMSensors.NetworkInterfaces {
        id: interfaces
    }

    properties: Kirigami.FormLayout {
        QQC2.CheckBox {
            text: i18n("Swap first and second line")
            checked: root.item.sensorsType[0]
            onClicked: {
                root.item.sensorsType[0] = checked;
                root.changed();
            }
        }

        QQC2.ComboBox {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Unit:")

            textRole: "label"
            valueRole: "value"
            model: [
                {
                    "label": i18n("kibibyte (KiB/s)"),
                    "value": "kibibyte"
                },
                {
                    "label": i18n("kilobit (Kbps)"),
                    "value": "kilobit"
                },
                {
                    "label": i18n("kilobyte (KBps)"),
                    "value": "kilobyte"
                }
            ]

            Component.onCompleted: currentIndex = indexOfValue(root.item.sensorsType[1])
            onActivated: {
                root.item.sensorsType[1] = currentValue;
                root.changed();
            }
        }

        // Interfaces
        GridLayout {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Network interfaces:")

            columns: 2
            rowSpacing: Kirigami.Units.smallSpacing
            columnSpacing: Kirigami.Units.largeSpacing

            Repeater {
                model: interfaces.names
                delegate: QQC2.CheckBox {
                    required property string modelData
                    readonly property string name: modelData

                    text: name
                    checked: root.item.ignoredInterfaces.indexOf(name) == -1

                    onClicked: {
                        if (checked) {
                            // Checking, and thus removing from the ignoredNetworkInterfaces
                            var i = root.item.ignoredInterfaces.indexOf(name);
                            root.item.ignoredInterfaces.splice(i, 1);
                        } else {
                            // Unchecking, and thus adding to the ignoredNetworkInterfaces
                            root.item.ignoredInterfaces.push(name);
                        }
                        root.changed();
                    }
                }
            }
        }

        // Transfer speed
        Kirigami.Separator {
            Kirigami.FormData.label: i18n("Maximum transfer speed")
            Kirigami.FormData.isSection: true
        }
        RMControls.PredefinedSpinBox {
            id: receivingSpeed
            Layout.fillWidth: true
            Kirigami.FormData.label: i18nc("Chart config", "Receiving:")
            factor: 1000

            realValue: root.item.uplimits[0]
            onRealValueChanged: {
                root.item.uplimits[0] = receivingSpeed.realValue;
                root.changed();
            }

            predefinedChoices {
                textRole: "label"
                valueRole: "value"
                model: root.speedOptions
            }

            spinBox {
                decimals: 3
                stepSize: 1
                realFrom: 0.001
                suffix: " M" + root.unit.symbol
            }
        }
        RMControls.PredefinedSpinBox {
            id: sendingSpeed
            Layout.fillWidth: true
            Kirigami.FormData.label: i18nc("Chart config", "Sending:")
            factor: 1000

            realValue: root.item.uplimits[1]
            onRealValueChanged: {
                root.item.uplimits[1] = sendingSpeed.realValue;
                root.changed();
            }

            predefinedChoices {
                textRole: "label"
                valueRole: "value"
                model: root.speedOptions
            }

            spinBox {
                decimals: 3
                stepSize: 1
                realFrom: 0.001
                suffix: " M" + root.unit.symbol
            }
        }
    }

    appearanceProperties: Kirigami.FormLayout {
        QQC2.CheckBox {
            text: i18n("Show icons (%1 / %2)", "↓", "↑")
            checked: root.item.icons
            onClicked: {
                root.item.icons = checked;
                root.changed();
            }
        }
    }

    // Utils function
    function _getOption(value, pow = 0) {
        return {
            label: Formatter.formatValue(value * Math.pow(unit.multiplier, Math.max(0, pow)), unit, Qt.locale()),
            value: value * Math.pow(1000, Math.max(0, pow - 1))
        };
    }
}
