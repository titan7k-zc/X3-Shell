pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris


Singleton {
    id: root

    // ---- find the Spotify MPRIS player among all connected players ----
    property var player: {
        for (let i = 0; i < Mpris.players.values.length; i++) {
            const p = Mpris.players.values[i];
            if (p.dbusName && p.dbusName.indexOf("spotify") !== -1) return p;
            if (p.identity && p.identity.toLowerCase().indexOf("spotify") !== -1) return p;
        }
        return null;
    }
    property bool running: player !== null

    // ---- persistent cache paths (survive quickshell + spotify restarts) ----
    property string artCachePath: Quickshell.cachePath("spotify/last-art.jpg")
    property string metaCachePath: Quickshell.cachePath("spotify/last-meta.json")

    // action queued while we wait for spotify to launch + register on mpris
    property var pendingAction: null

    // ---- which image/text to actually show: live data if we have it, else cache ----
    property string liveArtUrl: player ? player.trackArtUrl : ""
    property string displayArtSource: liveArtUrl.length > 0 ? liveArtUrl: ("file://" + root.artCachePath)

    property string displayTitle: {
        if (player && player.trackTitle) return player.trackTitle;
        const cached = readCachedMeta();
        return cached.title || "Nothing played yet";
    }
    property string displayArtist: {
        if (player && player.trackArtist) return player.trackArtist;
        const cached = readCachedMeta();
        return cached.artist || "";
    }

    // ---- metadata cache (title/artist) ----
    FileView {
        id: metaFile
        path: root.metaCachePath
        printErrors: false
    }

    function readCachedMeta() {
        try {
            return JSON.parse(metaFile.text());
        } catch (e) {
            return { title: "", artist: "" };
        }
    }

    function writeCachedMeta(title, artist) {
        metaFile.setText(JSON.stringify({ title: title, artist: artist }));
    }

    // ---- ensure cache dir exists once at startup ----
    Process {
        running: true
        command: ["mkdir", "-p", Quickshell.cachePath("spotify")]
    }

    // ---- download/copy the current track art into the persistent cache ----
    Process {
        id: artFetcher
    }

    function cacheArt(url) {
        if (!url) return;
        if (url.indexOf("file://") === 0) {
            artFetcher.exec({ command: ["cp", url.substring(7), root.artCachePath] });
        } else {
            artFetcher.exec({ command: ["curl", "-sL", url, "-o", root.artCachePath] });
        }
    }

    Connections {
        target: root.player
        function onTrackArtUrlChanged() {
            if (root.player && root.player.trackArtUrl) {
                root.cacheArt(root.player.trackArtUrl);
            }
        }
        function onTrackTitleChanged() {
            if (root.player) {
                root.writeCachedMeta(root.player.trackTitle, root.player.trackArtist);
            }
        }
    }

    // player is a normal QML property, so it emits its own change signal
    // whenever the computed value changes - this fires reliably the
    // moment spotify registers on the MPRIS bus after being launched.
    onPlayerChanged: {
        if (root.player && root.pendingAction) {
            const action = root.pendingAction;
            root.pendingAction = null;
            // Spotify has JUST registered on mpris - its playback
            // capabilities (canPlay/canGoNext/...) often aren't populated
            // for a few hundred ms yet, so wait briefly before sending
            // the actual command.
            readyTimer.actionToRun = action;
            readyTimer.restart();
        }
    }

    Timer {
        id: readyTimer
        interval: 900
        property var actionToRun: null
        onTriggered: {
            if (root.player && actionToRun) actionToRun(root.player);
            actionToRun = null;
        }
    }

    // launches spotify detached (so it survives quickshell reloads/restarts),
    // then runs `action` on the player once it's available (see
    // onPlayerChanged above)
    Process {
        id: launcher
        command: ["spotify"]
    }

    function ensureThen(action) {
        if (root.player) {
            action(root.player);
        } else {
            root.pendingAction = action;
            launcher.startDetached();
        }
    }

    // ---- public controls ----
    function playPause() {
        ensureThen(function (p) { if (p.canTogglePlaying) p.togglePlaying(); });
    }
    function next() {
        ensureThen(function (p) { if (p.canGoNext) p.next(); });
    }
    function previous() {
        ensureThen(function (p) { if (p.canGoPrevious) p.previous(); });
    }
}
