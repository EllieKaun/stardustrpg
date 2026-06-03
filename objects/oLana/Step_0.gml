if (global.uiModal) {
    sprite_index = (last_v_dir < 0) ? sLanaBackwards : sLana;
    exit;
}

// ───── INPUT ─────
var h = keyboard_check(ord("D")) - keyboard_check(ord("A"));
var v = keyboard_check(ord("S")) - keyboard_check(ord("W"));

// ───── MOVEMENT VECTOR ─────
var moving = (h != 0 || v != 0);
var mx = h * spdWalk;
var my = v * spdWalk;

// ───── REMEMBER LAST VERTICAL DIRECTION ─────
if (v != 0)
    last_v_dir = sign(v);

// ───── ANIMATION ─────
if (moving)
{
    if (v < 0)
        sprite_index = sLanaBackwardsWalk;
    else
        sprite_index = sLanaWalk;
}
else
{
    if (last_v_dir < 0)
        sprite_index = sLanaBackwards;
    else
        sprite_index = sLana;
}

// ───── SPRITE FLIP ─────
if (h != 0)
    image_xscale = sign(h);

// ───── COLLISION & MOVE ─────
if (!place_meeting(x + mx, y, oWall))
    x += mx;

if (!place_meeting(x, y + my, oWall))
    y += my;
