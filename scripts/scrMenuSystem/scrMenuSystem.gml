function menuParam(params, key, def) {
    return (is_struct(params) && variable_struct_exists(params, key)) ? params[$ key] : def
}

// Пункт меню 
function MenuItem(label, iconSpr = noone, iconSelectedSpr = noone, onSelect = undefined) constructor {
    self.label = label
    self.iconSpr = iconSpr
    self.iconSelectedSpr = (iconSelectedSpr == noone) ? iconSpr : iconSelectedSpr
    self.onSelect = onSelect
    self.enabled = true

    // Иконка с учётом состояния выделения.
    self.icon = function(isSelected) {
        return isSelected ? self.iconSelectedSpr : self.iconSpr
    }
}

// Анимированный слой
// name — подпись для заглушки
// scrollX/scrollY — скорость скролла, px/сек
// bobAmp/bobFreq — амплитуда (доля высоты) и частота (Гц) синусного покачивания по Y
// scale — оверскан слоя (1 = ровно экран); >1 не даёт краям обрезаться при бобе
// alpha — прозрачность 0..1
// tiled — растянуть на весь экран для false
// placeholderColor — цвет заглушки
function MenuLayer(spr = noone, params = {}) constructor {
    self.spr = spr
    self.name = menuParam(params, "name", "layer")
    self.scrollX = menuParam(params, "scrollX", 0)
    self.scrollY = menuParam(params, "scrollY", 0)
    self.bobAmp = menuParam(params, "bobAmp", 0)
    self.bobFreq = menuParam(params, "bobFreq", 0)
    self.scale = menuParam(params, "scale", 1)
    self.alpha = menuParam(params, "alpha", 1)
    self.tiled = menuParam(params, "tiled", false)
    self.placeholderColor = menuParam(params, "placeholderColor", make_color_rgb(20, 24, 34))
    self.time = 0 // секунды с создания
    self.ox = 0 // накопленный горизонтальный скролл

    self.update = function() {
        var dt = delta_time / 1000000
        self.time += dt
        self.ox += self.scrollX * dt
    }

    self.draw = function(gw, gh) {
        var bob = (self.bobAmp != 0) ? sin(self.time * self.bobFreq * 2 * pi) * self.bobAmp * gh : 0
        var oy = self.scrollY * self.time + bob

        if (self.spr == noone || !sprite_exists(self.spr)) {
            draw_set_alpha(self.alpha)
            draw_set_color(self.placeholderColor)
            draw_rectangle(0, 0, gw, gh, false)
            draw_set_alpha(1)
            draw_set_color(c_white)
            draw_set_halign(fa_left)
            draw_set_valign(fa_top)
            //drawUiText(6, 6, "[" + self.name + "]", gh * 0.04)
            return
        }

        var sw = sprite_get_width(self.spr)
        var sh = sprite_get_height(self.spr)

        if (self.tiled) {
            var offX = self.ox mod sw;
            if (offX > 0) offX -= sw    
            var offY = oy mod sh; 
            if (offY > 0) {
                offY -= sh
            } 
            for (var yy = offY; yy < gh; yy += sh) 
                for (var xx = offX; xx < gw; xx += sw)
                    draw_sprite_ext(self.spr, 0, xx, yy, 1, 1, 0, c_white, self.alpha)
        } else {
            // Растянуть с оверсканом и центрированием, чтобы боб не оголял края.
            var ew = gw * self.scale
            var eh = gh * self.scale
            var baseX = (gw - ew) * 0.5 + self.ox
            var baseY = (gh - eh) * 0.5 + oy
            draw_sprite_stretched_ext(self.spr, 0, baseX, baseY, ew, eh, c_white, self.alpha)
        }
    }
}

// ---- Контроллер меню --------------------------------------------------------
// items — массив MenuItem. config (опц.): расположение/вид в ДОЛЯХ экрана:
//   anchorX — точка привязки по X (0..1)
//   startY — верх списка по Y (0..1)
//   spacing — шаг между пунктами (доля высоты)
//   textH — высота текста (доля высоты)
//   iconGap — отступ иконка↔текст (доля высоты)
//   halign — fa_left/fa_center/fa_right (выравнивание группы "иконка+текст")
//   colNormal/colSelect/colDisabled — цвета
//   wrap — зацикливать навигацию (true)
function Menu(items, config = {}) constructor {
    self.items = items
    self.index = 0
    self.wrap = menuParam(config, "wrap", true)
    self.anchorX = menuParam(config, "anchorX", 0.5)
    self.startY = menuParam(config, "startY", 0.45)
    self.spacing = menuParam(config, "spacing", 0.10)
    self.textH = menuParam(config, "textH", 0.055)
    self.iconGap = menuParam(config, "iconGap", 0.02)
    self.halign = menuParam(config, "halign", fa_center)
    self.colNormal = menuParam(config, "colNormal", c_white)
    self.colSelect = menuParam(config, "colSelect", c_yellow)
    self.colDisabled = menuParam(config, "colDisabled", make_color_rgb(120, 120, 130))

    self.hitRects = []   // { x, y, w, h, index } в GUI-координатах, заполняется в draw

    // --- навигация ---
    self.moveBy = function(dir) {
        var n = array_length(self.items)
        if (n == 0) return
        var i = self.index
        repeat (n) { // перескакиваем выключенные пункты
            i += dir
            if (self.wrap) i = (i + n) mod n
            else i = clamp(i, 0, n - 1)
            if (self.items[i].enabled) break
        }
        self.index = i
    }
    self.moveNext = function() { self.moveBy(1) }
    self.movePrev = function() { self.moveBy(-1) }
    self.current  = function() { return self.items[self.index] }

    self.confirm = function() {
        if (array_length(self.items) == 0) return false
        var it = self.current()
        if (!it.enabled) return false
        if (it.onSelect != undefined) it.onSelect(it)
        return true
    }

    // Ввод: клавиатура (вверх/вниз/enter/space) + мышь (наведение/клик по hitRects).
    // Возвращает true, если пункт подтверждён.
    self.handleInput = function(mx, my, mouseMoved, mouseClicked) {
        if (keyboard_check_pressed(vk_up)   || keyboard_check_pressed(ord("W"))) self.movePrev()
        if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) self.moveNext()

        var confirmed = false
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) confirmed = self.confirm()

        for (var i = 0; i < array_length(self.hitRects); i++) {
            var r = self.hitRects[i]
            if (pointInRect(mx, my, r.x, r.y, r.w, r.h)) {
                if (self.items[r.index].enabled) {
                    if (mouseMoved)   self.index = r.index
                    if (mouseClicked) { self.index = r.index; confirmed = self.confirm() }
                }
                break
            }
        }
        return confirmed
    }

    // Отрисовка пунктов в GUI. Заполняет hitRects. Иконка слева от текста. группа
    // "иконка текст" выравнивается по halign относительно anchorX.
    self.draw = function(gw, gh) {
        self.hitRects = []

        var textPx = gh * self.textH
        var stepPx = gh * self.spacing
        var iconPx = textPx * 1.15
        var gapPx  = gh * self.iconGap
        var cx = gw * self.anchorX
        var y0 = gh * self.startY

        draw_set_valign(fa_middle)
        draw_set_halign(fa_left)
        draw_set_font(uiFont())

        for (var i = 0; i < array_length(self.items); i++) {
            var it = self.items[i]
            var isSel = (i == self.index)
            var yy = y0 + i * stepPx
            var icon = it.icon(isSel)
            var hasIcon = (icon != noone && sprite_exists(icon))

            var tScale = uiTextScale(it.label, textPx, gw)
            var textW = string_width(it.label) * tScale
            var iconW = hasIcon ? iconPx : 0
            var groupW = iconW + (hasIcon ? gapPx : 0) + textW

            var left
            switch (self.halign) {
                case fa_center: 
                    left = cx - groupW / 2
                    break
                case fa_right: 
                    left = cx - groupW
                    break
                default: 
                    left = cx
                    break
            }

            // иконка
            if (hasIcon) {
                var isc = iconPx / max(sprite_get_width(icon), sprite_get_height(icon))
                draw_sprite_ext(icon, 0, left, yy - iconPx / 2, isc, isc, 0, c_white, 1)
            }

            // текст
            var col = !it.enabled ? self.colDisabled : (isSel ? self.colSelect : self.colNormal)
            draw_set_color(col)
            draw_text_transformed(left + (hasIcon ? iconW + gapPx : 0), yy, it.label, tScale, tScale, 0)

            array_push(self.hitRects, { x: left, y: yy - stepPx / 2, w: groupW, h: stepPx, index: i })
        }

        draw_set_halign(fa_left)
        draw_set_valign(fa_top)
        draw_set_color(c_white)
    }
}

//// Помощник композиции слоёв 
// Единый порядок отрисовки сцены меню
function menuDrawScene(backLayers, foreLayers, menu, itemsAboveForeground, gw, gh) {
    for (var i = 0; i < array_length(backLayers); i++) backLayers[i].draw(gw, gh)
    if (!itemsAboveForeground && menu != undefined) menu.draw(gw, gh)
    for (var i = 0; i < array_length(foreLayers); i++) foreLayers[i].draw(gw, gh)
    if (itemsAboveForeground && menu != undefined) menu.draw(gw, gh)
}

// Обновление анимации всех слоёв сцены (вызывать в Step)
function menuUpdateLayers(backLayers, foreLayers) {
    for (var i = 0; i < array_length(backLayers); i++) backLayers[i].update()
    for (var i = 0; i < array_length(foreLayers); i++) foreLayers[i].update()
}

// GUI-слой в аспекте 16:9
function menuEnsureCrispGui() {
    setCrispGui(320, 180)
}

// Возвращает список разрешений экрана, не превышающих размер дисплея
function menuGetResolutions() {
    var all_res = [
        [1280, 720],
        [1600, 900],
        [1920, 1080],
        [2560, 1440],
        [3840, 2160]
    ]
    var valid_res = []
    var dw = display_get_width()
    var dh = display_get_height()
    
    // Если по какой-то причине дисплей не определен
    if (dw == 0 || dh == 0) {
        return all_res
    }
    
    for (var i = 0; i < array_length(all_res); i++) {
        if (all_res[i][0] <= dw && all_res[i][1] <= dh) {
            array_push(valid_res, all_res[i])
        }
    }
    
    // Оставляем хотя бы одно разрешение на случай ошибок
    if (array_length(valid_res) == 0) {
        array_push(valid_res, all_res[0])
    }
    
    return valid_res
}

// Применить режим окна: фуллскрин, либо оконный размер с центрированием
function applyWindowMode(winW, winH, fullscreen) {
    if (fullscreen) {
        window_set_fullscreen(true)
        return
    }
    window_set_fullscreen(false)
    // оконный размер не больше рабочего стола
    var dw = display_get_width(), dh = display_get_height()
    winW = min(winW, dw)
    winH = min(winH, dh)
    window_set_size(winW, winH)
    window_set_position((dw - winW) div 2, max(0, (dh - winH) div 2))
}

// Применяет настройки дисплея при старте
function initDisplaySettings() {
    if (variable_global_exists("displayModeReady") && global.displayModeReady) return;
    global.displayModeReady = true;
    
    ini_open("settings.ini")
    var resInd = ini_read_real("Display", "ResolutionIndex", 2)
    var fs = ini_read_real("Display", "Fullscreen", 1)
    ini_close()

    var res = menuGetResolutions()
    resInd = min(resInd, array_length(res) - 1)
    if (resInd >= 0) {
        applyWindowMode(res[resInd][0], res[resInd][1], fs)
        display_set_gui_size(res[resInd][0], res[resInd][1])
    }
    global.displayFullscreen = fs
}
