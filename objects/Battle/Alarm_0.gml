var currentEnemy = selectedCharacter
if currentEnemy == noone {
    skipTurn()
    return
}
var cards = currentEnemy.getCardsInHand()
if array_length(cards) == 0 {
    shuffleDeckAndTake4(currentEnemy)
    cards = currentEnemy.getCardsInHand()
    if (array_length(cards) == 0) {
        skipTurn()
        return
    }
}
var cardToPlay = cards[irandom(array_length(cards) - 1)]
var target = heroes[irandom(array_length(heroes) - 1)]
playCard(cardToPlay, currentEnemy, target)