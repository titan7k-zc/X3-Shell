pragma Singleton
import QtQuick
import Quickshell
import QtCore

Singleton {
    id: root

    property alias theme: settings.theme 

    Settings {
        id: settings
        property int theme: 0
    }



    property int themeAnimationDuration: 800

    property var themeColors: [
        // ["Nord", "#626F89", "#D8DEE9", "#C8D8E9", "#D8DEE9", "#ECEFF4", "#88C0D0", "#D8DEE9", "#214C566A", "#88C0D0", "#88C0D0", "#A3BE8C"],
        // ["Light", "#E5E9F0", "#2E3440", "#3B4252", "#2E3440", "#4C566A", "#5E81AC", "#2E3440", "#D8DEE9", "#5E81AC", "#5E81AC", "#5E81AC"],
        ["Crimson", "#000000", "#959595", "#c8959595", "#959595", "#ffffff", '#ed1358', "#959595",  "#ef2a68", "#ef2a68", "#ef2a68"],
        ["Nord Frost", "#2E3440", "#ECEFF4", "#AEB8C7", "#D8DEE9", "#8FBCBB", "#81A1C1", "#88C0D0",  "#88C0D0", "#81A1C1", "#A3BE8C"],
        ["Polar Night", "#242933", "#E5E9F0", "#9AA4B2", "#C8D0DC", "#81A1C1", "#88C0D0", "#8FBCBB", "#88C0D0", "#81A1C1", "#A3BE8C"],
        ["Blue Steel", "#202833", "#DCE6F2", "#8B9BAD", "#B8C7D9", "#8CB4D8", "#6FA8DC", "#91C4E8", "#8CB4D8", "#6FA8DC", "#9BCB8B"],
        ["Deep Ocean", "#0D1B24", "#D6E5EA", "#78909C", "#B0C4CC", "#5FB3B3", "#4FA3D1", "#72C7D9",  "#5FB3B3", "#4FA3D1", "#9CCC65"],
        ["Aurora", "#182027", "#DCE7E5", "#899B99", "#B9CCC7", "#A3BE8C", "#88C0D0", "#B48EAD", "#8FBCBB", "#88C0D0", "#A3BE8C"],
        ["Catppuccin Mocha", "#1E1E2E", "#CDD6F4", "#A6ADC8", "#BAC2DE", "#F5E0E8", "#89B4FA", "#B4BEFE", "#89DCEB", "#89B4FA", "#A6E3A1"],
        ["Tokyo Night", "#1A1B26", "#C0CAF5", "#9AA5CE", "#A9B1D6", "#BB9AF7", "#7AA2F7", "#89DDFF",  "#7DCFFF", "#7AA2F7", "#9ECE6A"],
        ["Dracula", "#282A36", "#F8F8F2", "#BFBFBF", "#F8F8F2", "#8BE9FD", "#BD93F9", "#FF79C6",  "#8BE9FD", "#50FA7B", "#F1FA8C"],
        ["Gruvbox", "#282828", "#EBDBB2", "#A89984", "#D5C4A1", "#FBF1C7", "#83A598", "#8EC07C",  "#83C07C", "#83A598", "#B8BB26"],
        ["Rose Pine", "#191724", "#E0DEF4", "#908CAA", "#E0DEF4", "#F6C177", "#C4A7E7", "#EBBCBA",  "#9CCFD8", "#C4A7E7", "#9CCFD8"],
        ["Everforest", "#2D353B", "#D3C6AA", "#9DA9A0", "#D3C6AA", "#A7C080", "#A7C080", "#83C092",  "#83C092", "#7FBBB3", "#A7C080"],
        ["One Dark", "#282C34", "#ABB2BF", "#7F848E", "#ABB2BF", "#D19A66", "#61AFEF", "#C678DD",  "#56B6C2", "#61AFEF", "#98C379"],
        ["Kanagawa", "#1F1F28", "#DCD7BA", "#727169", "#C8C093", "#98BB6C", "#7E9CD8", "#7FB4CA",  "#7AA89F", "#7E9CD8", "#98BB6C"],
        ["Nord Aurora", "#3B4252", "#ECEFF4", "#D8DEE9", "#E5E9F0", "#A3BE8C", "#88C0D0", "#B48EAD", "#81A1C1", "#88C0D0", "#A3BE8C"],
        ["Ayu Dark", "#0D1017", "#D5D8DA", "#8A9199", "#B7BDC5", "#C7D1DB", "#E6B450", "#73B7FF",  "#E6B450", "#73B7FF", "#7FD962"],
        ["Nord", "#626f89", "#D8DEE9", "#c8D8DEE9", "#D8DEE9", "#ECEFF4", "#88C0D0", "#D8DEE9", "#88C0D0", "#88C0D0", "#88C0D0"], // A
        ["Material Ocean", "#0F111A", "#EEFFFF", "#8F93A2", "#C5C8C6", "#89DDFF", "#82AAFF", "#C792EA", "#89DDFF", "#82AAFF", "#C3E88D"],
        ["Moonlight", "#222436", "#C8D3F5", "#828BB8", "#A9B8E8", "#86E1FC", "#82AAFF", "#C099FF",  "#86E1FC", "#82AAFF", "#C3E88D"], // AA
        ["Horizon", "#1C1E26", "#D5D8DA", "#A1A1A1", "#D5D8DA", "#E95678", "#FAB795", "#B877DB",  "#25B0BC", "#FAB795", "#29D398"],
        ["Monokai", "#272822", "#F8F8F2", "#A6A69C", "#F8F8F2", "#A6E22E", "#66D9EF", "#FD971F",  "#A6E22E", "#66D9EF", "#E6DB74"],
        ["Solarized Dark", "#002B36", "#839496", "#657B83", "#93A1A1", "#B58900", "#268BD2", "#2AA198", "#B58900", "#268BD2", "#859900"],
        ["Cyberpunk", "#0B0E14", "#E6E6E6", "#7A7F8B", "#C5C8C6", "#00E5FF", "#FF00A8", "#B967FF",  "#00E5FF", "#FF00A8", "#A6FF00"],
        ["Synthwave", "#241B2F", "#F8F8F2", "#A89BB9", "#E6E1FF", "#FF7EDB", "#FF7EDB", "#36F9F6",  "#36F9F6", "#FF7EDB", "#72F1B8"],
        ["Amethyst", "#17131F", "#E8E0F0", "#9C91A8", "#D4C5E2", "#C8A2FF", "#A970FF", "#E0AAFF",  "#C8A2FF", "#A970FF", "#9BE28C"],
        ["Oceanic", "#0B1E26", "#D8E6E9", "#8199A1", "#B8CDD2", "#5CCFE6", "#4DB6E8", "#89DDFF",  "#5CCFE6", "#4DB6E8", "#91D67A"],
        ["Forest Night", "#101A16", "#D8E8DF", "#81968A", "#B9D0C1", "#8FCB9B", "#78C091", "#A3D9A5",  "#8FCB9B", "#78C091", "#C5D86D"],
        ["Coffee Dark", "#211B18", "#E8DDD5", "#A4948C", "#D1C0B7", "#D9A066", "#C78B5A", "#E0B084",  "#D9A066", "#C78B5A", "#A8C080"], // AA
        ["Midnight", "#10141C", "#D7DEE9", "#7F8A9A", "#B8C2D1", "#8BA4C7", "#6C8ED4", "#91B4E8", "#8BA4C7", "#6C8ED4", "#91C483"],
        ["Obsidian", "#111111", "#E6E6E6", "#858585", "#C8C8C8", "#A8D08D", "#6EA8FE", "#C586C0",  "#7FDBCA", "#6EA8FE", "#A8D08D"],
        ["Slate", "#20242B", "#D9DEE7", "#8B939F", "#BEC6D1", "#9AA8B8", "#7FA6D9", "#9BB7D4",  "#8FB9A8", "#7FA6D9", "#A5C982"],
        ["Arctic", "#18212B", "#E5EDF5", "#91A4B7", "#C7D5E3", "#A6D8FF", "#72B7FF", "#9AC7FF",  "#8ED6FF", "#72B7FF", "#9EDC9A"],
        ["Deep Purple", "#181520", "#E6DFF2", "#9288A3", "#C8BED8", "#B8A0FF", "#9B7BFF", "#D0A8FF", "#B8A0FF", "#9B7BFF", "#A6D98A"],
        ["Cherry", "#1E1418", "#F0DCE2", "#A98A94", "#D7BBC3", "#FF8FA3", "#FF6B81", "#FF9FB0", "#FF8FA3", "#FF6B81", "#A8D88A"], // AA
        ["Ember", "#211714", "#F0DDD5", "#A99087", "#D6C0B8", "#FF9E64", "#FF8F5E", "#FFB088",  "#FF9E64", "#FF8F5E", "#B5D66A"],
        ["Lavender", "#191722", "#E4DDF5", "#9690AA", "#CAC2DF", "#B9A7FF", "#A78BFA", "#D0B8FF", "#B9A7FF", "#A78BFA", "#A8D68A"],
    ]

    // === Global ===
    property color shellBackgroundColor: themeColors[theme][1]
    property color mainTextColor: themeColors[theme][2]
    property color secondaryTextColor: themeColors[theme][3]
    property color mainIconColor: themeColors[theme][4]
    property color aliveIconColor: themeColors[theme][5]
    property color activeColor: themeColors[theme][6]
    property color focusColor: themeColors[theme][7]

    // === Animations ===
    Behavior on shellBackgroundColor { ColorAnimation { duration: root.themeAnimationDuration; easing.type: Easing.InOutQuad } }
    Behavior on mainTextColor { ColorAnimation { duration: root.themeAnimationDuration; easing.type: Easing.InOutQuad } }
    Behavior on secondaryTextColor { ColorAnimation { duration: root.themeAnimationDuration; easing.type: Easing.InOutQuad } }
    Behavior on mainIconColor { ColorAnimation { duration: root.themeAnimationDuration; easing.type: Easing.InOutQuad } }
    Behavior on aliveIconColor { ColorAnimation { duration: root.themeAnimationDuration; easing.type: Easing.InOutQuad } }
    Behavior on activeColor { ColorAnimation { duration: root.themeAnimationDuration; easing.type: Easing.InOutQuad } }
    Behavior on focusColor { ColorAnimation { duration: root.themeAnimationDuration; easing.type: Easing.InOutQuad } }


    // === cava ===
    readonly property color cavaBackgroundColor: powerBarBulletColor
    readonly property color cavaBarColor: Qt.rgba(activeColor.r, activeColor.g, activeColor.b, 1.0)


    // === Workspace ===
    readonly property color workspaceActiveColor: activeColor
    readonly property color workspaceAliveColor: activeColor
    readonly property color workspaceInactiveColor: mainIconColor

    // === Clock ===
    readonly property color clockTextColor: mainTextColor

    // === Brightness ===
    property color brightnessIconColor: themeColors[theme][8]
    Behavior on brightnessIconColor { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    readonly property color brightnessTextColor: mainTextColor

    // === Volume ===
    property color volumeIconColor: themeColors[theme][9]
    Behavior on volumeIconColor { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    readonly property color volumeTextColor: mainTextColor


    // === Battery ===
    property color batteryIconColor: themeColors[theme][10]
    Behavior on batteryIconColor { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
    readonly property color batteryTextColor: mainTextColor


    // === Spotify ===
    readonly property color spotifyPanelColor: "Transparent"
    readonly property color spotifyAlbumPlaceholderColor: "#3B4252"
    readonly property color spotifyAlbumBorder: Qt.rgba(activeColor.r, activeColor.g, activeColor.b, 0.7)
    readonly property color spotifyTitleColor: activeColor
    readonly property color spotifyArtistColor: secondaryTextColor
    readonly property color spotifyControlColor: mainTextColor
    readonly property color spotifyControlIconColor: shellBackgroundColor
    readonly property color spotifyPlayColor: Qt.rgba(activeColor.r, activeColor.g, activeColor.b, 0.8)


    // === Popups ===
    readonly property color pop8MenuColor: shellBackgroundColor
    readonly property color pop8ShadowColor: shellBackgroundColor


    // === Taskbar ===
    readonly property color taskbarTextColor: mainTextColor
    readonly property color taskbarActiveColor: activeColor

    // === Wallpaper ===
    readonly property color wallpaperLoadingTextColor: mainTextColor
    readonly property color themeBackgroundColor: "#a9000000"
    readonly property color themeIconColor: activeColor
    readonly property color themeTextColor: mainTextColor
    readonly property color wallthemeSelectedColor: secondaryTextColor   
    readonly property color wallthemeActiveColor: activeColor



    // === Overview ===
    readonly property color overviewTextColor: mainTextColor
    readonly property color overviewSecondaryTextColor: secondaryTextColor
    readonly property color overviewSurfaceFillColor: "Transparent"    // dont chnage
    readonly property color overviewIndicatorColor: activeColor
    readonly property color overviewIndicatorIconColor: mainIconColor
    readonly property color overviewIndicatorTrackColor: Qt.rgba(overviewIndicatorColor.r, overviewIndicatorColor.g, overviewIndicatorColor.b, 0.1)//Qt.rgba(1, 1, 1, 0.12)
    readonly property color overviewWarningColor: activeColor // for temperature value
    readonly property color overviewNormalColor: mainTextColor // for temperature value
    readonly property color overviewLevelBarBackgroundColor: Qt.rgba(overviewIndicatorColor.r, overviewIndicatorColor.g, overviewIndicatorColor.b, 0.1)//mainTextColor 
    readonly property color overviewlevelBarFillColor: overviewIndicatorColor 

    // === Power menu ===
    readonly property color powerButtonColor: "Transparent"
    readonly property color powerIconColor: mainIconColor
    readonly property color powerFocusedIconColor: activeColor

    // === Bar ===
    readonly property color barBorderColor: shellBackgroundColor

    // === Power bar / topbar ===
    readonly property color powerBarTextColor: mainTextColor
    readonly property color powerBarBulletColor: Qt.rgba(shellBackgroundColor, shellBackgroundColor, shellBackgroundColor, 0.3)


    // === Launcher ===
    readonly property color launcherPanelColor: "Transparent"
    readonly property color launcherBorderColor: "Transparent"
    readonly property color launcherPrimaryTextColor: mainTextColor//"#EBCB8B"
    readonly property color launcherDimTextColor: mainTextColor
    readonly property color launcherAccentColor: Qt.rgba(activeColor.r, activeColor.g, activeColor.b, 0.3)  // dont change
    readonly property color launcherAccentIconColor: "Transparent"
    readonly property color launcherSearchBackgroundColor: Qt.rgba(1, 1, 1, 0.07)
    readonly property color launcherSearchFocusColor: activeColor
    readonly property color launcherIconBubbleColor: Qt.rgba(1, 1, 1, 0.08)
    readonly property color launcherDragHandleColor: "Transparent"



}
