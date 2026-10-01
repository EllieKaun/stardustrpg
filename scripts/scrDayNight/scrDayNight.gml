function updateTimeOfDay(){
    if (global.gamePaused || global.timePaused) { return }
        
    var deltaSeconds = delta_time / 1000000
    global.timeOfDay += deltaSeconds * global.timeSpeed
    global.timeOfDay -= floor(global.timeOfDay)
}

function smoothstep(edge0, edge1, x) {
    var time = clamp((x - edge0) / (edge1 - edge0), 0, 1)
    return time * time * (3 - 2 * time)
}

function nightValue() {
    var time = global.timeOfDay
    var dayFactor = smoothstep(0.20, 0.30, time) * (1 - smoothstep(0.70, 0.8, time))
    return 1 - dayFactor
}

function isNight() {
    return nightValue() >= 0.5
}