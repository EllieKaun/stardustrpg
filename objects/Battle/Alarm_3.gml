// Старт катсцены появления босса
if (bossIntroSprite == undefined || !sprite_exists(bossIntroSprite)) exit
if (battleState == BattleStates.Victory || battleState == BattleStates.GameOver) exit

// Откладываю начало игры
if (battleState == BattleStates.EnemysTurn
    || battleState == BattleStates.PuppetTurn
    || battleState == BattleStates.CardAnimating) {
    alarm[3] = game_get_speed(gamespeed_fps) * 0.5
    exit
}

bossIntroReturnState = battleState
bossIntroFrame = 0
battleState = BattleStates.BossIntro
