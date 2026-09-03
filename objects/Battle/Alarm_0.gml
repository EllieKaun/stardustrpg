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

var validCards = []
for (var vi = 0; vi < array_length(cards); vi++) {
    var vc = cards[vi]
    if (is_struct(vc) && variable_struct_exists(vc, "cardBaseSpr") && variable_struct_exists(vc, "effects")) {
        array_push(validCards, vc)
    }
}
cards = validCards
if (array_length(cards) == 0) {
    skipTurn()
    return
}

var aliveHeroes  = filterNotKO(heroes) // противники врага
var aliveEnemies = filterNotKO(enemies) // союзники врага

// Принимаем решение по разыгрыванию карты
var healChoice = noone, buffChoice = noone, attackChoice = noone
for (var i = 0; i < array_length(cards); i++) {
    var c = cards[i]
    switch (cardCategoryOf(c)) {
        case CardCategory.Heal: 
            if (healChoice == noone) healChoice = c
            break
        case CardCategory.Buff: 
            if (buffChoice == noone) buffChoice = c
            break
        case CardCategory.Attack:
        case CardCategory.Magic: 
            if (attackChoice == noone) attackChoice = c
            break
    }
}

// Самый раненый союзник (для хила)
var woundedAlly = noone
var lowestHp = 999999
for (var i = 0; i < array_length(aliveEnemies); i++) {
    var a = aliveEnemies[i]
    if (a.hp < a.maxHp && a.hp < lowestHp) { lowestHp = a.hp; woundedAlly = a }
}

var cardToPlay = noone
var target = noone

// ЕслиЕ есть хил и есть раненый союзник, значит лечим самого раненого
if (healChoice != noone && woundedAlly != noone) {
    target = enemyResolveTarget(healChoice, currentEnemy, aliveHeroes, aliveEnemies, woundedAlly, noone)
    if (target != noone) cardToPlay = healChoice
}

// Если есть бафф и кастер ещё не забаффан этим модификаторо, значит баффаем себя
if (cardToPlay == noone && buffChoice != noone) {
    var alreadyBuffed = false
    var e0 = buffChoice.effects[0]
    if (variable_struct_exists(e0, "buffType"))
        alreadyBuffed = !is_undefined(checkIfHasBuff(currentEnemy, EffectTypes.Buff, e0.buffType))
    if (!alreadyBuffed) {
        target = enemyResolveTarget(buffChoice, currentEnemy, aliveHeroes, aliveEnemies, currentEnemy, noone)
        if (target != noone) cardToPlay = buffChoice
    }
}

// Атакуем
if (cardToPlay == noone && attackChoice != noone) {
    target = enemyResolveTarget(attackChoice, currentEnemy, aliveHeroes, aliveEnemies, noone, noone)
    if (target != noone) cardToPlay = attackChoice
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
