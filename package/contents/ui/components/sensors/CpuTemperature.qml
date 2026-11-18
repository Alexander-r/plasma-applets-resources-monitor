import QtQuick
import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.formatter as Formatter

// Maximum CPU temperature from ksystemstats.
Item {
    id: root

    property real value: 0

    function update() {
        const value = parseFloat(_sensor.value);
        if (!isNaN(value) && value !== 0) {
            root.value = value;
        }
    }

    function getFormattedValue() {
        if (Formatter.Formatter.formatValueWithPrecision) {
            return Formatter.Formatter.formatValueWithPrecision(value, Formatter.Units.UnitCelsius, 0);
        }
        return value + " °C";
    }

    readonly property var _sensor: Sensors.Sensor {
        enabled: root.enabled
        updateRateLimit: -1
        sensorId: "cpu/all/maximumTemperature"
    }
}
