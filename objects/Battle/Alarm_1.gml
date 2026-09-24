// Пауза: откладываем срабатывание таймера
if (global.gamePaused) {
    alarm_set(PUPPET_TURN, 1)
    exit
}
runPuppetTurn(selectedCharacter) // Ход куклы