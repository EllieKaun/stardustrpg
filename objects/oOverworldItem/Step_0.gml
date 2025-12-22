var p = instance_nearest(x, y, oLana);

var tree_base_depth = -bbox_bottom;

if (p != noone) {

    // Player feet
    var px = p.x;
    var py = p.bbox_top;

    // Trunk zone
    var trunk_base = bbox_bottom;
    var trunk_top  = trunk_base - trunk_height;

    var trunk_left  = x - trunk_width * 0.5;
    var trunk_right = x + trunk_width * 0.5;

    // Player is BEHIND tree (fully above trunk)
    var player_behind =
        (py < trunk_top) &&
        (px > trunk_left) &&
        (px < trunk_right);

    if (player_behind) {
        // Tree in front of player
        depth = p.depth - 1;
        image_alpha = lerp(image_alpha, fade_alpha, fade_speed);
    } else {
        // Player in front of tree
        depth = p.depth + 1;
        image_alpha = lerp(image_alpha, 1, fade_speed);
    }

} else {
    depth = tree_base_depth;
}
