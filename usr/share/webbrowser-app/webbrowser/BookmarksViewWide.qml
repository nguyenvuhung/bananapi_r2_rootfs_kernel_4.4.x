/*
 * Copyright 2015 Canonical Ltd.
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
import "." as Local

FocusScope {
    id: bookmarksViewWide

    property alias homepageUrl: bookmarksFoldersViewWide.homeBookmarkUrl

    signal bookmarkEntryClicked(url url)
    signal done()
    signal newTabClicked()

    Rectangle {
        anchors.fill: parent
        color: "#f6f6f6"
    }

    BookmarksFoldersViewWide {
        id: bookmarksFoldersViewWide

        anchors {
            top: topBar.bottom
            left: parent.left
            right: parent.right
            bottom: toolbar.top
        }

        focus: true

        onBookmarkClicked: bookmarksViewWide.bookmarkEntryClicked(url)
        onBookmarkRemoved: {
            if (BookmarksModel.count == 1) {
                done()
            }
            BookmarksModel.remove(url)
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

        Label {
            anchors {
                top: parent.top
                left: parent.left
                topMargin: units.gu(2)
                leftMargin: units.gu(2)
            }

            text: i18n.tr("Bookmarks")
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
        id: toolbar
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

            onClicked: bookmarksViewWide.done()
        }

        ToolbarAction {
            objectName: "newTabAction"
            anchors {
                right: parent.right
                rightMargin: units.gu(2)
                verticalCenter: parent.verticalCenter
            }
            height: parent.height - units.gu(2)

            text: i18n.tr("New tab")
            iconName: "tab-new"

            onClicked: bookmarksViewWide.newTabClicked()
        }
    }
}
