var currentEnemy = selectedCharacter // Ход врага
if currentEnemy == noone { // Если нет выбранного врага - пропускаем ход
    skipTurn()
    return
}
var cards = currentEnemy.getCardsInHand() // Смотрим карты врага
if array_length(cards) == 0 { // Если карт нет - замешиваем
    shuffleDeckAndTake4(currentEnemy)
    cards = currentEnemy.getCardsInHand()
    if (array_length(cards) == 0) { // Если все еще нет карт - пропускаем ход
        skipTurn()
        return
    }
}

var cardToPlay = cards[irandom(array_length(cards) - 1)] // Случайная карта для игры

// Цель резолвится ОТНОСИТЕЛЬНО врага: его «враги» = герои, его «союзники» = враги.
// (Раньше враг всегда целился в героя, поэтому баффал/лечил игрока.)
var aliveHeroes  = filterNotKO(heroes)
var aliveEnemies = filterNotKO(enemies)
var target = noone

switch (cardToPlay.target) {
    case TargetTypes.SingleEnemyTarget: // атака/дебафф по герою
        if (array_length(aliveHeroes) == 0) { skipTurn(); return }
        target = aliveHeroes[irandom(array_length(aliveHeroes) - 1)]
    break
    case TargetTypes.AllEnemies:
        if (array_length(aliveHeroes) == 0) { skipTurn(); return }
        target = aliveHeroes
    break
    case TargetTypes.SingleAllyTarget: // бафф/хил по своему союзнику-врагу
        if (array_length(aliveEnemies) == 0) { skipTurn(); return }
        target = aliveEnemies[irandom(array_length(aliveEnemies) - 1)]
    break
    case TargetTypes.AllAllies:
        if (array_length(aliveEnemies) == 0) { skipTurn(); return }
        target = aliveEnemies
    break
    case TargetTypes.Self:
        target = currentEnemy
    break
    default:
        if (array_length(aliveHeroes) == 0) { skipTurn(); return }
        target = aliveHeroes[irandom(array_length(aliveHeroes) - 1)]
    break
}

playCard(cardToPlay, currentEnemy, target) // Играем карту
