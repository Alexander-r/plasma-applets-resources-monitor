import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support
import "./code/graphs.js" as GraphFns

PlasmoidItem {
    id: root

    property bool isVertical: {
        switch (Plasmoid.formFactor) {
        case PlasmaCore.Types.Planar:
        case PlasmaCore.Types.MediaCenter:
        case PlasmaCore.Types.Application:
        default:
            if (root.height > root.width) {
                return true;
            } else {
                return false;
            }
        case PlasmaCore.Types.Vertical:
            return true;
        case PlasmaCore.Types.Horizontal:
            return false;
        }
    }

    // Graphs direction: follows the panel unless forced in the settings
    property bool graphsIsVertical: {
        switch (Plasmoid.configuration.graphsDirection) {
        case "horizontal":
            return false;
        case "vertical":
            return true;
        default:
            return root.isVertical;
        }
    }
    // Graphs laid out along a panel: the widget length comes from the graphs
    readonly property bool alongPanel: (Plasmoid.formFactor === PlasmaCore.Types.Horizontal && !graphsIsVertical) || (Plasmoid.formFactor === PlasmaCore.Types.Vertical && graphsIsVertical)

    // Settings properties
    property var graphsModel: GraphFns.parse(Plasmoid.configuration.graphs)
    property string clickApplication: Plasmoid.configuration.clickApplication

    // Plasma configuration
    Plasmoid.backgroundHints: PlasmaCore.Types.DefaultBackground
    Plasmoid.configurationRequired: !graphsModel || graphsModel.length === 0 // Check if graphs is valid and have some items
    preferredRepresentation: Plasmoid.configurationRequired ? compactRepresentation : fullRepresentation // Show graphs only if at least 1 is present, otherwise ask to configure
    Plasmoid.constraintHints: Plasmoid.configuration.fillPanel ? Plasmoid.CanFillArea : Plasmoid.NoHint// Allow widget to take all height/width

    // Margin for prevent "invsible" 0 and full lines when fill panel
    anchors.topMargin: Plasmoid.configuration.fillPanel ? 1 : 0
    anchors.bottomMargin: anchors.topMargin

    // Content
    compactRepresentation: Kirigami.Icon {
        Layout.preferredWidth: width
        Layout.preferredHeight: height

        source: Plasmoid.icon
        width: Kirigami.Units.iconSizes.smallMedium
        height: width
    }
    fullRepresentation: MouseArea {
        acceptedButtons: clickApplication !== "" ? Qt.LeftButton : Qt.NoButton

        // Propagate child size to parent. Along a panel the length comes from the graphs;
        // otherwise the graphs fill the given space, so the length must not depend on them
        // (that would grow forever): across a panel the widget is square.
        Layout.preferredWidth: {
            if (alongPanel && !graphsIsVertical)
                return graphView.implicitWidth + Kirigami.Units.smallSpacing;
            return isVertical ? Kirigami.Units.iconSizes.small : height;
        }
        Layout.preferredHeight: {
            if (alongPanel && graphsIsVertical)
                return graphView.implicitHeight + Kirigami.Units.smallSpacing;
            return isVertical ? width : Kirigami.Units.iconSizes.small;
        }
        // The panel shrinks applets toward their minimum when it runs out of space,
        // and falls back to the panel thickness when none is set. The graphs can't
        // shrink, so require the full length along the panel.
        Layout.minimumWidth: isVertical ? -1 : Layout.preferredWidth
        Layout.minimumHeight: isVertical ? Layout.preferredHeight : -1
        // Never draw over neighbouring widgets
        clip: true

        // Click action: start the selected application through kstart
        Plasma5Support.DataSource {
            id: launcher
            engine: "executable"
            onNewData: (sourceName, data) => disconnectSource(sourceName)
        }
        onClicked: {
            // "file:///usr/share/applications/org.kde.foo.desktop" -> "org.kde.foo"
            const desktopId = clickApplication.split("/").pop().replace(/\.desktop$/, "");
            if (/^[\w.+-]+$/.test(desktopId)) {
                launcher.connectSource(`kstart --application ${desktopId}`);
            }
        }

        // Render
        GraphLayout {
            id: graphView
            model: graphsModel
            updateInterval: Plasmoid.configuration.updateInterval * 1000

            spacing: Plasmoid.configuration.graphSpacing
            isVertical: root.graphsIsVertical
            fillLength: !root.alongPanel

            parentWidth: parent.width
            parentHeight: parent.height
        }
    }
}
