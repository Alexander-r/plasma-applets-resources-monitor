import QtQuick
import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.formatter as Formatter
import org.kde.plasma.plasmoid
import org.kde.quickcharts as Charts
import "./base" as RMBaseGraph
import "../../code/formatter.js" as RMFormatter

RMBaseGraph.TwoSensorsGraph {
    id: root
    objectName: "MemoryGraph"

    // Config shortcut
    property bool firstIsSwap: sensorsType[0].startsWith("swap")
    property bool secondIsSwap: sensorsType[1].startsWith("swap")
    property var fieldInPercent: [sensorsType[0].endsWith("-percent"), sensorsType[1].endsWith("-percent")]
    // Cache band: only stacked on application memory, which excludes all cache
    property bool showCache: sensorsType[2] === true && sensorsType[0].startsWith("application")

    sensorsFormat: [(fieldInPercent[0] ? Formatter.Units.UnitPercent : Formatter.Units.UnitByte), (sensorsType[1] == "none" ? null : (fieldInPercent[1] ? Formatter.Units.UnitPercent : Formatter.Units.UnitByte))]

    // Labels
    textContainer {
        valueColors: [root.firstIsSwap ? root.colors[0] : undefined, root.secondIsSwap ? root.colors[1] : undefined, undefined]
        labelsVisibleWhenZero: [!firstIsSwap, !secondIsSwap, true]
        thresholdIndex: firstIsSwap ? (secondIsSwap ? -1 : 1) : 0
        thresholds: {
            const index = firstIsSwap ? 1 : 0;
            return [root.realUplimits[index] * (root.thresholds[0] / 100.0), root.realUplimits[index] * (root.thresholds[1] / 100.0)];
        }

        hints: [(firstIsSwap ? "Swap" : "RAM"), (sensorsType[1] != "none" ? (secondIsSwap ? "Swap" : "RAM") : ""), (root.showCache ? i18nc("Graph label", "Cache") : "")]
    }

    // Graph options
    sensorSlots: [_toSensor(sensorsType[0]), _toSensor(sensorsType[1])]
    secondChartVisible: secondIsSwap || !fieldInPercent[1]

    // Override methods, for handle memory in percent
    _formatValue: (index, value) => {
        if (fieldInPercent[index]) {
            if (sensorSlots[index].endsWith("Percent")) {
                return i18nc("Percent unit", "%1%", Math.round(value * 10) / 10); // This is for round to 1 decimal
            } else {
                return i18nc("Percent unit", "%1%", Math.round((value / root.realUplimits[index]) * 1000) / 10); // This is for round to 1 decimal
            }
        }
        return _defaultFormatValue(index, value);
    }

    // Reclaimable cache (page/slab cache plus buffers), drawn behind the first chart
    // from the first value up to first value + cache.
    Sensors.SensorDataModel {
        id: cacheModel
        enabled: root.showCache
        updateRateLimit: -1
        sensors: ["memory/physical/cache", "memory/physical/buffer"]

        function total() {
            let sum = 0;
            for (let column = 0; column < columnCount(); column++) {
                sum += parseFloat(data(index(0, column), Sensors.SensorDataModel.Value)) || 0;
            }
            return sum;
        }
    }
    Charts.LineChart {
        anchors.fill: parent
        z: -1
        visible: root.showCache && root.enableHistory

        direction: Charts.XYChart.ZeroAtEnd
        fillOpacity: Plasmoid.configuration.graphFillOpacity / 100
        smooth: true
        yRange.to: root.realUplimits[0]
        yRange.automatic: root.realUplimits[0] == 0

        colorSource: Charts.SingleValueSource {
            value: root._resolveColor(root.colors[2])
        }
        valueSources: [
            RMBaseGraph.ArrayDataSource {
                id: cacheChartData
                maximumHistory: Plasmoid.configuration.historyAmount
            }
        ]
    }
    _update: () => {
        _defaultUpdate();
        if (!showCache) {
            return;
        }
        const cache = cacheModel.total();
        const first = parseFloat(sensorsModel.getData(sensorsModel.sensorIndexMap[0])) || 0;
        if (enableHistory) {
            cacheChartData.insertValue(first + cache);
        }
        if (textContainer.enabled) {
            textContainer.setValue(2, cache, _formatCache(cache));
        }
    }
    function _formatCache(value) {
        if (fieldInPercent[0]) {
            return i18nc("Percent unit", "%1%", Math.round((value / realUplimits[0]) * 1000) / 10);
        }
        if (Plasmoid.configuration.abbreviate) {
            return RMFormatter.formatInAbbreviate(value, Formatter.Units.UnitByte, Qt.locale());
        }
        return Formatter.Formatter.formatValueShowNull(value, Formatter.Units.UnitByte);
    }

    // Initialize limits and threshold
    Sensors.SensorDataModel {
        id: maxQueryModel
        sensors: {
            const values = [firstIsSwap ? "memory/swap/total" : "memory/physical/total"];
            const secondValue = secondIsSwap ? "memory/swap/total" : "memory/physical/total";
            if (!values.includes(secondValue)) {
                values.push(secondValue);
            }
            return values;
        }
        enabled: true
        property var maxMemory: [-1, -1]

        onDataChanged: topLeft => {
            // Update values
            const value = parseInt(data(topLeft, Sensors.SensorDataModel.Value));
            if (isNaN(value) || (topLeft.column === 0 && value <= 0)) {
                return;
            }
            maxMemory[topLeft.column] = value;

            // Update graph Y range and sensors
            if (sensors.length == 1) {
                enabled = false;
                maxMemory = [maxMemory[0], maxMemory[0]];
                root.realUplimits = maxMemory;
            } else if (maxMemory[0] > 0 && maxMemory[1] >= 0) {
                enabled = false;
                root.realUplimits = maxMemory;
            }
        }
    }

    function _toSensor(value) {
        const [type, percent] = value.split("-");
        switch (type) {
        case "physical":
            return "memory/physical/used";
        case "application":
            return "memory/physical/application";
        case "swap":
            return "memory/swap/used";
        default:
            return null;
        }
    }
}
