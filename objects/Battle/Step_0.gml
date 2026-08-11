updateCardAnims() // двигаем/чистим летящие карты в любом состоянии

// ---- Управление мышью (в дополнение к клавиатуре) ---------------------------
// UI боя рисуется прямо в координатах GUI (окна), поэтому мышь берём как есть.
// Хит-боксы карт/меню тоже в оконных координатах. Враги — мировые объекты.
var mbx = device_mouse_x_to_gui(0)
var mby = device_mouse_y_to_gui(0)
var mouseMoved = (mbx != mouseLastX || mby != mouseLastY)
mouseLastX = mbx
mouseLastY = mby
var mClick = mouse_check_button_pressed(mb_left)
var mouseConfirm = false

switch (battleState) {
    case BattleStates.CharacterPlay:
        // карты в руке — сверху вниз по z (последняя нарисованная — верхняя)
        var hoveredCard = -1
        for (var i = array_length(cardHitRects) - 1; i >= 0; i--) {
            var r = cardHitRects[i]
            if (pointInRotatedRect(mbx, mby, r.x, r.y, r.w, r.h, r.angle)) {
                hoveredCard = r.index
                break
            }
        }
        if (hoveredCard >= 0) {
            if (mouseMoved) { focusArea = FocusArea.Deck; selectedCard = hoveredCard }
            if (mClick)     { focusArea = FocusArea.Deck; selectedCard = hoveredCard; mouseConfirm = true }
        } else {
            for (var i = 0; i < array_length(menuHitRects); i++) {
                var r = menuHitRects[i]
                if (pointInRect(mbx, mby, r.x, r.y, r.w, r.h)) {
                    if (mouseMoved) { focusArea = FocusArea.Menu; selectedMenuItem = r.index }
                    if (mClick)     { focusArea = FocusArea.Menu; selectedMenuItem = r.index; mouseConfirm = true }
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
        
        if (focusArea == FocusArea.Deck) { // Переключение стрелками в деке
            if (leftPressed) { 
                if (selectedCard == 0) {
                    focusArea = FocusArea.Menu // Переключение в меню
                    selectedMenuItem = 0
                } else {
                    selectedCard--
                }
            }
            if (rightPressed) {
                if (selectedCard < array_length(selectedCharacter.getCardsInHand()) - 1) {
                    selectedCard++
                }
            }
        } else if (focusArea == FocusArea.Menu) { // Переключение стрелками в меню
            var upPressed = keyboard_check_pressed(vk_up)
            var downPressed = keyboard_check_pressed(vk_down)
            
            if (upPressed) {
                selectedMenuItem = selectedMenuItem - 1 < 0 ? array_length(menuItems) - 1 : selectedMenuItem - 1
            }
            if (downPressed) {
                selectedMenuItem = selectedMenuItem + 1 >= array_length(menuItems) ? 0 : selectedMenuItem + 1
            }
            if (rightPressed) {
                focusArea = FocusArea.Deck // Возвращение в деку
                selectedCard = 0
            }
        }
        if (enterPressed) { // Выбор
            if (focusArea == FocusArea.Menu) { // если меню
                switch (menuItems[selectedMenuItem]) {
                    case "Shuffle": // Перемешать
                        shuffleDeckAndTake4(selectedCharacter) 
                        skipTurn()
                    break
                    case "Run": // Сбежать
                        with (oTransition) {
                            target_room = global.returnRoom
                            state = "fade_out"
                        }
                    break // Информация о врагах
                    case "Info":
                        battleState = BattleStates.EnemyInfoSelection
                        initTargetSelection(enemies)
                    break
                }
            } else if (array_length(selectedCharacter.getCardsInHand()) > 0) {  // Если дека и есть карты в руке
                var currentCard = selectedCharacter.getCardsInHand()[selectedCard] // Текущая карта
                var check = checkIfCanPlayCard(selectedCharacter, currentCard) // Проверка условий, возможно ли сыграть карту
                if !check { return }
                if currentCard.target == TargetTypes.SingleEnemyTarget { // Игровка карты в зависимости от типа карты
                    battleState = BattleStates.EnemyTargetSelection
                    initTargetSelection(enemies)
                } else if currentCard.target == TargetTypes.SingleAllyTarget {
                    battleState = BattleStates.AllyTargetSelection
                    if (cardIsResurrection(currentCard)) initTargetSelectionKO(heroes) // цель — павший
                    else initTargetSelection(heroes)
                } else if currentCard.target == TargetTypes.AllEnemies {
                    playCardAnimated(currentCard, selectedCharacter, enemies)
                } else if currentCard.target == TargetTypes.AllAllies {
                    playCardAnimated(currentCard, selectedCharacter, heroes)
                }
            } else {
                skipTurn() // Если нет карт - пропуск хода
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