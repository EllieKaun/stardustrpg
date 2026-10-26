fade_alpha = 0.4;
fade_speed = 0.15;

trunk_height = 8;   // pixels
trunk_width = 10;  // pixels

visLeft = x - sprite_get_xoffset(sprite_index)
visTop = y - sprite_get_yoffset(sprite_index)
visRight = visLeft + sprite_get_width(sprite_index)
visBottom = visTop + sprite_get_height(sprite_index)
depth = -visBottom

