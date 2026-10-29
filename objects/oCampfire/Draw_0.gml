draw_self()

if (!canInteract) { exit }

var icon = campfireInteractIcon()
if (icon == noone) { exit }

var bob = sin(current_time / 300) * 1.5
draw_sprite(icon, 0, x, bbox_top - CAMPFIRE_ICON_OFFSET + bob)
