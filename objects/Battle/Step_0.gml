
switch (battleState) {
    case BattleStates.Preparing:
        
    break
    case BattleStates.DeckPreparing:
        
    break
    case BattleStates.CharacterPreparing:
        
    break
    case BattleStates.CharacterPlay:
        var enterPressed = keyboard_check_pressed(vk_enter)
        var leftPressed = keyboard_check_pressed(vk_left)
        var rightPressed = keyboard_check_pressed(vk_right)
        var changeIndex = leftPressed - rightPressed
        if changeIndex != 0 { 
            if changeIndex < 0 {
                selectedCard = selectedCard + 1 >= array_length(cards) ? 0 : selectedCard + 1
            } else {
                selectedCard = selectedCard - 1 < 0 ? array_length(cards) - 1 : selectedCard - 1
            }
        }
        if (enterPressed) {
            battleState = BattleStates.PlayProcess
            playCard(selectedCharacter.deck[selectedCard], selectedCharacter, enemies[0])
        }
    break
    case BattleStates.PlayProcess:
    break
    case BattleStates.PlayResult:
        
    break
    case BattleStates.AfterPlayChecks:
        afterPlayChecks()
    break
    case BattleStates.BattleOver:
        
    break
}