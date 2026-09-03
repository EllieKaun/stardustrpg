updateCardAnims() // Анимации карт

// Управление мышью 
var mbx = device_mouse_x_to_gui(0)
var mby = device_mouse_y_to_gui(0)
var mouseMoved = (mbx != mouseLastX || mby != mouseLastY)
mouseLastX = mbx
mouseLastY = mby
var mClick = mouse_check_button_pressed(mb_left)
var mouseConfirm = false

switch (battleState) {
    case BattleStates.CharacterPlay:
        var hoveredCard = -1
        for (var i = array_length(cardHitRects) - 1; i >= 0; i--) {
            var r = cardHitRects[i]
            if (pointInRotatedRect(mbx, mby, r.x, r.y, r.w, r.h, r.angle)) {
                hoveredCard = r.index
                break
            }
        }
        if (hoveredCard >= 0) {
            if (mouseMoved) {
                focusArea = FocusArea.Deck
                if (selectedCard != hoveredCard) playCardSelectSound()
                selectedCard = hoveredCard
            }
            if (mClick)     { focusArea = FocusArea.Deck; selectedCard = hoveredCard; mouseConfirm = true }
        } else {
            for (var i = 0; i < array_length(menuHitRects); i++) {
                var r = menuHitRects[i]
                if (pointInRect(mbx, mby, r.x, r.y, r.w, r.h)) {
                    if (mClick) doMenuAction(r.name)
                    break
                }
            }
        }
    break

    case BattleStates.EnemyTargetSelection:
    case BattleStates.AllyTargetSelection:
    case BattleStates.EnemyInfoSelection:
        if (mouseMoved || mClick) {
            var overTarget = selectTargetAtMouse()
            if (mClick && overTarget) mouseConfirm = true
        }
    break

    case BattleStates.EnemyInfoDisplay:
        if (mClick && infoCloseRect != undefined
            && pointInRect(mbx, mby, infoCloseRect.x, infoCloseRect.y, infoCloseRect.w, infoCloseRect.h))
            mouseConfirm = true
    break
}

// Отмена выбранной карты
var cancelPressed = mouse_check_button_pressed(mb_right) || keyboard_check_pressed(ord("C"))
if (cancelPressed
    && (battleState == BattleStates.EnemyTargetSelection
     || battleState == BattleStates.AllyTargetSelection
     || battleState == BattleStates.EnemyInfoSelection
     || battleState == BattleStates.EnemyInfoDisplay)) {
    battleState = BattleStates.CharacterPlay
    unselectTargets()
    restoreSelection()
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
    case BattleStates.EnemyTargetSelection: // Выбрать цель для карты: Противник
        var enterPressed = keyboard_check_pressed(vk_enter) || mouseConfirm
        var leftPressed = keyboard_check_pressed(vk_left)
        var rightPressed = keyboard_check_pressed(vk_right)
        var changeIndex = leftPressed - rightPressed
        if changeIndex != 0 { 
            if changeIndex < 0 {
                selectNextTarget()
            } else {
                selectPreviousTarget()
            }
        }
        if (enterPressed) { // Когда выбрали - энтер и продолжаем игровой процесс
            battleState = BattleStates.PlayProcess
            unselectTargets()
            var currentCard = selectedCharacter.getCardsInHand()[selectedCard]
            playCardAnimated(currentCard, selectedCharacter, selectedTarget)
        }
    break    
    case BattleStates.AllyTargetSelection: // Выбрать цель для карты: Союзник
        var enterPressed = keyboard_check_pressed(vk_enter) || mouseConfirm
        var leftPressed = keyboard_check_pressed(vk_left)
        var rightPressed = keyboard_check_pressed(vk_right)
        var changeIndex = leftPressed - rightPressed
        if changeIndex != 0 { 
            if changeIndex < 0 {
                selectNextTarget()
            } else {
                selectPreviousTarget()
            }
        }
        if (enterPressed) { // Когда выбрали - энтер и продолжаем игровой процесс
            battleState = BattleStates.PlayProcess
            unselectTargets()
            var currentCard = selectedCharacter.getCardsInHand()[selectedCard]
            playCardAnimated(currentCard, selectedCharacter, selectedTarget)
        }
    break 
    case BattleStates.CharacterPlay: // Переключение стрелками между режимами: дека или меню, а также переключение между картами и опциями
        var enterPressed = keyboard_check_pressed(vk_enter) || mouseConfirm
        var leftPressed = keyboard_check_pressed(vk_left)
        var rightPressed = keyboard_check_pressed(vk_right)

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
                    battleState = BattleStates.EnemyTargetSelection
                    initTargetSelection(enemies)
                } else if currentCard.target == TargetTypes.SingleAllyTarget {
                    battleState = BattleStates.AllyTargetSelection
                    if (cardIsResurrection(currentCard)) initTargetSelectionKO(heroes)
                    else initTargetSelection(heroes)
                } else if currentCard.target == TargetTypes.AllEnemies {
                    playCardAnimated(currentCard, selectedCharacter, enemies)
                } else if currentCard.target == TargetTypes.AllAllies {
                    playCardAnimated(currentCard, selectedCharacter, heroes)
                }
            } else {
                skipTurn()
            }
        }
    break
    case BattleStates.EnemyInfoSelection: // Менюшка выбора секции информации о враге
        var enterPressed = keyboard_check_pressed(vk_enter) || mouseConfirm
        var leftPressed = keyboard_check_pressed(vk_left)
        var rightPressed = keyboard_check_pressed(vk_right)
        if (leftPressed) selectPreviousTarget()
        if (rightPressed) selectNextTarget()
        
        if (enterPressed) {
            battleState = BattleStates.EnemyInfoDisplay // Отображение конкретной информации
        }
    break
    case BattleStates.EnemyInfoDisplay: // Менюшка информации о враге
        var enterPressed = keyboard_check_pressed(vk_enter) || mouseConfirm
        if (enterPressed) {
            battleState = BattleStates.CharacterPlay
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

// Танец простоя 
if (battleState == BattleStates.CharacterPlay && instance_exists(selectedCharacter)) {
    if (mClick || keyboard_check_pressed(vk_anykey)) {
        idleDanceTimer = 0
        if (selectedCharacter.actionState == StarriorStates.Dance) {
            selectedCharacter.changeActionState(StarriorStates.Idle, undefined)
        }
    } else {
        idleDanceTimer += 1
        if (idleDanceTimer >= 5 * game_get_speed(gamespeed_fps)
            && selectedCharacter.spriteActionDance != noone
            && selectedCharacter.actionState == StarriorStates.Idle) {
            selectedCharacter.changeActionState(StarriorStates.Dance, undefined)
        }
    }
} else {
    if (instance_exists(selectedCharacter) && selectedCharacter.actionState == StarriorStates.Dance) {
        selectedCharacter.changeActionState(StarriorStates.Idle, undefined)
    }
    idleDanceTimer = 0
}