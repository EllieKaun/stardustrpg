// Пауза: анимация и таймер эффекта замирают
if (global.gamePaused) {
    image_speed = 0
    if (alarm[0] > 0) { alarm[0] += 1 }
    exit
}
image_speed = 1

if (instance_exists(target)) {
    x = target.x
    y = target.y
} else {
    instance_destroy()
}