// Музыка и фоновые звуки

function playMusic(track) {
    if (!variable_global_exists("currentMusic")) global.currentMusic = noone
    if (track < 0) return
    if (global.currentMusic == track && audio_is_playing(track)) return
    if (global.currentMusic >= 0) audio_stop_sound(global.currentMusic)
    global.currentMusic = track
    audio_play_sound(track, 10, true)
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
    audio_play_sound(track, 5, true)
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
    if (SND_CARD_SELECT != noone) audio_play_sound(SND_CARD_SELECT, 8, false)
}

function playCardPlaySound() {
    if (SND_CARD_PLAY != noone) audio_play_sound(SND_CARD_PLAY, 8, false)
}
