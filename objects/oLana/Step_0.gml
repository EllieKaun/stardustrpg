var _inputH = keyboard_check(ord("D")) - keyboard_check(ord("A"));
var _inputV =keyboard_check(ord("S")) - keyboard_check(ord("W"));
var _inputD = point_direction(0, 0, _inputH, _inputV);
var _inputM = point_distance(0, 0, _inputH, _inputV);


if(_inputM != 0){
	direction = _inputD;
	sprite_index = sLanaWalk;
}else{
	sprite_index = sLana
}

if (_inputH != 0) {
	image_xscale = sign(_inputH);
}




x += lengthdir_x(spdWalk*_inputM,_inputD);
y += lengthdir_y(spdWalk*_inputM,_inputD);


array_insert(move_history, 0, { x: x, y: y });

if (array_length(move_history) > history_max) {
	array_resize(move_history, history_max);
}

