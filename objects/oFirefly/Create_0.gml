state = FireflyState.Appearing
homeX = x
homeY = y 
homeSpawner = noone 
patrolAxis = choose(0, 1)
patrolDir = choose(-1, 1)
brightness = 0
blinkPhase = random(6.28)
fadeThreshold = random_range(0.25, 0.45) // при какой "глубине ночи" гаснет; у каждого свой, чтобы гасли не разом
bodyColor = make_colour_rgb(230, 255, 140)
light = undefined
blinkValue = 0
drawX = x // позиция отрисовки с учётом виляния
drawY = y
// Спрайт рисуем сами в Draw End. Автоматическую отрисовку в Draw гасим,
// иначе точка рисуется второй раз - под ночным затемнением и без мигания
image_alpha = 0
if (instance_exists(oLighting)) {
    light = oLighting.addLight({
        x: x,
        y: y,
        radius: FIREFLY_LIGHT_RADIUS,
        color: make_colour_rgb(190, 255, 120),
        intensity: 0,
        flicker: 0
    })
}