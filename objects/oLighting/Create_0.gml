lightSurface = -1 
dayColor = c_white
nightColor = make_color_rgb(45, 55, 95)

lights = []
addLight = function (cfg) {
    array_push(lights, cfg)
    return cfg
}
removeLight = function(light) {
    for(var index = 0; index < array_length(lights); index++) {
        if(light == lights[index]) {
            array_delete(lights, index, 1)
        }
    }
}