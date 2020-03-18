/*
 * Copyright 2014-2016 Canonical Ltd.
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
import QtQuick.Window 2.2
import Ubuntu.Components 1.3

Window {
    id: window

    property bool developerExtrasEnabled: false
    property bool forceFullscreen: false
    property var currentWebview: null

    signal openUrls(var urls)

    contentOrientation: Screen.orientation

    width: units.gu(100)
    height: units.gu(75)

    QtObject {
        id: internal
        property int currentWindowState: Window.Windowed
    }

    Connections {
        target: window.currentWebview
        onFullscreenChanged: window.setFullscreen(window.currentWebview.fullscreen)
    }

    function setFullscreen(fullscreen) {
        if (!window.forceFullscreen) {
            if (fullscreen) {
                internal.currentWindowState = window.visibility
                window.visibility = Window.FullScreen
            } else {
                window.visibility = internal.currentWindowState
            }
        }
    }

    // Handle runtime requests to open urls as defined
    // by the freedesktop application dbus interface's open
    // method for DBUS application activation:
    // http://standards.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html#dbus
    // The dispatch on the org.freedesktop.Application if is done per appId at the
    // url-dispatcher/upstart level.
    Connections {
        target: UriHandler
        onOpened: window.openUrls(uris)
    }
}
