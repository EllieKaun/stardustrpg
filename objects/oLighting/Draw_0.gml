var cam = view_camera[0]
var viewX = camera_get_view_x(cam)
var viewY = camera_get_view_y(cam)
var viewWidth = camera_get_view_width(cam)
var viewHeight = camera_get_view_height(cam)

if (!surface_exists(lightSurface)) { lightSurface = surface_create(viewWidth, viewHeight) }

// Рисование дня или ночи    
var ambient = merge_color(dayColor, nightColor, nightValue())

surface_set_target(lightSurface)
draw_clear_alpha(ambient, 1)
gpu_set_blendmode(bm_add)
for (var index = 0; index < array_length(lights); index++) {
    var light = lights[index]
    var localX = light.x - viewX 
    var localY = light.y - viewY
    var flick = 1
    if (light.flicker > 0){ 
        flick = 1 - light.flicker * (0.5 + 0.5 * sin(current_time / 90 + index))
    }
    var scaleXY = (light.radius * 2) / sprite_get_width(sprLight)
    var alpha = clamp(light.intensity * flick, 0, 1)
    draw_sprite_ext(sprLight, 0, localX, localY, scaleXY, scaleXY, 0, light.color, alpha)
}
gpu_set_blendmode(bm_normal)
surface_reset_target()

gpu_set_blendmode_ext(bm_dest_colour, bm_zero)
draw_surface(lightSurface, viewX, viewY)
gpu_set_blendmode(bm_normal)
