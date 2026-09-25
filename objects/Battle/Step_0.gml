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
var mouseConfirm = false

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

switch (battleState) {
    case BattleStates.CharacterPlay:
        var hoveredCard = -1
        for (var i = array_length(cardHitRects) - 1; i >= 0; i--) {
            var hitRect = cardHitRects[i]
            if (pointInRotatedRect(mouseGuiX, mouseGuiY, hitRect.x, hitRect.y, hitRect.w, hitRect.h, hitRect.angle)) {
                hoveredCard = hitRect.index
                break
            }
        }
        if (hoveredCard >= 0) {
            if (mouseMoved) {
                focusArea = FocusArea.Deck
                if (selectedCard != hoveredCard) { playCardSelectSound() }
                selectedCard = hoveredCard
            }
            if (mouseClicked)     { focusArea = FocusArea.Deck; selectedCard = hoveredCard; mouseConfirm = true }
        } else {
            for (var i = 0; i < array_length(menuHitRects); i++) {
                var hitRect = menuHitRects[i]
                if (pointInRect(mouseGuiX, mouseGuiY, hitRect.x, hitRect.y, hitRect.w, hitRect.h)) {
                    if (mouseClicked) { doMenuAction(hitRect.name) }
                    break
                }
            }
        }
    break

    case BattleStates.EnemyTargetSelection:
    case BattleStates.AllyTargetSelection:
    case BattleStates.EnemyInfoSelection:
        if (mouseMoved || mouseClicked) {
            var overTarget = selectTargetAtMouse()
            if (mouseClicked && overTarget) { mouseConfirm = true }
        }
    break

    case BattleStates.EnemyInfoDisplay:
        if (mouseClicked && infoCloseRect != undefined
            && pointInRect(mouseGuiX, mouseGuiY, infoCloseRect.x, infoCloseRect.y, infoCloseRect.w, infoCloseRect.h)) {
            mouseConfirm = true
            }
    break
}

// Отмена выбранной карты
var cancelClicked = (mouseClicked && cancelHitRect != undefined
    && pointInRect(mouseGuiX, mouseGuiY, cancelHitRect.x, cancelHitRect.y, cancelHitRect.w, cancelHitRect.h))
var cancelPressed = mouse_check_button_pressed(mb_right) || keyboard_check_pressed(ord("C")) || cancelClicked
if (cancelPressed
    && (battleState == BattleStates.EnemyTargetSelection
     || battleState == BattleStates.AllyTargetSelection
     || battleState == BattleStates.EnemyInfoSelection
     || battleState == BattleStates.EnemyInfoDisplay)) {
    changeBattleState(BattleStates.CharacterPlay)
    unselectTargets()
    restoreSelection()
    mouseConfirm = false
}

switch (battleState) {
    case BattleStates.Victory:
        stepVictoryScreen() // Обработка действия на экране победы
        exit
    case BattleStates.GameOver: 
        stepGameOverScreen() // Обработка действия на экране поражения
        exit
    case BattleStates.Preparing:
        
    break
    case BattleStates.DeckPreparing:
        
    break
    case BattleStates.CharacterPreparing:
        
    break
    case BattleStates.EnemyTargetSelection:
    case BattleStates.AllyTargetSelection:
        var enterPressed = keyboard_check_pressed(vk_enter) || mouseConfirm
        var leftPressed = keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))
        var rightPressed = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))
        var changeIndex = leftPressed - rightPressed
        if changeIndex != 0 {
            if changeIndex < 0 {
                selectNextTarget()
            } else {
                selectPreviousTarget()
            }
        }
        if (enterPressed) {
            changeBattleState(BattleStates.PlayProcess)
            unselectTargets()
            var currentCard = selectedCharacter.getCardsInHand()[selectedCard]
            playCardAnimated(currentCard, selectedCharacter, selectedTarget)
        }
    break
    case BattleStates.CharacterPlay: // Переключение стрелками между режимами: дека или меню, а также переключение между картами и опциями
        var enterPressed = keyboard_check_pressed(vk_enter) || mouseConfirm
        var leftPressed = keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))
        var rightPressed = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))

        if (keyboard_check_pressed(ord("R"))) { 
            doMenuAction("Run")
            break 
        }
        if (keyboard_check_pressed(ord("S"))) { 
            doMenuAction("Shuffle") 
            break 
        }
        if (keyboard_check_pressed(ord("I"))) { 
            doMenuAction("Info") 
            break 
        }

        var handLen = array_length(selectedCharacter.getCardsInHand())
        if (leftPressed && selectedCard > 0) {
            selectedCard--
            playCardSelectSound() 
        }
        if (rightPressed && selectedCard < handLen - 1) { 
            selectedCard++
            playCardSelectSound() 
        }

        if (enterPressed) {
            if (handLen > 0) {
                var currentCard = selectedCharacter.getCardsInHand()[selectedCard]
                var check = checkIfCanPlayCard(selectedCharacter, currentCard)
                if !check { return }
                if currentCard.target == TargetTypes.SingleEnemyTarget {
                    changeBattleState(BattleStates.EnemyTargetSelection)
                } else if currentCard.target == TargetTypes.SingleAllyTarget {
                    changeBattleState(BattleStates.AllyTargetSelection)
                    if (cardIsResurrection(currentCard)) { initTargetSelectionKO(heroes) }
                    else { initTargetSelection(heroes) }
                } else if currentCard.target == TargetTypes.AllEnemies {
                    playCardAnimated(currentCard, selectedCharacter, enemies)
                } else if currentCard.target == TargetTypes.AllAllies {
                    playCardAnimated(currentCard, selectedCharacter, heroes)
                } else if currentCard.target == TargetTypes.Self {
                  
                    playCardAnimated(currentCard, selectedCharacter, selectedCharacter)
                }
            } else {
                skipTurn()
            }
        }
    break
    case BattleStates.EnemyInfoSelection: // Менюшка выбора секции информации о враге
        var enterPressed = keyboard_check_pressed(vk_enter) || mouseConfirm
        var leftPressed = keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))
        var rightPressed = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))
        if (leftPressed) { selectPreviousTarget() }
        if (rightPressed) { selectNextTarget() }
        
        if (enterPressed) {
            changeBattleState(BattleStates.EnemyInfoDisplay) // Отображение конкретной информации
        }
    break
    case BattleStates.EnemyInfoDisplay: // Менюшка информации о враге
        var enterPressed = keyboard_check_pressed(vk_enter) || mouseConfirm
        if (enterPressed) {
            changeBattleState(BattleStates.CharacterPlay)
            unselectTargets()
            restoreSelection()
        }
    break
    case BattleStates.PlayProcess:
    break
    case BattleStates.CardAnimating: // Карта летит и ввод заблокирован
    break
    case BattleStates.PlayResult:
        
    break
    case BattleStates.AfterPlayChecks:
        
    break
    case BattleStates.BattleOver:

    break
}
