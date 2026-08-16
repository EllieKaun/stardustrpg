spdWalk = 1
last_v_dir = 1
xPrev = x
yPrev = y

path = path_add()
nSpeed = 1
calcPathDelay = 8
calcPathTimer = 0
distanceToStopFollowing = 24

sprIdle = sViv
sprWalk = sVivWalk

// Движение выбранного персонажа
stepControlled = function() {
    path_end()

    var h = keyboard_check(ord("D")) - keyboard_check(ord("A"))
    var v = keyboard_check(ord("S")) - keyboard_check(ord("W"))
    var mx = h * spdWalk
    var my = v * spdWalk

    if (!place_meeting(x + mx, y, oWall)) { 
        x += mx
    }
    if (!place_meeting(x, y + my, oWall)) { 
        y += my
    }
}

// MP движение невыделенного персонажа
stepFollowing = function() {
    var leader = oGameController.selected_character
    if (!instance_exists(leader)) {
        path_end()
        return
    }

    var dis = point_distance(x, y, leader.x, leader.y)
    if (dis <= distanceToStopFollowing) {
        path_end()
        speed = 0
        return
    }

    // Прямая линия до лидера свободна -> идём напрямую, минуя сетку (без «крюков»)
    if (collision_line(x, y, leader.x, leader.y, oWall, true, true) == noone) {
        path_end()
        move_towards_point(leader.x, leader.y, nSpeed)
        return
    }

    // Иначе обходим препятствия по сетке (пересчёт с задержкой)
    if (calcPathTimer-- <= 0) {
        calcPathTimer = calcPathDelay
        var found = mp_grid_path(global.mpGrid, path, x, y, leader.x, leader.y, true)
        if (found) {
            path_start(path, nSpeed, path_action_stop, false)
        } else {
            path_end()
            move_towards_point(leader.x, leader.y, nSpeed)
        }
    }
}