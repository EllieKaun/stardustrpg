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

introSpeed = 0.9

stepScriptedApproach = function() {
    path_end()
    if (!instance_exists(global.introTarget)) {
        global.introWalk = false
        return
    }
    var obstacles = worldObstacles()
    var stepX = clamp(global.introTarget.x - x, -introSpeed, introSpeed)
    var stepY = clamp(global.introTarget.y - y, -introSpeed, introSpeed)
    if (!place_meeting(x + stepX, y, obstacles)) x += stepX
    if (!place_meeting(x, y + stepY, obstacles)) y += stepY
}

// Движение выбранного персонажа
stepControlled = function() {
    path_end()

    var h = (keyboard_check(ord("D")) || keyboard_check(vk_right)) - (keyboard_check(ord("A")) || keyboard_check(vk_left))
    var v = (keyboard_check(ord("S")) || keyboard_check(vk_down)) - (keyboard_check(ord("W")) || keyboard_check(vk_up))
    var mx = h * spdWalk
    var my = v * spdWalk

    var obstacles = worldObstacles()
    
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

    var obstacles = worldObstacles()

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