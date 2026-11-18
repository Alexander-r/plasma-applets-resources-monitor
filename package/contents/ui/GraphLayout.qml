import QtQuick
import QtQuick.Layouts

Flow {
    id: root

    property alias model: repeater.model
    property alias updateInterval: updater.interval

    property bool isVertical: false
    property double widthRatio: 1.4

    property int parentWidth: 0
    property int parentHeight: 0

    // Share the given length along the flow between the graphs without an explicit size.
    // Only valid when that length doesn't come from our own size (across a panel, on the
    // desktop); along a panel the graphs are sized from the panel thickness instead.
    property bool fillLength: false
    readonly property real autoLength: {
        if (!fillLength)
            return 0;

        const axis = isVertical ? 1 : 0;
        let fixedLength = 0;
        let autoCount = 0;
        let visibleCount = 0;
        for (let i = 0; i < repeater.count; i++) {
            const loaderItem = repeater.itemAt(i);
            if (!loaderItem?.item?.visible)
                continue;

            visibleCount++;
            if (loaderItem.modelData.sizes[axis] !== -1) {
                fixedLength += loaderItem.modelData.sizes[axis];
            } else {
                autoCount++;
            }
        }
        if (autoCount === 0)
            return 0;

        const available = isVertical ? parentHeight : parentWidth;
        return Math.max(0, (available - fixedLength - spacing * Math.max(visibleCount - 1, 0)) / autoCount);
    }

    flow: isVertical ? GridLayout.TopToBottom : GridLayout.LeftToRight

    Repeater {
        id: repeater

        delegate: Loader {
            required property var modelData

            width: {
                if (!item?.visible)
                    return 0;
                if (modelData.sizes[0] !== -1)
                    return modelData.sizes[0];
                if (root.isVertical)
                    return root.parentWidth;
                if (root.fillLength)
                    return Math.max(item?.minimumWidth ?? 0, root.autoLength);
                if (modelData.type.endsWith("Text"))
                    return Math.max(item?.minimumWidth ?? 0, root.parentHeight);

                return Math.max(item?.minimumWidth ?? 0, Math.round(root.parentHeight * root.widthRatio));
            }
            height: {
                if (!item?.visible)
                    return 0;
                if (modelData.sizes[1] !== -1)
                    return modelData.sizes[1];
                if (!root.isVertical)
                    return root.parentHeight;
                if (root.fillLength)
                    return root.autoLength;

                return root.parentWidth;
            }

            Component.onCompleted: {
                const typeCapitalized = modelData.type.charAt(0).toUpperCase() + modelData.type.slice(1);
                // Retrieve props without un wanted internals
                let props = {};
                for (const [key, value] of Object.entries(modelData)) {
                    if (["_v", "type", "sizes"].includes(key)) {
                        continue;
                    }
                    props[key] = value;
                }

                // Load graph
                if (typeCapitalized.endsWith("Text")) {
                    setSource(Qt.resolvedUrl(`./components/text/${typeCapitalized}.qml`), props);
                } else {
                    setSource(Qt.resolvedUrl(`./components/graph/${typeCapitalized}Graph.qml`), props);
                }
            }
        }
    }

    function getGraph(index) {
        return root.children[index]?.item;
    }

    // Global update timer
    Timer {
        id: updater

        running: true
        repeat: true

        onTriggered: {
            for (let i = 0; i < root.model.length + 1; i++) {
                const graph = root.getGraph(i);
                if (typeof graph !== "undefined" && graph.objectName !== "Text") {
                    graph._update();
                }
            }
        }
    }
}
