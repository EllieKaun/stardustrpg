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
    if (track == noone || track < 0) return noone;
    var snd = audio_play_sound(track, prio, loop)
    audio_sound_gain(snd, global.volSounds, 0)
    return snd
}

// Музыка и фоновые звуки

function playMusic(track) {
    if (!variable_global_exists("currentMusic")) global.currentMusic = noone
    if (track < 0) return
    if (global.currentMusic == track && audio_is_playing(track)) return
    if (global.currentMusic >= 0) audio_stop_sound(global.currentMusic)
    global.currentMusic = track
    var snd = audio_play_sound(track, 10, true)
    audio_sound_gain(snd, global.volMusic, 0)
}

function stopMusic() {
    if (!variable_global_exists("currentMusic")) { 
        global.currentMusic = noone
        return 
    }
    if (global.currentMusic >= 0) audio_stop_sound(global.currentMusic)
    global.currentMusic = noone
}

function playAmbient(track) {
    if (!variable_global_exists("currentAmbient")) global.currentAmbient = noone
    if (track < 0) return
    if (global.currentAmbient == track && audio_is_playing(track)) return
    if (global.currentAmbient >= 0) audio_stop_sound(global.currentAmbient)
    global.currentAmbient = track
    var snd = audio_play_sound(track, 5, true)
    audio_sound_gain(snd, global.volSounds, 0)
}

function stopAmbient() {
    if (!variable_global_exists("currentAmbient")) { 
        global.currentAmbient = noone
        return 
    }
    if (global.currentAmbient >= 0) audio_stop_sound(global.currentAmbient)
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

function playCardSelectSound() {
    playSfx(SND_CARD_SELECT, 8, false)
}

function playCardPlaySound() {
    playSfx(SND_CARD_PLAY, 8, false)
}
