if (global.gamePaused) { exit }
    
switch (state) {
    case FireflyState.Appearing:
        brightness = min(1, brightness + FIREFLY_FADE_SPEED)
        if (brightness >= 1) { state = FireflyState.Flying }
    break
    case FireflyState.Flying:
        
    break
    case FireflyState.Fading:
        brightness = max(0, brightness + FIREFLY_FADE_SPEED)
        if (brightness <= 1) { instance_destroy() }
    break
}