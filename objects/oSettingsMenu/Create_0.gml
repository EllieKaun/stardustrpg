menuEnsureCrispGui()
depth = -10000 // поверх интерфейса боя

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

// Задние слои для отрисовки меню 
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
    menu.items[0].label = loc("menu.resolution")
    menu.items[0].valueText = string(resolutions[selectedResIndex][0]) + "x" + string(resolutions[selectedResIndex][1])
    menu.items[1].label = loc("menu.fullscreen")
    menu.items[1].valueText = selectedFullscreen ? loc("menu.on") : loc("menu.off")
    menu.items[2].label = loc("menu.masterVol")
    menu.items[2].valueText = string(round(selectedVolMaster * 100)) + "%"
    menu.items[3].label = loc("menu.musicVol")
    menu.items[3].valueText = string(round(selectedVolMusic * 100)) + "%"
    menu.items[4].label = loc("menu.soundsVol")
    menu.items[4].valueText = string(round(selectedVolSounds * 100)) + "%"
    menu.items[5].label = loc("menu.language")
    menu.items[5].valueText = languageNativeName(global.language)
    menu.items[6].label = loc("menu.apply")
    menu.items[7].label = loc("menu.cancel")
    menu.items[8].label = loc("menu.back")

    // Включение/отключение кнопок "Применить" и "Отмена" при наличии изменений
    var hasChanges = (selectedResIndex != currentResIndex) || (selectedFullscreen != currentFullscreen)
    hasChanges = hasChanges || (selectedVolMaster != global.volMaster) || (selectedVolMusic != global.volMusic) || (selectedVolSounds != global.volSounds)
    menu.items[6].enabled = hasChanges // Применить
    menu.items[7].enabled = hasChanges // Отмена

    // Применяем громкость в реальном времени для предпросмотра
    previewAudioVolumes()
}

changeResolution = function(item, direction) {
    var count = array_length(resolutions)
    selectedResIndex = (selectedResIndex + direction + count) mod count
    updateMenuLabels()
}
changeFullscreen = function(item, direction) {
    selectedFullscreen = !selectedFullscreen
    updateMenuLabels()
}
changeMasterVol = function(item, direction) {
    selectedVolMaster = clamp(selectedVolMaster + 0.1 * direction, 0, 1.0)
    updateMenuLabels()
}
changeMusicVol = function(item, direction) {
    selectedVolMusic = clamp(selectedVolMusic + 0.1 * direction, 0, 1.0)
    updateMenuLabels()
}
changeSoundsVol = function(item, direction) {
    selectedVolSounds = clamp(selectedVolSounds + 0.1 * direction, 0, 1.0)
    updateMenuLabels()
    var sound = audio_play_sound(SND_CARD_SELECT, 8, false)
    audio_sound_gain(sound, selectedVolSounds, 0)
}
changeLanguage = function(item, direction) {
    locCycleLanguage()
    updateMenuLabels()
}

menu = new Menu([
    new MenuItem("Resolution", noone, noone, function(it) { changeResolution(it, 1) }),
    new MenuItem("Fullscreen", noone, noone, function(it) { changeFullscreen(it, 1) }),
    new MenuItem("Master Vol", noone, noone, function(it) { changeMasterVol(it, 1) }),
    new MenuItem("Music Vol", noone, noone, function(it) { changeMusicVol(it, 1) }),
    new MenuItem("Sounds Vol", noone, noone, function(it) { changeSoundsVol(it, 1) }),
    new MenuItem("Language", noone, noone, function(it) { changeLanguage(it, 1) }),
    new MenuItem("Apply", noone, noone, function(it) {
        currentResIndex = selectedResIndex
        currentFullscreen = selectedFullscreen
        global.volMaster = selectedVolMaster
        global.volMusic = selectedVolMusic
        global.volSounds = selectedVolSounds
        applyAudioVolumes()
        
        applyWindowMode(resolutions[currentResIndex][0], resolutions[currentResIndex][1], currentFullscreen)

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
            with(oMainMenu) { visible = true; menuCooldown = 2; if (variable_instance_exists(id, "rebuildMenu")) { rebuildMenu() } }
        }
        if (instance_exists(oPauseMenu)) {
            with(oPauseMenu) { visible = true; menuCooldown = 2; if (variable_instance_exists(id, "rebuildMenu")) { rebuildMenu() } }
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
            with(oMainMenu) { 
                visible = true 
                menuCooldown = 2
                if (variable_instance_exists(id, "rebuildMenu")) {
                    rebuildMenu() 
                }
            }
        }
        if (instance_exists(oPauseMenu)) {
            with(oPauseMenu) { 
                visible = true
                menuCooldown = 2
                if (variable_instance_exists(id, "rebuildMenu")) {
                    rebuildMenu() 
                }
            }
        }
        instance_destroy()
    })
], {
    anchorX: 0.5, startY: 0.2, spacing: 0.075, textH: 0.045, halign: fa_center, buttonW: 0.32, buttonH: 0.065
})

var changeHandlers = [changeResolution, changeFullscreen, changeMasterVol, changeMusicVol, changeSoundsVol, changeLanguage]
for (var handlerIndex = 0; handlerIndex < array_length(changeHandlers); handlerIndex++) {
    menu.items[handlerIndex].onChange = changeHandlers[handlerIndex]
}
for (var buttonIndex = 6; buttonIndex < array_length(menu.items); buttonIndex++) {
    menu.items[buttonIndex].button = true
    menu.items[buttonIndex].gapBefore = (buttonIndex == 6) ? 0.05 : 0.02
}

updateMenuLabels()

mouseLastX = -1
mouseLastY = -1
