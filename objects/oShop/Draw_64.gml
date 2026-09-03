if (!open) exit

layoutPanels()

var screenWidth = display_get_gui_width()
var screenHeight = display_get_gui_height()
var margin = screenWidth * 0.012

// Фон магазина
draw_set_alpha(0.5)
draw_set_color(c_black) 
draw_rectangle(0, 0, screenWidth, screenHeight, false)
draw_set_color(c_white)
draw_set_alpha(1)
draw_sprite_stretched(ShopBg1, 0, 0, 0, screenWidth, screenHeight)
draw_sprite_stretched(ShopBg2, 0, 0, 0, screenWidth, screenHeight)

// Список товаров
shopPanel.draw()

// Баннер по центру
draw_sprite_stretched(BigShopSignboard, 0, bannerX, bannerY, bannerW, signHeight)

// подпись на баннере
draw_set_font(uiFont())
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_color(c_white)

var titleScale = uiTextScale("TURNSTAR's SHOP", signHeight * 0.4, bannerW * 0.62)
draw_text_transformed(bannerX + bannerW * 0.5, bannerY + signHeight * 0.45, "TURNSTAR's SHOP", titleScale, titleScale, 0)

// Головы
var headCY = bannerY + signHeight * 0.5
var headInset = headW * 0.12
// левая 
draw_sprite_ext(TurnstarHead, 0, bannerX - headInset, headCY,
    headW / sprite_get_width(TurnstarHead), headH / sprite_get_height(TurnstarHead), 0, c_white, 1)
// правая 
draw_sprite_ext(TurnstarHead, 0, bannerX + bannerW + headInset, headCY,
    -headW / sprite_get_width(TurnstarHead), headH / sprite_get_height(TurnstarHead), 0, c_white, 1)

// Счётчик монет
var coinH = signHeight * 0.55
var coinScale = coinH / sprite_get_height(CoinIcon)
var coinW = sprite_get_width(CoinIcon) * coinScale
var coinCX = screenWidth - margin - coinW * 0.5
var coinCY = bannerY + signHeight * 0.5
draw_sprite_ext(CoinIcon, 0, coinCX, coinCY, coinScale, coinScale, 0, c_white, 1)

draw_set_halign(fa_right)
draw_set_valign(fa_middle)
var balStr = string(getGold())
var balScale = uiTextScale(balStr, coinH * 0.9, screenWidth * 0.15)
draw_text_transformed(coinCX - coinW * 0.5 - margin * 0.4, coinCY, balStr, balScale, balScale, 0)

draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_set_color(c_white)
