import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "../../code/formatter.js" as Formatter
import "../../components/sensors" as RMSensors

/**
 * Settings format: {@link ../../code/graphs.js:79}
 */
BaseForm {
    id: root
    colorsType: ["text", "text", false]

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
}
