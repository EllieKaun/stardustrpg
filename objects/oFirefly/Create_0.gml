state = FireflyState.Appearing
homeX = x
homeY = y 
homeSpawner = noone 
patrolAxis = choose(0, 1)
patrolDir = choose(-1, 1)
patrolStuckSteps = 0
patrolAxisSwitches = 0
brightness = 0
blinkPhase = random(6.28)
fadeThreshold = random_range(0.25, 0.45)
bodyColor = make_colour_rgb(230, 255, 140)
light = undefined

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