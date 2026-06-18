
if (battleState == BattleStates.Victory)  { 
    stepVictoryScreen()
    exit
}
if (battleState == BattleStates.GameOver) { 
    
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
        var enterPressed = keyboard_check_pressed(vk_enter)
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
            playCard(currentCard, selectedCharacter, selectedTarget)
        }
    break    
    case BattleStates.AllyTargetSelection: // Выбрать цель для карты: Союзник
        var enterPressed = keyboard_check_pressed(vk_enter)
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
            playCard(currentCard, selectedCharacter, selectedTarget)
        }
    break 
    case BattleStates.CharacterPlay: // Переключение стрелками между режимами: дека или меню, а также переключение между картами и опциями
        var enterPressed = keyboard_check_pressed(vk_enter)
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
                    initTargetSelection(heroes)
                } else if currentCard.target == TargetTypes.AllEnemies {
                    battleState = BattleStates.PlayProcess
                    playCard(currentCard, selectedCharacter, enemies)
                } else if currentCard.target == TargetTypes.AllAllies {
                    battleState = BattleStates.PlayProcess
                    playCard(currentCard, selectedCharacter, heroes)
                } 
            } else {
                skipTurn() // Если нет карт - пропуск хода
            }
        }
    break
    case BattleStates.EnemyInfoSelection: // Менюшка выбора секции информации о враге
        var enterPressed = keyboard_check_pressed(vk_enter)
        var leftPressed = keyboard_check_pressed(vk_left)
        var rightPressed = keyboard_check_pressed(vk_right)
        if (leftPressed) selectPreviousTarget()
        if (rightPressed) selectNextTarget()
        
        if (enterPressed) {
            battleState = BattleStates.EnemyInfoDisplay // Отображение конкретной информации
        }
    break
    case BattleStates.EnemyInfoDisplay: // Менюшка информации о враге
        var enterPressed = keyboard_check_pressed(vk_enter)
        if (enterPressed) {
            battleState = BattleStates.CharacterPlay
            unselectTargets()
            restoreSelection()
        }
    break
    case BattleStates.PlayProcess:
    break
    case BattleStates.PlayResult:
        
    break
    case BattleStates.AfterPlayChecks:
        
    break
    case BattleStates.BattleOver:
        
    break
}