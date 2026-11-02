if (global.gamePaused) { exit } // на паузе камера заморожена

if (instance_exists(oGameController) && instance_exists(oGameController.selected_character)) {
	follow = oGameController.selected_character;
}

if (instance_exists(follow)) {
	xTo = follow.x;
	yTo = follow.y;
}


var followT = 1 - power(1 - 1/CAMERA_FOLLOW_SMOOTHING, delta_time / 1000000 * game_get_speed(gamespeed_fps));
x += (xTo - x) * followT;
y += (yTo - y) * followT;

if (xTo == xToPrev && yTo == yToPrev && point_distance(x, y, xTo, yTo) < 2) {
	x = xTo;
	y = yTo;
}
xToPrev = xTo;
yToPrev = yTo;


x = clamp(x, viewWHalf, room_width-viewWHalf);
y = clamp(y, viewHHalf, room_height-viewHHalf);


camera_set_view_pos(cam, x-viewWHalf, y-viewHHalf);