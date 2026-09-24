// Пауза: откладываем срабатывание таймера
if (global.gamePaused) {
    alarm_set(STUN_TURN, 1)
    exit
}
skipTurn() // Конец хода оглушённого персонажа
