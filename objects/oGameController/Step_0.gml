displayRecoverOnFocus()
autosaveUpdate()
updateTimeOfDay()

// Анимации входа в бой
if (battleEntryState == BattleEntryState.Leaving) { exit }
if (battleEntryState != BattleEntryState.Idle) {
    entryAnimFrame += entryAnimFramesPerStep(entryAnimSprite)
    if (entryAnimFrame >= sprite_get_number(entryAnimSprite)) {
        if (battleEntryState == BattleEntryState.Transition) {
            goToBattleAfterTransition()
        } else if (battleStartSprite() != noone) {
            changeBattleEntryState(BattleEntryState.Transition)
        } else {
            startFadeToBattle()
        }
    }
    exit
}

if (variable_global_exists("introPendingWalk") && global.introPendingWalk) {
    if (!instance_exists(oDialogManager) || !oDialogManager.active) {
        global.introPendingWalk = false
        startTutorialIntro()
    }
}

if (global.deckTutorialStage == DeckTutorialStage.Dialog) {
    if (!instance_exists(oDialogManager) || !oDialogManager.active) {
        global.deckTutorialStage = DeckTutorialStage.AwaitOpen
    }
} else if (global.deckTutorialStage == DeckTutorialStage.AwaitOpen) {
    if (instance_exists(oDeckBuilder) && oDeckBuilder.open) {
        global.deckTutorialStage = DeckTutorialStage.Steps
    }
}

// F11 - на весь экран
if (keyboard_check_pressed(vk_f11)) {
    setDisplayMode(!global.displayFullscreen)
}

// Esc - закрыть открытое окно (декбилдер/магазин), иначе переключатель паузы
if (keyboard_check_pressed(vk_escape)) {
    if (instance_exists(oDeckBuilder) && oDeckBuilder.open) {
        oDeckBuilder.closeBuilder()
    } else if (instance_exists(oShop) && oShop.open) {
        oShop.closeShop()
    } else if (instance_exists(oPauseMenu)) {
        with (oPauseMenu) close()
    } else if (!global.uiModal) {
        instance_create_layer(0, 0, "Instances", oPauseMenu)
    }
}

// Открыть/закрыть декбилдер 
if (keyboard_check_pressed(vk_tab) && instance_exists(oDeckBuilder)) {
    if (oDeckBuilder.open) {
        oDeckBuilder.closeBuilder()
    } else if (!global.uiModal) { // не открываем поверх паузы/диалога
        oDeckBuilder.openBuilder()
    }
//    say([
//    dialogLine("Lana", portraitLana,
//        "Hey hey"),
//    dialogLine("Viv", portraitViv,
//        "Yeh yeh")
//], function() {
//    show_debug_message("dialog finished")
//})
}
if (keyboard_check_pressed(ord("I")) && instance_exists(oShop) && oShop.open) {
    oShop.closeShop()
}

if (keyboard_check_pressed(vk_lcontrol)) {
    switchCharacter()
}

updateDayNightMusic()