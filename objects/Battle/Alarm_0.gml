var currentEnemy = selectedCharacter
if currentEnemy == noone {
    selectedCharacter.energy = 0
    battleState = BattleStates.AfterPlayChecks
    return
}
var cards = currentEnemy.getCardsInHand()
if array_length(cards) == 0 {
    selectedCharacter.energy = 0
    battleState = BattleStates.AfterPlayChecks
    return
}
var cardToPlay = cards[irandom(array_length(cards) - 1)]
var target = heroes[irandom(array_length(heroes) - 1)]
playCard(cardToPlay, currentEnemy, target)