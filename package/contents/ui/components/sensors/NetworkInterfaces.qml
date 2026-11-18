import QtQuick
import org.kde.ksysguard.sensors as Sensors

/**
 * Lists the network interfaces known to ksystemstats (e.g. ["eth0", "wlan0"]),
 * taken from the "network/<interface>/download" sensor ids. "all" is excluded.
 */
Sensors.SensorTreeModel {
    id: root

    property var names: []

    onRowsInserted: Qt.callLater(rescan)
    onModelReset: Qt.callLater(rescan)
    Component.onCompleted: rescan()

    function rescan() {
        const found = [];
        const visit = parent => {
            const count = parent ? rowCount(parent) : rowCount();
            for (let i = 0; i < count; i++) {
                const modelIndex = parent ? index(i, 0, parent) : index(i, 0);
                // Plain interface names only: the tree also holds wildcard ids like "network/(?!all).*/download"
                const match = /^network\/([\w.:-]+)\/download$/.exec(data(modelIndex, Sensors.SensorTreeModel.SensorId) ?? "");
                if (match && match[1] !== "all" && !found.includes(match[1])) {
                    found.push(match[1]);
                }
                visit(modelIndex);
            }
        };
        visit(null);
        found.sort();
        if (JSON.stringify(found) !== JSON.stringify(names)) {
            names = found;
        }
    }
}
