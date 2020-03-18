/*
 * Copyright 2015-2016 Canonical Ltd.
 *
 * This file is part of webbrowser-app.
 *
 * webbrowser-app is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * webbrowser-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItems
import webbrowserapp.private 0.1
import "Highlight.js" as Highlight
import "." as Local

FocusScope {
    id: historyViewWide

    property bool searchMode: false
    readonly property bool selectMode: urlsListView.ViewItems.selectMode
    onSearchModeChanged: {
        if (searchMode) searchQuery.focus = true
        else {
            searchQuery.text = ""
            urlsListView.focus = true
        }
    }

    signal done()
    signal historyEntryClicked(url url)
    signal newTabRequested()

    Keys.onLeftPressed: lastVisitDateListView.forceActiveFocus()
    Keys.onRightPressed: urlsListView.forceActiveFocus()
    Keys.onUpPressed: if (searchMode) searchQuery.focus = true
    Keys.onPressed: {
        if (event.modifiers === Qt.ControlModifier && event.key === Qt.Key_F) {
            if (searchMode) searchQuery.focus = true
            else if (!selectMode) searchMode = true
            event.accepted = true
        }
    }
    Keys.onDeletePressed: {
        if (urlsListView.ViewItems.selectMode) {
            internal.removeSelected()
        } else {
            if (urlsListView.activeFocus) {
                HistoryModel.removeEntryByUrl(urlsListView.currentItem.siteUrl)

                if (urlsListView.count == 0) {
                    lastVisitDateListView.currentIndex = 0
                }
            } else {
                if (lastVisitDateListView.currentIndex == 0) {
                    HistoryModel.clearAll()
                } else {
                    HistoryModel.removeEntriesByDate(lastVisitDateListView.currentItem.lastVisitDate)
                    lastVisitDateListView.currentIndex = 0
                }
            }
        }
    }

    onActiveFocusChanged: {
        if (activeFocus) {
            urlsListView.forceActiveFocus()
        }
    }

    Rectangle {
        anchors.fill: parent
    }

    Timer {
        // Set the model asynchronously to ensure
        // the view is displayed as early as possible.
        id: loadModelTimer
        interval: 1
        onTriggered: historySearchModel.sourceModel = HistoryModel
    }

    function loadModel() { loadModelTimer.restart() }

    TextSearchFilterModel {
        id: historySearchModel
        searchFields: ["title", "url"]
        terms: searchQuery.terms
    }

    Row {
        id: historyViewWideRow
        anchors {
            top: topBar.bottom
            left: parent.left
            bottom: bottomToolbar.top
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
        }

        spacing: units.gu(1)

        FocusScope {
            width: units.gu(40)
            height: parent.height

            ListView {
                id: lastVisitDateListView
                objectName: "lastVisitDateListView"

                anchors.fill: parent
                focus: true

                currentIndex: 0
                onCurrentIndexChanged: urlsListView.ViewItems.selectedIndices = []

                model: HistoryLastVisitDateListModel {
                    sourceModel: historyLastVisitDateModel.model
                }

                delegate: ListItem {
                    id: lastVisitDateDelegate
                    objectName: "lastVisitDateDelegate"

                    property var lastVisitDate: model.lastVisitDate

                    anchors {
                        left: parent.left
                        right: parent.right
                        rightMargin: units.gu(1)
                    }

                    width: parent.width
                    height: units.gu(4)

                    Label {
                        objectName: "lastVisitDateDelegateLabel"

                        anchors {
                            top: parent.top
                            left: parent.left
                            topMargin: units.gu(1)
                            leftMargin: units.gu(2)
                        }

                        height: parent.height

                        text: {
                            if (!lastVisitDate.isValid()) {
                                return i18n.tr("All History")
                            }

                            var today = new Date()
                            today.setHours(0, 0, 0, 0)

                            var yesterday = new Date()
                            yesterday.setDate(yesterday.getDate() - 1)
                            yesterday.setHours(0, 0, 0, 0)

                            var entryDate = new Date(lastVisitDate)
                            entryDate.setHours(0, 0, 0, 0)

                            if (entryDate.getTime() == today.getTime()) {
                                return i18n.tr("Today")
                            } else if (entryDate.getTime() == yesterday.getTime()) {
                                return i18n.tr("Yesterday")
                            }
                            return Qt.formatDate(lastVisitDate, Qt.DefaultLocaleLongDate)
                        }

                        fontSize: "small"
                        color: (!lastVisitDateListView.activeFocus && lastVisitDateDelegate.ListView.isCurrentItem) ? UbuntuColors.orange : UbuntuColors.darkGrey
                    }

                    divider {
                        // Hide the divider so that the highlight doesn’t overlap it
                        // Do not set visible to false, otherwise the content item is resized.
                        opacity: (!ListView.view.activeFocus ||
                                  (index > ListView.view.currentIndex) ||
                                  (index < (ListView.view.currentIndex - 1))) ? 1 : 0
                        Behavior on opacity { UbuntuNumberAnimation {} }
                    }

                    onClicked: ListView.view.currentIndex = index

                    ListView.onRemove: {
                        if (ListView.isCurrentItem) {
                            // For some reason, setting the current index here
                            // results in it being reset to its previous value
                            // right away. Delaying it with a timer so the
                            // operation is queued does the trick.
                            resetIndexTimer.restart()
                        }
                    }
                }

                highlight: ListViewHighlight {}

                Timer {
                    id: resetIndexTimer
                    interval: 0
                    onTriggered: lastVisitDateListView.currentIndex = 0
                }
            }

            Keys.onUpPressed: {
                if (searchMode) {
                    searchQuery.focus = true
                } else {
                    event.accepted = false
                }
            }

            Scrollbar {
                flickableItem: lastVisitDateListView
                align: Qt.AlignTrailing
            }
        }

        Item {
            width: historyViewWide.width - lastVisitDateListView.width - historyViewWideRow.spacing - units.gu(4)
            height: parent.height

            ListView {
                id: urlsListView
                objectName: "urlsListView"

                anchors.fill: parent

                Keys.onReturnPressed: historyEntrySelected()
                Keys.onEnterPressed: historyEntrySelected()

                model: SortFilterModel {
                    id: historyLastVisitDateModel
                    readonly property date lastVisitDate: lastVisitDateListView.currentItem ? lastVisitDateListView.currentItem.lastVisitDate : ""
                    filter {
                        property: "lastVisitDateString"
                        pattern: new RegExp(lastVisitDate.isValid() ? "^%1$".arg(Qt.formatDate(lastVisitDate, "yyyy-MM-dd")) : "")
                    }
                    // Until a valid HistoryModel is assigned the TextSearchFilterModel
                    // will not report role names, and the HistoryLastVisitDateListModel
                    // will emit warnings since it needs a dateLastVisit role to be
                    // present.
                    model: historySearchModel.sourceModel ? historySearchModel : null
                }

                clip: true

                onModelChanged: urlsListView.currentIndex = -1

                onActiveFocusChanged: {
                    if (!activeFocus) {
                        urlsListView.currentIndex = -1
                    } else {
                        urlsListView.currentIndex = 0
                    }
                }

                function historyEntrySelected() {
                    if (urlsListView.ViewItems.selectMode) {
                        currentItem.selected = !currentItem.selected
                    } else {
                        historyViewWide.historyEntryClicked(currentItem.siteUrl)
                    }
                }

                // Only use sections for "All History" history list
                section.property: historyLastVisitDateModel.lastVisitDate.isValid() ? "" : "lastVisitDate"
                section.delegate: HistorySectionDelegate {
                    width: parent.width - units.gu(3)
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    todaySectionTitle: i18n.tr("Today")
                }

                delegate: UrlDelegate{
                    objectName: "historyDelegate"
                    width: parent.width - units.gu(1)
                    height: units.gu(5)

                    property url siteUrl: model.url

                    icon: model.icon
                    title: Highlight.highlightTerms(model.title ? model.title : model.url, searchQuery.terms)
                    url: Highlight.highlightTerms(model.url, searchQuery.terms)

                    headerComponent: Label {
                        text: Qt.formatTime(model.lastVisit)
                        fontSize: "xx-small"
                    }

                    onClicked: {
                        if (selectMode) {
                            selected = !selected
                        } else {
                            historyViewWide.historyEntryClicked(model.url)
                        }
                    }

                    onRemoved: {
                        HistoryModel.removeEntryByUrl(model.url)
                        if (urlsListView.count == 0) {
                            lastVisitDateListView.currentIndex = 0
                        }
                    }

                    onPressAndHold: {
                        if (historyViewWide.searchMode) return
                        selectMode = !selectMode
                        if (selectMode) {
                            urlsListView.ViewItems.selectedIndices = [index]
                        }
                    }
                }

                highlight: ListViewHighlight {}
            }

            Scrollbar {
                flickableItem: urlsListView
                align: Qt.AlignTrailing
            }
        }
    }

    Local.Toolbar {
        id: topBar

        height: units.gu(7)
        color: "#f7f7f7"

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        Keys.onEscapePressed: {
            if (searchQuery.activeFocus) {
                historyViewWide.searchMode = false
            } else {
                event.accepted = false
            }
        }

        Label {
            visible: !urlsListView.ViewItems.selectMode &&
                     !historyViewWide.searchMode

            anchors {
                top: parent.top
                left: parent.left
                topMargin: units.gu(2)
                leftMargin: units.gu(2)
            }

            text: i18n.tr("History")
        }

        ToolbarAction {
            objectName: "backButton"

            visible: historyViewWide.selectMode || historyViewWide.searchMode

            anchors {
                top: parent.top
                left: parent.left
                leftMargin: units.gu(2)
            }
            height: parent.height - units.gu(2)

            iconName: "back"
            text: i18n.tr("Cancel")

            onClicked: {
                if (historyViewWide.searchMode) {
                    historyViewWide.searchMode = false
                } else {
                    urlsListView.ViewItems.selectMode = false
                }
                lastVisitDateListView.forceActiveFocus()
            }
        }

        ToolbarAction {
            objectName: "selectButton"

            visible: urlsListView.ViewItems.selectMode

            anchors {
                top: parent.top
                right: deleteButton.left
                rightMargin: units.gu(2)
            }
            height: parent.height - units.gu(2)

            iconName: "select"
            text: i18n.tr("Select all")

            onClicked: internal.toggleSelectAll()
        }

        ToolbarAction {
            id: deleteButton
            objectName: "deleteButton"

            visible: urlsListView.ViewItems.selectMode

            anchors {
                top: parent.top
                right: parent.right
                rightMargin: units.gu(2)
            }
            height: parent.height - units.gu(2)

            iconName: "delete"
            text: i18n.tr("Delete")
            enabled: urlsListView.ViewItems.selectedIndices.length > 0
            onClicked: internal.removeSelected()
        }

        TextField {
            id: searchQuery
            objectName: "searchQuery"
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: units.gu(2)
            }
            width: urlsListView.width
            inputMethodHints: Qt.ImhNoPredictiveText
            primaryItem: Icon {
               height: parent.height - units.gu(2)
               width: height
               name: "search"
            }
            hasClearButton: true
            placeholderText: i18n.tr("search history")
            visible: historyViewWide.searchMode
            readonly property var terms: text.split(/\s+/g).filter(function(term) { return term.length > 0 })

            Keys.onDownPressed: urlsListView.focus = true
        }

        ToolbarAction {
            id: searchButton
            iconName: "search"
            objectName: "searchButton"
            visible: !urlsListView.ViewItems.selectMode &&
                     !historyViewWide.searchMode
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: units.gu(3.5)
            }
            height: parent.height - units.gu(2)
            onClicked: {
                historyViewWide.searchMode = true
                searchQuery.forceActiveFocus()
            }
        }

        ListItems.ThinDivider {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
        }
    }

    Local.Toolbar {
        id: bottomToolbar
        height: units.gu(7)

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        Button {
            objectName: "doneButton"
            anchors {
                left: parent.left
                leftMargin: units.gu(2)
                verticalCenter: parent.verticalCenter
            }

            strokeColor: UbuntuColors.darkGrey

            text: i18n.tr("Done")

            onClicked: historyViewWide.done()
        }

        ToolbarAction {
            objectName: "newTabButton"
            anchors {
                right: parent.right
                rightMargin: units.gu(2)
                verticalCenter: parent.verticalCenter
            }
            height: parent.height - units.gu(2)

            text: i18n.tr("New tab")
            iconName: "tab-new"

            onClicked: {
                historyViewWide.newTabRequested()
                historyViewWide.done()
            }
        }
    }

    QtObject {
        id: internal

        function toggleSelectAll() {
            if (urlsListView.ViewItems.selectedIndices.length === urlsListView.count) {
                urlsListView.ViewItems.selectedIndices = []
            } else {
                var indices = []
                for (var i = 0; i < urlsListView.count; ++i) {
                    indices.push(i)
                }
                urlsListView.ViewItems.selectedIndices = indices
            }

            urlsListView.forceActiveFocus()
        }

        function removeSelected() {
            var indices = urlsListView.ViewItems.selectedIndices
            var urls = []
            for (var i in indices) {
                urls.push(urlsListView.model.get(indices[i])["url"])
            }

            if (urlsListView.count == urls.length) {
                lastVisitDateListView.currentIndex = 0
            }

            urlsListView.ViewItems.selectMode = false
            for (var j in urls) {
                HistoryModel.removeEntryByUrl(urls[j])
            }

            lastVisitDateListView.forceActiveFocus()
        }
    }
}
