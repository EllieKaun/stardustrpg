function initAudioVolumes() {
    // Читаем настройки громкости из файла. Если файла или записей нет, берутся значения по умолчанию
    ini_open("settings.ini")
    global.volMaster = ini_read_real("Audio", "Master", 1.0) // Общая громкость
    global.volMusic = ini_read_real("Audio", "Music", 0.8)   // Громкость музыки
    global.volSounds = ini_read_real("Audio", "Sounds", 1.0) // Громкость эффектов
    ini_close()
    
    // Сразу применяем настройки к игре
    applyAudioVolumes()
}

function applyAudioVolumes() {
    // Устанавливаем общую (мастер) громкость, которая умножается на громкость любого звука
    audio_master_gain(global.volMaster)
    
    // Для зацикленных звуков (музыка и окружение) применяем громкость напрямую к ассету.
    // Это мгновенно изменит громкость уже играющего звука и применится к его будущим запускам.
    if (variable_global_exists("currentMusic") && global.currentMusic != noone) {
        audio_sound_gain(global.currentMusic, global.volMusic, 0)
    }
    if (variable_global_exists("currentAmbient") && global.currentAmbient != noone) {
        audio_sound_gain(global.currentAmbient, global.volSounds, 0)
    }
}

function playSfx(track, prio, loop) {
    if (track == noone || track < 0) { return noone; }
    var sound = audio_play_sound(track, prio, loop)
    audio_sound_gain(sound, global.volSounds, 0)
    return sound
}

// Музыка и фоновые звуки

// currentMusic — id звука (инстанса), currentMusicAsset — id ассета (какой трек играет)
function ensureMusicState() {
    if (!variable_global_exists("currentMusic")) { global.currentMusic = noone }
    if (!variable_global_exists("currentMusicAsset")) { global.currentMusicAsset = noone }
    if (!variable_global_exists("musicFadingOut")) { global.musicFadingOut = [] }
}

function playMusic(track) {
    ensureMusicState()
    if (track < 0) { return }
    if (global.currentMusicAsset == track && audio_is_playing(global.currentMusic)) { return }
    if (global.currentMusic != noone && global.currentMusic >= 0) { audio_stop_sound(global.currentMusic) }
    var sound = audio_play_sound(track, 10, true)
    audio_sound_gain(sound, global.volMusic, 0)
    global.currentMusic = sound
    global.currentMusicAsset = track
}

function stopMusic() {
    ensureMusicState()
    if (global.currentMusic != noone && global.currentMusic >= 0) { audio_stop_sound(global.currentMusic) }
    global.currentMusic = noone
    global.currentMusicAsset = noone
}

function playAmbient(track) {
    if (!variable_global_exists("currentAmbient")) { global.currentAmbient = noone }
    if (track < 0) { return }
    if (global.currentAmbient == track && audio_is_playing(track)) { return }
    if (global.currentAmbient >= 0) { audio_stop_sound(global.currentAmbient) }
    global.currentAmbient = track
    var sound = audio_play_sound(track, 5, true)
    audio_sound_gain(sound, global.volSounds, 0)
}

function stopAmbient() {
    if (!variable_global_exists("currentAmbient")) { 
        global.currentAmbient = noone
        return 
    }
    if (global.currentAmbient >= 0) { audio_stop_sound(global.currentAmbient) }
    global.currentAmbient = noone
}

function playMusicNamed(name) {
    playMusic(asset_get_index(name))
}
function playAmbientNamed(name) {
    playAmbient(asset_get_index(name))
}

#macro SND_CARD_SELECT CardSelect // смена выбранной карты 
#macro SND_CARD_PLAY CardFly // начало розыгрыша карты
#macro SND_CHEST_OPEN sndChestOpen // открытие сундука

function playCardSelectSound() {
    playSfx(SND_CARD_SELECT, 8, false)
}

function playCardPlaySound() {
    playSfx(SND_CARD_PLAY, 8, false)
}

function playChestOpenSound() {
    playSfx(SND_CHEST_OPEN, 8, false)
}


function crossfadeMusic(track, fadeMs = 1500) {
    ensureMusicState()
    if (track < 0) { return }
    if (global.currentMusicAsset == track && audio_is_playing(global.currentMusic)) { return }

    if (global.currentMusic != noone && global.currentMusic >= 0 && audio_is_playing(global.currentMusic)) {
        audio_sound_gain(global.currentMusic, 0, fadeMs)
        var stopFrames = ceil(fadeMs / 1000 * game_get_speed(gamespeed_fps)) + 2
        array_push(global.musicFadingOut, { sound: global.currentMusic, framesLeft: stopFrames })
    }

    var sound = audio_play_sound(track, 10, true)
    audio_sound_gain(sound, 0, 0)
    audio_sound_gain(sound, global.volMusic, fadeMs)
    global.currentMusic = sound
    global.currentMusicAsset = track
}

function updateMusicFades() {
    ensureMusicState()
    for (var fadeIndex = array_length(global.musicFadingOut) - 1; fadeIndex >= 0; fadeIndex--) {
        var fade = global.musicFadingOut[fadeIndex]
        fade.framesLeft -= 1
        if (fade.framesLeft <= 0) {
            if (audio_is_playing(fade.sound)) { audio_stop_sound(fade.sound) }
            array_delete(global.musicFadingOut, fadeIndex, 1)
        }
    }
}

// Трек по времени суток
function musicTrackForTime() {
    return (nightValue() >= 0.5) ? asset_get_index("ForestNightMusic") : asset_get_index("ForestDayMusic")
}

function syncMusicToTime() {
    global.musicIsNight = (nightValue() >= 0.5)
    crossfadeMusic(musicTrackForTime(), 0)
}

function updateDayNightMusic() {
    updateMusicFades()
    var night = nightValue()
    if (!variable_global_exists("musicIsNight")) { global.musicIsNight = (night >= 0.5) }
   
    if (!global.musicIsNight && night > 0.6) {
        global.musicIsNight = true
        crossfadeMusic(asset_get_index("ForestNightMusic"))
    } else if (global.musicIsNight && night < 0.4) {
        global.musicIsNight = false
        crossfadeMusic(asset_get_index("ForestDayMusic"))
    }
}