if (!instance_exists(leader)) exit;

// ensure history exists
if (!variable_instance_exists(id, "move_history")) {
	move_history = [];
	history_max = 120;
}

// save previous position
var prev_x = x;
var prev_y = y;

// save my own history
array_insert(move_history, 0, { x: x, y: y });
if (array_length(move_history) > history_max) {
	array_resize(move_history, history_max);
}

// follow leader
var history = leader.move_history;

if (array_length(history) > follow_index) {
	var target = history[follow_index];
	x = lerp(x, target.x, 0.25);
	y = lerp(y, target.y, 0.25);
}

// ─────────────────────────
// MOVEMENT CHECK
// ─────────────────────────
var is_moving = (point_distance(x, y, prev_x, prev_y) > 0.1);

// animation switch
if (is_moving) {
	sprite_index = sprite_walk;
	image_speed = 1;
} else {
	image_speed = 1;
	sprite_index = sprite_idle;
}

// facing direction
if (x < leader.x) image_xscale = 1;
if (x > leader.x) image_xscale = -1;
