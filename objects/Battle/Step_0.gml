// Пауза по Esc (не во время смены комнаты)
var transitioning = instance_exists(oTransition) && oTransition.state != "idle"
if (keyboard_check_pressed(vk_escape) && !transitioning) {
    if (instance_exists(oSettingsMenu)) {
        // Esc обрабатывает само меню настроек
    } else if (instance_exists(oPauseMenu)) {
        // menuCooldown > 0 - только что вернулись из настроек тем же Esc
        if (oPauseMenu.visible && oPauseMenu.menuCooldown <= 0) { with (oPauseMenu) close() }
    } else if (!global.uiModal) {
        instance_create_layer(0, 0, "Instances", oPauseMenu)
    }
}
if (global.gamePaused) { exit } // на паузе бой полностью заморожен

autosaveUpdate()
updateCardAnims() // Анимации карт

// ВЫполнение очереди из действий
for (var action = array_length(actionsQueue) - 1; action >= 0; action--) {
    actionsQueue[action].update()
    if (!actionsQueue[action].isRunning()) {
        array_delete(actionsQueue, action, 1)
    }
}

// Управление мышью
var mouseGuiX = device_mouse_x_to_gui(0)
var mouseGuiY = device_mouse_y_to_gui(0)
var mouseMoved = (mouseGuiX != mouseLastX || mouseGuiY != mouseLastY)
mouseLastX = mouseGuiX
mouseLastY = mouseGuiY
var mouseClicked = mouse_check_button_pressed(mb_left)

if (tutorialActive) {
    if (battleState == BattleStates.Victory || battleState == BattleStates.GameOver) {
        tutorialActive = false
        markTutorialDone()
    } else if (battleState == BattleStates.CharacterPlay) {
        if (tutorial.step()) {
            tutorialActive = false
            markTutorialDone()
        }
        exit
    }
}

var currentState = stateAt(battleState)
var stepHook = (currentState != undefined) ? currentState[StateHook.Step] : undefined
if (stepHook != undefined) {
    var input = { guiX: mouseGuiX, guiY: mouseGuiY, moved: mouseMoved, clicked: mouseClicked }
    var onCancel = currentState[StateHook.OnCancel]
    if (onCancel != undefined && wantsCancel(input)) { onCancel() }
    else { stepHook(input) }
}
