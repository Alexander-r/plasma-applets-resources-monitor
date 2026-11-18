import QtQuick
import org.kde.ksysguard.sensors as Sensors

/**
 * Network speed from ksystemstats, in bytes per second, summed over all
 * interfaces except the ignored ones. No external process is started.
 */
Item {
    id: root

    property var ignoredInterfaces: []

    // Results of the last execute()
    property real download: 0
    property real upload: 0
    signal updated

    // Interface names are only needed when some of them are ignored
    Loader {
        id: interfaces
        active: root.ignoredInterfaces.length > 0
        sourceComponent: NetworkInterfaces {}
    }

    Sensors.SensorDataModel {
        id: sensorsModel
        updateRateLimit: -1
        sensors: {
            // Array.from: QML hands lists over as list wrappers without the full Array API
            const ignored = Array.from(root.ignoredInterfaces);
            const names = ignored.length === 0 ? ["all"] : Array.from(interfaces.item?.names ?? []).filter(name => !ignored.includes(name));
            const ids = [];
            for (const name of names) {
                ids.push(`network/${name}/download`, `network/${name}/upload`);
            }
            return ids;
        }
    }

    function execute() {
        let download = 0, upload = 0;
        for (let column = 0; column < sensorsModel.columnCount(); column++) {
            const modelIndex = sensorsModel.index(0, column);
            const sensorId = sensorsModel.data(modelIndex, Sensors.SensorDataModel.SensorId) ?? "";
            const value = parseFloat(sensorsModel.data(modelIndex, Sensors.SensorDataModel.Value));
            if (isNaN(value)) {
                continue;
            }
            if (sensorId.endsWith("/download")) {
                download += value;
            } else {
                upload += value;
            }
        }
        root.download = download;
        root.upload = upload;
        updated();
    }
}
