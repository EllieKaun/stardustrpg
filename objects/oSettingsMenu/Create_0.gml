menuEnsureCrispGui()

resolutions = [
    [1280, 720],
    [1600, 900],
    [1920, 1080],
    [2560, 1440],
    [3840, 2160]
]

// Find current resolution index or default to 1920x1080
var curW = window_get_width()
var curH = window_get_height()
currentResIndex = 2 // default 1920x1080
for (var i = 0; i < array_length(resolutions); i++) {
    if (curW == resolutions[i][0] && curH == resolutions[i][1]) {
        currentResIndex = i
        break
    }
}

selectedResIndex = currentResIndex

// Fullscreen
currentFullscreen = window_get_fullscreen()
selectedFullscreen = currentFullscreen

// Back layers for menu rendering (similar to pause menu)
backLayers = [
    new MenuLayer(noone, { alpha: 0.8, placeholderColor: make_color_rgb(10, 15, 20) })
]
foreLayers = []
itemsAboveForeground = true

updateMenuLabels = function() {
    var resText = "Resolution: < " + string(resolutions[selectedResIndex][0]) + "x" + string(resolutions[selectedResIndex][1]) + " >"
    var fsText = "Fullscreen: < " + (selectedFullscreen ? "On" : "Off") + " >"
    
    menu.items[0].label = resText
    menu.items[1].label = fsText
    
    // Enable/disable Apply and Cancel based on changes
    var hasChanges = (selectedResIndex != currentResIndex) || (selectedFullscreen != currentFullscreen)
    menu.items[2].enabled = hasChanges // Apply
    menu.items[3].enabled = hasChanges // Cancel
}

menu = new Menu([
    new MenuItem("Resolution", noone, noone, function(it) {
        // Handled by Left/Right arrows now, but we can keep mouse click support
        selectedResIndex = (selectedResIndex + 1) mod array_length(resolutions)
        updateMenuLabels()
    }),
    new MenuItem("Fullscreen", noone, noone, function(it) {
        // Handled by Left/Right arrows now, but we can keep mouse click support
        selectedFullscreen = !selectedFullscreen
        updateMenuLabels()
    }),
    new MenuItem("Apply", noone, noone, function(it) {
        currentResIndex = selectedResIndex
        currentFullscreen = selectedFullscreen
        
        window_set_fullscreen(currentFullscreen)
        if (!currentFullscreen) {
            window_set_size(resolutions[currentResIndex][0], resolutions[currentResIndex][1])
        }
        
        ini_open("settings.ini")
        ini_write_real("Display", "ResolutionIndex", currentResIndex)
        ini_write_real("Display", "Fullscreen", currentFullscreen ? 1 : 0)
        ini_close()
        
        updateMenuLabels()
    }),
    new MenuItem("Cancel", noone, noone, function(it) {
        selectedResIndex = currentResIndex
        selectedFullscreen = currentFullscreen
        updateMenuLabels()
    }),
    new MenuItem("Back", noone, noone, function(it) {
        if (instance_exists(oMainMenu)) {
            with(oMainMenu) { visible = true; menuCooldown = 2; }
        }
        if (instance_exists(oPauseMenu)) {
            with(oPauseMenu) { visible = true; menuCooldown = 2; }
        }
        instance_destroy()
    })
], {
    anchorX: 0.5, startY: 0.4, spacing: 0.12, textH: 0.055, halign: fa_center
})

updateMenuLabels()

mouseLastX = -1
mouseLastY = -1
