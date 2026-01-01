var space = keyboard_check_pressed(vk_space)
if space {
    selectNextCharacter()
}

switch (battleState) {
    case BattleStates.Preparing:
        
    break
    case BattleStates.DeckPreparing:
        
    break
    case BattleStates.CharacterPreparing:
        
    break
    case BattleStates.CharacterPlay:
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