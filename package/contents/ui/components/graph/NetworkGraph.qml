import QtQuick
import "./base" as RMBaseGraph
import "../sensors" as RMSensors
import "../../code/formatter.js" as RMFormatter

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "NetworkGraph"
    sensorsModel.enabled: false // Disable base sensor due to use custom one
    _update: networkSpeed.execute

    // Settings
    property var ignoredInterfaces: []
    property bool icons: false
    readonly property var unit: RMFormatter.getUnitInfo(sensorsType[1], i18nc)

    // Retrieve chart index and swap it if needed
    readonly property int downloadIndex: sensorsType[0] ? 1 : 0
    readonly property int uploadIndex: sensorsType[0] ? 0 : 1

    sensorsFormat: [unit.id]

    // Labels config
    textContainer {
        hints: {
            const receiving = i18nc("Graph label", "Receiving");
            const sending = i18nc("Graph label", "Sending");
            return sensorsType[0] ? [sending, receiving, ""] : [receiving, sending, ""];
        }
    }

    // Charts config
    realUplimits: [uplimits[0] * unit.multiplier, uplimits[1] * unit.multiplier]

    // Custom sensor
    RMSensors.NetworkSpeed {
        id: networkSpeed
        ignoredInterfaces: root.ignoredInterfaces

        onUpdated: {
            // Apply selected unit
            const downloadValue = download * unit.byteDiff;
            const uploadValue = upload * unit.byteDiff;

            _insertChartData(downloadIndex, downloadValue);
            _insertChartData(uploadIndex, uploadValue);

            // Update labels
            if (textContainer.enabled) {
                _updateData(downloadIndex, downloadValue);
                _updateData(uploadIndex, uploadValue);
            }
        }
    }

    function _updateData(index, value) {
        let icon = ""
        if (root.icons) {
            if (index == downloadIndex) {
                icon = "\u2009↓"
            } else if (index == uploadIndex) {
                icon = "\u2009↑"
            }
        }

        textContainer.setValue(index, value, RMFormatter.formatValue(value, unit, Qt.locale()) + icon)
    }
}
