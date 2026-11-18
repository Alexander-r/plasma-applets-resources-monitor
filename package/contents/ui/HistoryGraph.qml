/*
 * Copyright 2015  Martin Kotelnik <clearmartin@seznam.cz>
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

Item {
    id: historyGraph

    anchors.fill: parent

    property var listViewModel
    property color barColor
    required property int granularity

    ListView {
        anchors.fill: parent

        interactive: false
        orientation: Qt.Horizontal
        layoutDirection: Qt.LeftToRight
        spacing: 0

        model: historyGraph.listViewModel

        // ListView positions delegates itself, so a bar can't set its own y.
        // Use a full-height slot and anchor the bar to its bottom instead.
        delegate: Item {
            required property real graphItemPercent

            width: historyGraph.width / historyGraph.granularity
            height: historyGraph.height

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: parent.height * Math.max(0, Math.min(1, parent.graphItemPercent))
                color: historyGraph.barColor
                radius: 3
            }
        }
    }
}
