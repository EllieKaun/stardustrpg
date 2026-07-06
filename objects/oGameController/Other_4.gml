// Инициализация сетки MP 
var cell = 16
var cols = ceil(room_width  / cell)
var rows = ceil(room_height / cell)

if (global.mpGrid != -1) {
    mp_grid_destroy(global.mpGrid)
}
global.mpGrid = mp_grid_create(0, 0, cols, rows, cell, cell)
mp_grid_add_instances(global.mpGrid, oWall, false)