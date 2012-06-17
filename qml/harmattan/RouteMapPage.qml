/*
 * This file is part of the Meegopas, more information at www.gitorious.org/meegopas
 *
 * Author: Jukka Nousiainen <nousiaisenjukka@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * See full license at http://www.gnu.org/licenses/gpl-3.0.html
 */

import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.location 1.2
import "reittiopas.js" as Reittiopas
import "UIConstants.js" as UIConstants

Page {
    id: page
    tools: mapTools
    anchors.fill: parent

    onStatusChanged: {
        if(status == Component.Ready)
            timer.start()
    }

    Timer {
        id: timer
        interval: 500
        triggeredOnStart: false
        repeat: false
        onTriggered: map_loader.sourceComponent = map_component
    }

    ToolBarLayout {
        id: mapTools
        ToolIcon { iconId: "toolbar-back"
            onClicked: {
                pageStack.pop();
            }
        }
        ToolButtonRow {
            ToolIcon { iconId: "toolbar-mediacontrol-previous"; enabled: !appWindow.follow_mode; onClicked: { map_loader.item.previous_station(); } }
            ToolIcon { iconId: "toolbar-mediacontrol-next"; enabled: !appWindow.follow_mode; onClicked: { map_loader.item.next_station(); } }
        }
        ToolIcon { platformIconId: "toolbar-view-menu";
             anchors.right: parent===undefined ? undefined : parent.right
             onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
    }
    Loader {
        id: map_loader
        anchors.fill: parent
        onLoaded: {
            map_loader.item.initialize()
            map_loader.item.first_station()
        }
    }

    Component {
        id: map_component
        MapElement {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.fill: parent
        }
    }
    ListModel {
        id: mapTypeModel
        ListElement { name: QT_TR_NOOP("Street"); value: Map.MobileTransitMap }
        ListElement { name: QT_TR_NOOP("Satellite"); value: Map.SatelliteMapDay }
        ListElement { name: QT_TR_NOOP("Hybrid"); value: Map.MobileHybridMap }
        ListElement { name: QT_TR_NOOP("Terrain"); value: Map.MobileTerrainMap }
    }

    SelectionDialog {
        id: mapTypeSelection
        model: mapTypeModel
        delegate: SelectionDialogDelegate {}
        selectedIndex: 0
        titleText: qsTr("Map type")
        onAccepted: {
            map_loader.item.flickable_map.map.mapType = mapTypeModel.get(selectedIndex).value
        }
    }

    Column {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: followMode.width + UIConstants.DEFAULT_MARGIN * 2
        spacing: UIConstants.DEFAULT_MARGIN
        z: 500
        MapButton {
            id: followMode
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/images/current.png"
            z: 500
            selected: appWindow.follow_mode
            mouseArea.onClicked: {
                appWindow.follow_mode = appWindow.follow_mode? false : true
            }
        }
        MapButton {
            id: mapMode
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/images/maptype.png"
            z: 500
            mouseArea.onClicked: {
                mapTypeSelection.open()
            }
        }
    }
    BusyIndicator {
        id: busyIndicator
        visible: !map_loader.sourceComponent || map_loader.status == Loader.Loading
        running: true
        platformStyle: BusyIndicatorStyle { size: 'large' }
        anchors.centerIn: parent
    }
}

