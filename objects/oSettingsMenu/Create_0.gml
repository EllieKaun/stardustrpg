menuEnsureCrispGui()

resolutions = menuGetResolutions()

// Поиск индекса текущего разрешения
var curW = window_get_width()
var curH = window_get_height()
currentResIndex = min(2, array_length(resolutions) - 1) // по умолчанию 1920x1080 или максимально доступное
for (var i = 0; i < array_length(resolutions); i++) {
    if (curW == resolutions[i][0] && curH == resolutions[i][1]) {
        currentResIndex = i
        break
    }
}

selectedResIndex = currentResIndex

// Полноэкранный режим
currentFullscreen = window_get_fullscreen()
selectedFullscreen = currentFullscreen

// Громкость
if (!variable_global_exists("volMaster")) {
    global.volMaster = 1.0
    global.volMusic = 0.8
    global.volSounds = 1.0
}
selectedVolMaster = global.volMaster
selectedVolMusic = global.volMusic
selectedVolSounds = global.volSounds

// Задние слои для отрисовки меню (аналогично меню паузы)
backLayers = [
    new MenuLayer(noone, { alpha: 0.8, placeholderColor: make_color_rgb(10, 15, 20) })
]
foreLayers = []
itemsAboveForeground = true

previewAudioVolumes = function() {
    audio_master_gain(selectedVolMaster)
    if (variable_global_exists("currentMusic") && global.currentMusic != noone) {
        audio_sound_gain(global.currentMusic, selectedVolMusic, 0)
    }
    if (variable_global_exists("currentAmbient") && global.currentAmbient != noone) {
        audio_sound_gain(global.currentAmbient, selectedVolSounds, 0)
    }
}

updateMenuLabels = function() {
    var resText = "Resolution: < " + string(resolutions[selectedResIndex][0]) + "x" + string(resolutions[selectedResIndex][1]) + " >"
    var fsText = "Fullscreen: < " + (selectedFullscreen ? "On" : "Off") + " >"
    var volMasterText = "Master Vol: < " + string(round(selectedVolMaster * 100)) + "% >"
    var volMusicText = "Music Vol: < " + string(round(selectedVolMusic * 100)) + "% >"
    var volSoundsText = "Sounds Vol: < " + string(round(selectedVolSounds * 100)) + "% >"
    
    menu.items[0].label = resText
    menu.items[1].label = fsText
    menu.items[2].label = volMasterText
    menu.items[3].label = volMusicText
    menu.items[4].label = volSoundsText
    
    // Включение/отключение кнопок "Применить" и "Отмена" при наличии изменений
    var hasChanges = (selectedResIndex != currentResIndex) || (selectedFullscreen != currentFullscreen)
    hasChanges = hasChanges || (selectedVolMaster != global.volMaster) || (selectedVolMusic != global.volMusic) || (selectedVolSounds != global.volSounds)
    menu.items[5].enabled = hasChanges // Применить
    menu.items[6].enabled = hasChanges // Отмена
    
    // Применяем громкость в реальном времени для предпросмотра
    previewAudioVolumes()
}

menu = new Menu([
    new MenuItem("Resolution", noone, noone, function(it) {
        selectedResIndex = (selectedResIndex + 1) mod array_length(resolutions)
        updateMenuLabels()
    }),
    new MenuItem("Fullscreen", noone, noone, function(it) {
        selectedFullscreen = !selectedFullscreen
        updateMenuLabels()
    }),
    new MenuItem("Master Vol", noone, noone, function(it) {
        selectedVolMaster = clamp(selectedVolMaster + 0.1, 0, 1.0)
        updateMenuLabels()
    }),
    new MenuItem("Music Vol", noone, noone, function(it) {
        selectedVolMusic = clamp(selectedVolMusic + 0.1, 0, 1.0)
        updateMenuLabels()
    }),
    new MenuItem("Sounds Vol", noone, noone, function(it) {
        selectedVolSounds = clamp(selectedVolSounds + 0.1, 0, 1.0)
        updateMenuLabels()
        var snd = audio_play_sound(SND_CARD_SELECT, 8, false)
        audio_sound_gain(snd, selectedVolSounds, 0)
    }),
    new MenuItem("Apply", noone, noone, function(it) {
        currentResIndex = selectedResIndex
        currentFullscreen = selectedFullscreen
        global.volMaster = selectedVolMaster
        global.volMusic = selectedVolMusic
        global.volSounds = selectedVolSounds
        // applyAudioVolumes() is no longer strictly needed since previewAudioVolumes is called, but we leave it for consistency or we can omit it.
        // Actually, let's keep it just in case.
        applyAudioVolumes()
        
        if (!currentFullscreen) {
            window_set_size(resolutions[currentResIndex][0], resolutions[currentResIndex][1])
        }
        window_set_fullscreen(currentFullscreen)
        surface_resize(application_surface, resolutions[currentResIndex][0], resolutions[currentResIndex][1])
        display_set_gui_size(resolutions[currentResIndex][0], resolutions[currentResIndex][1])
        
        ini_open("settings.ini")
        ini_write_real("Display", "ResolutionIndex", currentResIndex)
        ini_write_real("Display", "Fullscreen", currentFullscreen ? 1 : 0)
        ini_write_real("Audio", "Master", global.volMaster)
        ini_write_real("Audio", "Music", global.volMusic)
        ini_write_real("Audio", "Sounds", global.volSounds)
        ini_close()
        
        updateMenuLabels()
        
        // Возвращаемся в предыдущее меню после сохранения
        if (instance_exists(oMainMenu)) {
            with(oMainMenu) { visible = true; menuCooldown = 2; }
        }
        if (instance_exists(oPauseMenu)) {
            with(oPauseMenu) { visible = true; menuCooldown = 2; }
        }
        instance_destroy()
    }),
    new MenuItem("Cancel", noone, noone, function(it) {
        selectedResIndex = currentResIndex
        selectedFullscreen = currentFullscreen
        selectedVolMaster = global.volMaster
        selectedVolMusic = global.volMusic
        selectedVolSounds = global.volSounds
        updateMenuLabels()
    }),
    new MenuItem("Back", noone, noone, function(it) {
        // Ревертим аудио, если нажали Back без Apply
        selectedVolMaster = global.volMaster
        selectedVolMusic = global.volMusic
        selectedVolSounds = global.volSounds
        previewAudioVolumes()
        
        if (instance_exists(oMainMenu)) {
            with(oMainMenu) { visible = true; menuCooldown = 2; }
        }
        if (instance_exists(oPauseMenu)) {
            with(oPauseMenu) { visible = true; menuCooldown = 2; }
        }
        instance_destroy()
    })
], {
    anchorX: 0.5, startY: 0.18, spacing: 0.10, textH: 0.045, halign: fa_center
})

updateMenuLabels()

mouseLastX = -1
mouseLastY = -1
