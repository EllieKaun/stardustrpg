var cam = view_camera[0]
var viewX = camera_get_view_x(cam)
var viewY = camera_get_view_y(cam)
var viewWidth = camera_get_view_width(cam)
var viewHeight = camera_get_view_height(cam)

if (!surface_exists(lightSurface)) { lightSurface = surface_create(viewWidth, viewHeight) }
    
var ambient = merge_color(dayColor, nightColor, nightValue())

surface_set_target(lightSurface)
draw_clear_alpha(ambient, 1)
surface_reset_target()

gpu_set_blendmode_ext(bm_dest_colour, bm_zero)
draw_surface(lightSurface, viewX, viewY)
gpu_set_blendmode(bm_normal)