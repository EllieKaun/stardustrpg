var cam = view_camera[0];

var view_x = camera_get_view_x(cam);
var view_y = camera_get_view_y(cam);
var view_w = camera_get_view_width(cam);
var view_h = camera_get_view_height(cam);

var spr_w = sprite_get_width(batlleBg);
var spr_h = sprite_get_height(batlleBg);

var scale_x = view_w / spr_w;
var scale_y = view_h / spr_h;

draw_sprite_ext(
	batlleBg,
	0,
	view_x,
	view_y,
	scale_x,
	scale_y,
	0,
	c_white,
	1
);


// ─────────────────────────
// BATTLE UI (BOTTOM, FULL WIDTH)
// ─────────────────────────
var ui_spr = sBox;

// UI height (1.5× taller)
var ui_h = view_h * 0.25 * 1.5;

// pinned to bottom
var ui_y = view_y + view_h - ui_h;

// full width
var ui_total_w = view_w;

// width split
var left_w  = ui_total_w * 0.25;
var right_w = ui_total_w * 0.75;

// x positions
var left_x  = view_x;
var right_x = view_x + left_w;

// draw left box (1/4)
draw_sprite_stretched(
	ui_spr,
	0,
	left_x,
	ui_y,
	left_w,
	ui_h
);

// draw right box (3/4)
draw_sprite_stretched(
	ui_spr,
	0,
	right_x,
	ui_y,
	right_w,
	ui_h
);




//draw units
var _unitsWithCurrentTurn = unitTurnOrder[turn].id

for(var i = 0; i < array_length(unitRenderOrder); i++){
	with(unitRenderOrder[i]){
		draw_self()
	}

}


//units data
#macro COLUMN_ENEMY -115
#macro COLUMN_NAME -55
#macro COLUMN_HP 0
#macro COLUMN_MP 55

#macro TOP_POSITION 15


draw_set_font(fnM3x6);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_gray);
draw_text(x+COLUMN_ENEMY, y+TOP_POSITION, "ENEMY");
draw_text(x+COLUMN_NAME, y+TOP_POSITION, "NAME");
draw_text(x+COLUMN_HP, y+TOP_POSITION, "HP");
draw_text(x+COLUMN_MP, y+TOP_POSITION, "MP");


//enemy info
draw_set_color(c_white);

var _drawLimit = 3;
var _drawn = 0;

for(var i = 0; (i < array_length(enemiesUnits)) && (_drawn < _drawLimit); i++){
	var _char = enemiesUnits[i];
	if(_char.hp > 0){
		_drawn++
		draw_set_color(c_white);
		if(_char.id == _unitsWithCurrentTurn) {
			draw_set_color(c_yellow);
		}
		draw_text(x+COLUMN_ENEMY, y+TOP_POSITION+10+(i*10), _char.name)
	}
}

//party info
for(var i = 0; i < array_length(partyUnits); i++){
	draw_set_color(c_white);
	var _char = partyUnits[i];
	if(_char.id == _unitsWithCurrentTurn) {
		draw_set_color(c_yellow);
	}
	if(_char.hp <= 0) {
		draw_set_color(c_red);
	}
	draw_text(x+COLUMN_NAME,y+TOP_POSITION+10+(i*10), _char.name);

	draw_set_color(c_white);
	if(_char.hp <= 0) {
		draw_set_color(c_red);
	}
	draw_text(x+COLUMN_HP,y+TOP_POSITION+10+(i*10), string(_char.hp) + "/" + string(_char.hpMax));

	draw_set_color(c_white);
	if(_char.hp <= 0) {
		draw_set_color(c_red);
	}
	draw_text(x+COLUMN_MP,y+TOP_POSITION+10+(i*10), string(_char.mp) + "/" + string(_char.mpMax));
}







