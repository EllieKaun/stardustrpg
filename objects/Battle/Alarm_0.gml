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
var filteredHeroes = filterNotKO(heroes)
if array_length(filteredHeroes) == 0 { skipTurn() }
var target = filteredHeroes[irandom(array_length(filteredHeroes) - 1)]
playCard(cardToPlay, currentEnemy, target)