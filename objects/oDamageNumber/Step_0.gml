// Пауза: числа урона замирают
if (global.gamePaused) exit

y += vspd;
image_alpha -= 1 / life

if (image_alpha <= 0) {
    instance_destroy()
}