

var _inputH = keyboard_check(ord("D")) - keyboard_check(ord("A"));
var _inputV = keyboard_check(ord("S")) - keyboard_check(ord("W"));

var _inputD = point_direction(0, 0, _inputH, _inputV);
var _inputM = point_distance(0, 0, _inputH, _inputV);

// Animation
if (_inputM != 0) {
    direction = _inputD;
    sprite_index = sLanaWalk;
} else {
    sprite_index = sLana;
}

if (_inputH != 0) {
    image_xscale = sign(_inputH);
}

// ───── MOVE X ─────
var mx = lengthdir_x(spdWalk * _inputM, _inputD);

if (!place_meeting(x + mx, y, oWall)) {
    x += mx;
}

// ───── MOVE Y ─────
var my = lengthdir_y(spdWalk * _inputM, _inputD);

if (!place_meeting(x, y + my, oWall)) {
    y += my;
}

// ───── SAVE HISTORY ─────
array_insert(move_history, 0, { x: x, y: y });

if (array_length(move_history) > history_max) {
    array_resize(move_history, history_max);
}
