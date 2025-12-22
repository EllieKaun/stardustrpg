if(instance_exists(follow)){
	xTo = follow.x;
	yTo = follow.y;
}


x += (xTo - x) / 15;
y += (yTo - y) / 15;


x = clamp(x, viewWHalf, room_width-viewWHalf);
y = clamp(y, viewHHalf, room_height-viewHHalf);


camera_set_view_pos(cam, x-viewWHalf, y-viewHHalf);