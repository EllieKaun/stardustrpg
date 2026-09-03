spdWalk = 0.8
last_v_dir = 1
xPrev = x
yPrev = y
can_move = true // false при входе в бой

path = path_add()
nSpeed = 0.8
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

    var obstacles = [oWall, oTree1, oTree2, oTree3, oTree4, oTree5, oStump]
    
    if (!place_meeting(x + mx, y, obstacles)) { 
        x += mx
    }
    if (!place_meeting(x, y + my, obstacles)) { 
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

    var obstacles = [oWall, oTree1, oTree2, oTree3, oTree4, oTree5, oStump]

    // Прямая линия до лидера 
    if (collision_line(x, y, leader.x, leader.y, obstacles, true, true) == noone) {
        path_end()
        move_towards_point(leader.x, leader.y, nSpeed)
        return
    }

    // Иначе обходим препятствия по сетке
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