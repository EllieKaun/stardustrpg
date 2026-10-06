// Draw End: поверх деревьев и ночного затемнения. Альфа = появление/угасание * мигание.
// Координаты не округляем: при скорости меньше пикселя за кадр округление даёт рывки
draw_sprite_ext(sprite_index, image_index, drawX, drawY, 1, 1, 0, bodyColor, brightness * blinkValue)
