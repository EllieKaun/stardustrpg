var currentEnemy = selectedCharacter // Ход врага
if currentEnemy == noone { // Если нет выбранного врага - пропускаем ход
    skipTurn() 
    return
}
var cards = currentEnemy.getCardsInHand() // Смотрим карты врага
if array_length(cards) == 0 { // Если карт нет - замешиваем
    shuffleDeckAndTake4(currentEnemy)
    cards = currentEnemy.getCardsInHand()
    if (array_length(cards) == 0) { // Если все еще нет карт, значит кончились или не было - пропускаем ход
        skipTurn()
        return
    }
}
var cardToPlay = cards[irandom(array_length(cards) - 1)] // Выбираем случайную карту для игры
var filteredHeroes = filterNotKO(heroes) // Выбираем героев которые не в нокауте
if array_length(filteredHeroes) == 0 { skipTurn() } // Если их нет - пропускаем ход 
var target = filteredHeroes[irandom(array_length(filteredHeroes) - 1)] // Выбираем случайного героя
playCard(cardToPlay, currentEnemy, target) // Играем карту