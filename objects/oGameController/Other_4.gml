// Инициализация сетки MP 
var cell = 16
var cols = ceil(room_width  / cell)
var rows = ceil(room_height / cell)

if (global.mpGrid != -1) {
    mp_grid_destroy(global.mpGrid)
}
global.mpGrid = mp_grid_create(0, 0, cols, rows, cell, cell)
mp_grid_add_instances(global.mpGrid, oWall, false)

// Возврат из боя: партия остаётся на месте (persistent). Динамического врага,
// с которым дрались, убираем; ручной остаётся (остывает, см. oEnemy).
if (global.returningFromBattle) {
    global.returningFromBattle = false
    if (instance_exists(selected_character)) {
        selected_character.can_move = true
        selected_character.x = global.returnX
        selected_character.y = global.returnY
    }
    if (instance_exists(global.fightEnemy) && global.fightEnemy.spawnedDynamically) {
        instance_destroy(global.fightEnemy)
    }
    global.fightEnemy = noone
}