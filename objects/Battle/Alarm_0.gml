// Пауза
if (global.gamePaused) {
    alarm_set(ENEMYS_TURN, 1)
    exit
}

var actor = selectedCharacter 
if (actor == noone) {
    skipTurn()
    return
}

if (array_length(actor.getCardsInHand()) == 0) {
    shuffleDeckAndTake4(actor)
}

var move = chooseMove(actor)
if (move == undefined) {
    shuffleDeckAndTake4(actor)
    move = chooseMove(actor)
}
if (move == undefined) {
    skipTurn()
    return 
}

playCard(move.card, actor, move.target)