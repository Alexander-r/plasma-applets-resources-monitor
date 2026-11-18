/*
 * Copyright 2015  Martin Kotelnik <clearmartin@seznam.cz>
 * Copyright 2020  Frieder Reinhold <reinhold@trigon-media.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.ksysguard.sensors as Sensors
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: main

    property bool vertical: (Plasmoid.formFactor == PlasmaCore.Types.Vertical)

    property bool verticalLayout: Plasmoid.configuration.verticalLayout
    property bool showCpuMonitor: Plasmoid.configuration.showCpuMonitor
    property bool showClock: Plasmoid.configuration.showClock
    property bool showRamMonitor: Plasmoid.configuration.showRamMonitor
    property bool showNetMonitor: Plasmoid.configuration.showNetMonitor
    property bool memoryInPercent: Plasmoid.configuration.memoryInPercent
    property bool enableHints: Plasmoid.configuration.enableHints
    property bool enableShadows: Plasmoid.configuration.enableShadows
    property double fontScale: (Plasmoid.configuration.fontScale / 100)
    property bool showMemoryInPercent: (!enableHints && ramMouseArea.containsMouse) ? !memoryInPercent : memoryInPercent
    property double downloadMaxMbps: Plasmoid.configuration.downloadMaxMbps
    property double uploadMaxMbps: Plasmoid.configuration.uploadMaxMbps
    property color networkUploadDiagramColor: Plasmoid.configuration.networkUploadDiagramColor
    property color networkDownloadDiagramColor: Plasmoid.configuration.networkDownloadDiagramColor
    property int updateIntervalMs: Math.max(100, 1000 * Plasmoid.configuration.updateInterval)

    property int containerCount: (showCpuMonitor?1:0) + (showRamMonitor?1:0) + (showNetMonitor?1:0)
    property int itemMargin: 5
    property double itemWidth:  vertical ? ( verticalLayout ? main.width : (main.width - itemMargin) / 2 ) : ( verticalLayout ? (main.height - itemMargin) / 2 : main.height )
    property double itemHeight: itemWidth
    property double fontPixelSize: itemHeight * fontScale
    property int graphGranularity: 20

    property bool cpuHint: enableHints && cpuMouseArea.containsMouse
    property bool ramHint: enableHints && ramMouseArea.containsMouse
    property bool netHint: enableHints && netMouseArea.containsMouse

    property color textColor: Kirigami.Theme.textColor
    property color highlightColor: Kirigami.Theme.highlightColor
    property color shadowColor: Kirigami.Theme.backgroundColor
    property color warningColor: Qt.tint(textColor, '#60FF0000')

    property double widgetWidth: !verticalLayout ? (itemWidth*containerCount + itemMargin) : itemWidth
    property double widgetHeight: verticalLayout ? (itemWidth*containerCount + itemMargin) : itemWidth

    // Only constrain the length along the panel. The thickness is given by the
    // panel and itemWidth is derived from it; constraining it too would feed the
    // widget's size back into itself.
    Layout.preferredWidth: vertical ? -1 : widgetWidth
    Layout.maximumWidth: vertical ? Infinity : widgetWidth
    Layout.preferredHeight: vertical ? widgetHeight : -1
    Layout.maximumHeight: vertical ? widgetHeight : Infinity

    preferredRepresentation: fullRepresentation

    onShowMemoryInPercentChanged: updateTexts()

    // Plasma 5 used ksysguard sensor ids like "network/interfaces/eth0/receiver/data".
    // Translate those (e.g. from an old config) to the ksystemstats ids used by Plasma 6.
    function networkSensorId(configured, isDownload) {
        var fallback = isDownload ? 'network/all/download' : 'network/all/upload'
        if (!configured) {
            return fallback
        }
        var legacy = /^network\/interfaces\/([^\/]+)\/(receiver|transmitter)\/data$/.exec(configured)
        if (legacy) {
            return 'network/' + legacy[1] + '/' + (legacy[2] === 'receiver' ? 'download' : 'upload')
        }
        return configured
    }

    Component.onCompleted: {
        // Migrate network sensor ids saved by the Plasma 5 version of this widget.
        var down = networkSensorId(Plasmoid.configuration.networkSensorDownload, true)
        if (down !== Plasmoid.configuration.networkSensorDownload) {
            Plasmoid.configuration.networkSensorDownload = down
        }
        var up = networkSensorId(Plasmoid.configuration.networkSensorUpload, false)
        if (up !== Plasmoid.configuration.networkSensorUpload) {
            Plasmoid.configuration.networkSensorUpload = up
        }
    }

    // Sensors from ksystemstats. Units: % for CPU usage, MHz for frequency,
    // bytes for memory and bytes per second for network.
    Sensors.Sensor {
        id: cpuUsageSensor
        sensorId: 'cpu/all/usage'
        updateRateLimit: updateIntervalMs
        enabled: showCpuMonitor
    }
    Sensors.Sensor {
        id: cpuClockSensor
        sensorId: 'cpu/all/averageFrequency'
        updateRateLimit: updateIntervalMs
        enabled: showCpuMonitor && showClock
    }
    Sensors.Sensor {
        // Memory used by applications, excluding buffers and all page/slab cache.
        id: ramApplicationSensor
        sensorId: 'memory/physical/application'
        updateRateLimit: updateIntervalMs
        enabled: showRamMonitor
    }
    Sensors.Sensor {
        id: ramBufferSensor
        sensorId: 'memory/physical/buffer'
        updateRateLimit: updateIntervalMs
        enabled: showRamMonitor
    }
    Sensors.Sensor {
        // Page cache plus reclaimable slab; drawn as a separate layer above application memory.
        id: ramCacheSensor
        sensorId: 'memory/physical/cache'
        updateRateLimit: updateIntervalMs
        enabled: showRamMonitor
    }
    Sensors.Sensor {
        id: ramTotalSensor
        sensorId: 'memory/physical/total'
        updateRateLimit: updateIntervalMs
        enabled: showRamMonitor
    }
    Sensors.Sensor {
        id: swapUsedSensor
        sensorId: 'memory/swap/used'
        updateRateLimit: updateIntervalMs
        enabled: showRamMonitor
    }
    Sensors.Sensor {
        id: swapTotalSensor
        sensorId: 'memory/swap/total'
        updateRateLimit: updateIntervalMs
        enabled: showRamMonitor
    }
    Sensors.Sensor {
        id: downloadSensor
        sensorId: Plasmoid.configuration.networkSensorDownload || 'network/all/download'
        updateRateLimit: updateIntervalMs
        enabled: showNetMonitor
    }
    Sensors.Sensor {
        id: uploadSensor
        sensorId: Plasmoid.configuration.networkSensorUpload || 'network/all/upload'
        updateRateLimit: updateIntervalMs
        enabled: showNetMonitor
    }

    function sensorValue(sensor) {
        var value = parseFloat(sensor.value)
        return isNaN(value) ? 0 : value
    }

    function proportion(used, total) {
        return total > 0 ? used / total : 0
    }

    property double cpuProportion: sensorValue(cpuUsageSensor) / 100
    property double cpuClockMhz: sensorValue(cpuClockSensor)
    property double ramTotalBytes: sensorValue(ramTotalSensor)
    property double ramUsedBytes: sensorValue(ramApplicationSensor)
    property double ramProportion: proportion(ramUsedBytes, ramTotalBytes)
    property double ramCacheBytes: sensorValue(ramBufferSensor) + sensorValue(ramCacheSensor)
    // Top of the cache layer: application memory plus buffers and cache.
    property double ramWithCacheProportion: proportion(ramUsedBytes + ramCacheBytes, ramTotalBytes)
    property double swapUsedBytes: sensorValue(swapUsedSensor)
    property double swapProportion: proportion(swapUsedBytes, sensorValue(swapTotalSensor))
    property double downloadMbps: sensorValue(downloadSensor) * 8 / 1000000
    property double uploadMbps: sensorValue(uploadSensor) * 8 / 1000000
    property double downloadProportion: downloadMaxMbps > 0 ? downloadMbps / downloadMaxMbps : 0
    property double uploadProportion: uploadMaxMbps > 0 ? uploadMbps / uploadMaxMbps : 0

    ListModel {
        id: cpuGraphModel
    }

    ListModel {
        id: ramGraphModel
    }

    ListModel {
        id: ramCacheGraphModel
    }

    ListModel {
        id: swapGraphModel
    }

    ListModel {
        id: uploadGraphModel
    }

    ListModel {
        id: downloadGraphModel
    }

    function getHumanReadableMemory(memBytes) {
        var megaBytes = memBytes / 1024 / 1024
        if (megaBytes <= 1024) {
            return Math.round(megaBytes) + 'M'
        }
        return Math.round(megaBytes / 1024 * 100) / 100 + 'G'
    }

    function getHumanReadableClock(clockMhz) {
        var clockNumber = Math.round(clockMhz)
        if (clockNumber < 1000) {
            return clockNumber + 'MHz'
        }
        clockNumber = clockNumber / 1000
        var floatingPointCount = 100
        if (clockNumber >= 10) {
            floatingPointCount = 10
        }
        return Math.round(clockNumber * floatingPointCount) / floatingPointCount + 'GHz'
    }

    function getHumanReadableNetRate(rateMbps) {
        if (rateMbps < 10) {
            return Math.round(rateMbps * 10) / 10 + 'Mb/s'
        }
        return Math.round(rateMbps) + 'Mb/s'
    }

    function updateTexts() {
        cpuPercentText.text = Math.round(cpuProportion * 100) + '%'
        cpuPercentText.color = cpuProportion > 0.9 ? warningColor : textColor
        averageClockText.text = getHumanReadableClock(cpuClockMhz)

        ramPercentText.text = showMemoryInPercent ? Math.round(ramProportion * 100) + '%' : getHumanReadableMemory(ramUsedBytes)
        ramPercentText.color = ramProportion > 0.9 ? warningColor : textColor
        swapPercentText.text = showMemoryInPercent ? Math.round(swapProportion * 100) + '%' : getHumanReadableMemory(swapUsedBytes)
        swapPercentText.color = swapProportion > 0.9 ? warningColor : textColor

        netUploadMbpsText.text = getHumanReadableNetRate(uploadMbps)
        netDownloadMbpsText.text = getHumanReadableNetRate(downloadMbps)
    }

    function addGraphData(model, graphItemPercent, graphGranularity) {
        // initial fill up
        while (model.count < graphGranularity) {
            model.append({
                'graphItemPercent': 0
            })
        }

        model.append({
            'graphItemPercent': graphItemPercent
        })
        model.remove(0)
    }

    // Sample all sensors once per update interval and advance the graphs.
    Timer {
        interval: updateIntervalMs
        running: true
        repeat: true
        onTriggered: {
            updateTexts()
            if (showCpuMonitor) {
                addGraphData(cpuGraphModel, cpuProportion, graphGranularity)
            }
            if (showRamMonitor) {
                addGraphData(ramCacheGraphModel, ramWithCacheProportion, graphGranularity)
                addGraphData(ramGraphModel, ramProportion, graphGranularity)
                addGraphData(swapGraphModel, swapProportion, graphGranularity)
            }
            if (showNetMonitor) {
                addGraphData(downloadGraphModel, downloadProportion, graphGranularity)
                addGraphData(uploadGraphModel, uploadProportion, graphGranularity)
            }
        }
    }

    Plasma5Support.DataSource {
        id: executable
        engine: 'executable'
        connectedSources: []
        onNewData: (sourceName, data) => disconnectSource(sourceName)

        function exec(command) {
            connectSource(command)
        }
    }

    Item {
        id: cpuMonitor
        width: itemWidth
        height: itemHeight

        visible: showCpuMonitor

        HistoryGraph {
            listViewModel: cpuGraphModel
            barColor: highlightColor
            granularity: graphGranularity
        }

        Item {
            id: cpuTextContainer
            anchors.fill: parent

            PlasmaComponents.Label {
                id: cpuInfoText
                anchors.right: parent.right
                verticalAlignment: Text.AlignTop
                text: 'CPU'
                color: highlightColor
                font.pixelSize: fontPixelSize
                visible: cpuHint
            }

            PlasmaComponents.Label {
                id: cpuPercentText
                anchors.right: parent.right
                verticalAlignment: Text.AlignTop
                text: '...'
                font.pixelSize: fontPixelSize
                visible: !cpuHint
            }

            PlasmaComponents.Label {
                id: averageClockText
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                font.pixelSize: fontPixelSize
                visible: showClock && !cpuHint
            }

            PlasmaComponents.Label {
                id: averageClockInfoText
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                font.pixelSize: fontPixelSize
                text: 'Clock'
                visible: showClock && cpuHint
            }
        }

        DropShadow {
            visible: enableShadows
            anchors.fill: cpuTextContainer
            radius: 3
            samples: 8
            spread: 0.8
            color: shadowColor
            source: cpuTextContainer
        }

        MouseArea {
            id: cpuMouseArea
            anchors.fill: parent
            hoverEnabled: true
        }
    }

    Item {
        id: ramMonitor
        width: itemWidth
        height: itemHeight
        anchors.left: parent.left
        anchors.leftMargin: showCpuMonitor && !verticalLayout ? itemWidth + itemMargin : 0
        anchors.top: parent.top
        anchors.topMargin: showCpuMonitor && verticalLayout ? itemWidth + itemMargin : 0

        visible: showRamMonitor

        // Drawn first so application memory covers its lower part,
        // leaving only the reclaimable cache visible above it.
        HistoryGraph {
            listViewModel: ramCacheGraphModel
            barColor: Qt.rgba(highlightColor.r, highlightColor.g, highlightColor.b, 0.35)
            granularity: graphGranularity
        }

        HistoryGraph {
            listViewModel: ramGraphModel
            barColor: highlightColor
            granularity: graphGranularity
        }

        HistoryGraph {
            listViewModel: swapGraphModel
            barColor: '#FF0000'
            granularity: graphGranularity
        }

        Item {
            id: ramTextContainer
            anchors.fill: parent

            PlasmaComponents.Label {
                id: ramInfoText
                text: 'RAM'
                color: highlightColor
                font.pixelSize: fontPixelSize
                anchors.right: parent.right
                verticalAlignment: Text.AlignTop
                visible: ramHint
            }

            PlasmaComponents.Label {
                id: ramPercentText
                anchors.right: parent.right
                verticalAlignment: Text.AlignTop
                text: '...'
                font.pixelSize: fontPixelSize
                visible: !ramHint
            }

            PlasmaComponents.Label {
                id: swapPercentText
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                font.pixelSize: fontPixelSize
                visible: !ramHint && swapProportion > 0
            }

            PlasmaComponents.Label {
                id: swapInfoText
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                color: '#FF0000'
                font.pixelSize: fontPixelSize
                text: 'Swap'
                visible: ramHint
            }
        }

        DropShadow {
            visible: enableShadows
            anchors.fill: ramTextContainer
            radius: 3
            samples: 8
            spread: 0.8
            color: shadowColor
            source: ramTextContainer
        }

        MouseArea {
            id: ramMouseArea
            anchors.fill: parent
            hoverEnabled: true
        }
    }

    Item {
        id: netMonitor
        width: itemWidth
        height: itemHeight
        anchors.left: parent.left
        anchors.leftMargin: (showCpuMonitor && !verticalLayout ? itemWidth + itemMargin: 0) + (showRamMonitor && !verticalLayout ? itemWidth + itemMargin : 0)
        anchors.top: parent.top
        anchors.topMargin: (showCpuMonitor && verticalLayout ? itemWidth + itemMargin: 0) + (showRamMonitor && verticalLayout ? itemWidth + itemMargin : 0)

        visible: showNetMonitor

        HistoryGraph {
            listViewModel: downloadGraphModel
            barColor: networkDownloadDiagramColor
            granularity: graphGranularity
        }

        HistoryGraph {
            listViewModel: uploadGraphModel
            barColor: networkUploadDiagramColor
            granularity: graphGranularity
        }

        Item {
            id: netMonitorTextContainer
            anchors.fill: parent

            PlasmaComponents.Label {
                id: netUploadInfoText
                text: 'Up'
                color: '#FF0000'
                font.pixelSize: fontPixelSize
                anchors.right: parent.right
                verticalAlignment: Text.AlignTop
                visible: netHint
            }

            PlasmaComponents.Label {
                id: netUploadMbpsText
                anchors.right: parent.right
                verticalAlignment: Text.AlignTop
                text: '...'
                font.pixelSize: fontPixelSize
                visible: !netHint
            }

            PlasmaComponents.Label {
                id: netDownloadMbpsText
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                font.pixelSize: fontPixelSize
                visible: !netHint
            }

            PlasmaComponents.Label {
                id: netDownloadInfoText
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                color: '#00FF00'
                font.pixelSize: fontPixelSize
                text: 'Down'
                visible: netHint
            }
        }

        DropShadow {
            visible: enableShadows
            anchors.fill: netMonitorTextContainer
            radius: 3
            samples: 8
            spread: 0.8
            color: shadowColor
            source: netMonitorTextContainer
        }

        MouseArea {
            id: netMouseArea
            anchors.fill: parent
            hoverEnabled: true
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: executable.exec('kstart --application org.kde.plasma-systemmonitor')
    }
}
