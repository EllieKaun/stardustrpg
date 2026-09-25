// Пауза: откладываем срабатывание таймера
if (global.gamePaused) {
    alarm_set(ENEMYS_TURN, 1)
    exit
}
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

// Только карты, которые сейчас можно сыграть
var validCards = enemyPlayableCards(currentEnemy, cards)
if (array_length(validCards) == 0) {
    // если нечего сыграть - перемешиваем
    shuffleDeckAndTake4(currentEnemy)
    validCards = enemyPlayableCards(currentEnemy, currentEnemy.getCardsInHand())
}
cards = validCards
if (array_length(cards) == 0) {
    skipTurn()
    return
}

var aliveHeroes = filterNotKO(heroes) // противники врага
var aliveEnemies = filterNotKO(enemies) // союзники врага

// Принимаем решение по разыгрыванию карты
var healChoice = noone, buffChoice = noone, attackChoice = noone
for (var i = 0; i < array_length(cards); i++) {
    var card = cards[i]
    switch (cardCategoryOf(card)) {
        case CardCategory.Heal: 
            if (healChoice == noone) { healChoice = card }
            break
        case CardCategory.Buff: 
            if (buffChoice == noone) { buffChoice = card }
            break
        case CardCategory.Attack:
        case CardCategory.Magic: 
            if (attackChoice == noone) { attackChoice = card }
            break
    }
}

// Самый раненый союзник (для хила)
var woundedAlly = noone
var lowestHp = 999999
for (var i = 0; i < array_length(aliveEnemies); i++) {
    var enemy = aliveEnemies[i]
    if (enemy.hp < enemy.maxHp && enemy.hp < lowestHp) { lowestHp = enemy.hp; woundedAlly = enemy }
}

var cardToPlay = noone
var target = noone

// Если есть хил и есть раненый союзник, значит лечим самого раненого
if (healChoice != noone && woundedAlly != noone) {
    target = enemyResolveTarget(healChoice, currentEnemy, aliveHeroes, aliveEnemies, woundedAlly, noone)
    if (target != noone) { cardToPlay = healChoice }
}

// Если есть бафф и кастер ещё не забаффан этим модификатором, баффаем себя - но только в 50% случаев
if (cardToPlay == noone && buffChoice != noone && irandom(1) == 0) {
    var alreadyBuffed = false
    var firstEffect = buffChoice.effects[0]
    if (variable_struct_exists(firstEffect, "buffType")) {
        alreadyBuffed = !is_undefined(checkIfHasBuff(currentEnemy, EffectTypes.Buff, firstEffect.buffType))
    }
    if (!alreadyBuffed) {
        target = enemyResolveTarget(buffChoice, currentEnemy, aliveHeroes, aliveEnemies, currentEnemy, noone)
        if (target != noone) { cardToPlay = buffChoice }
    }
}

// Атакуем
if (cardToPlay == noone && attackChoice != noone) {
    target = enemyResolveTarget(attackChoice, currentEnemy, aliveHeroes, aliveEnemies, noone, noone)
    if (target != noone) { cardToPlay = attackChoice }
}

// Если ничего не выполнилось, случайная карта из руки
if (cardToPlay == noone) {
    cardToPlay = cards[irandom(array_length(cards) - 1)]
    target = enemyResolveTarget(cardToPlay, currentEnemy, aliveHeroes, aliveEnemies, woundedAlly, noone)
    if (target == noone) {
        skipTurn()
        return
    }
}

playCard(cardToPlay, currentEnemy, target) // Играем карту
