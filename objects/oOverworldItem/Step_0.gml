if (global.gamePaused) { exit }

var nearestHero = instance_nearest(x, y, oHero)
var playerBehind = (nearestHero != noone) && point_in_rectangle(nearestHero.x, nearestHero.bbox_bottom, visLeft, visTop, visRight, visBottom - trunk_height)
var targetAlpha = playerBehind ? fade_alpha : 1
if (image_alpha != targetAlpha) {
    image_alpha = lerp(image_alpha, targetAlpha, fade_speed)
    if (abs(image_alpha - targetAlpha) < 0.01) { image_alpha = targetAlpha }
}
