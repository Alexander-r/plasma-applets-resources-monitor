import QtQuick
import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.formatter as Formatter

/**
 * Battery information from the ksystemstats "power/<device>/..." sensors.
 * No external process is started.
 */
Item {
    id: root

    required property string device
    required property string metric // Available: percentage, energy-rate, time

    readonly property int unit: metric === "percentage" ? Formatter.Units.UnitPercent : (metric === "energy-rate" ? Formatter.Units.UnitWatt : -1)
    readonly property bool isPresent: percentageSensor.status === Sensors.Sensor.Ready

    // Watt, positive while charging and negative while discharging
    readonly property real rate: parseFloat(rateSensor.value)
    readonly property bool isPlugged: rate >= 0

    readonly property real value: {
        switch (metric) {
        case "percentage":
            return parseFloat(percentageSensor.value);
        case "energy-rate":
            return Math.abs(rate);
        case "time":
            // Charge and capacity are in Wh, so Wh / W gives hours
            if (rate < 0) {
                return parseFloat(chargeSensor.value) / -rate * 3600;
            } else if (rate > 0) {
                return (parseFloat(capacitySensor.value) - parseFloat(chargeSensor.value)) / rate * 3600;
            }
            return NaN;
        }
        return NaN;
    }

    Sensors.Sensor {
        id: percentageSensor
        sensorId: `power/${root.device}/chargePercentage`
    }
    Sensors.Sensor {
        id: rateSensor
        sensorId: `power/${root.device}/chargeRate`
    }
    Sensors.Sensor {
        id: chargeSensor
        sensorId: `power/${root.device}/charge`
        enabled: root.metric === "time"
    }
    Sensors.Sensor {
        id: capacitySensor
        sensorId: `power/${root.device}/capacity`
        enabled: root.metric === "time"
    }
}
