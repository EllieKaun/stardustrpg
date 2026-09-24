// Пауза: откладываем срабатывание таймера
if (global.gamePaused) {
    alarm_set(HERO_DRAW_DELAY, 1)
    exit
}
if (canDrawCardForTurn(selectedCharacter)) beginDrawCardAnim(selectedCharacter)
else beginTurnFor(selectedCharacter)
