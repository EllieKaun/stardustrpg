function menuParam(params, key, defaultValue) {
    return (is_struct(params) && variable_struct_exists(params, key)) ? params[$ key] : defaultValue
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
        var deltaTime = delta_time / 1000000
        self.time += deltaTime
        self.ox += self.scrollX * deltaTime
    }

    self.draw = function(guiWidth, guiHeight) {
        var bobOffset = (self.bobAmp != 0) ? sin(self.time * self.bobFreq * 2 * pi) * self.bobAmp * guiHeight : 0
        var scrollOffsetY = self.scrollY * self.time + bobOffset

        if (self.spr == noone || !sprite_exists(self.spr)) {
            draw_set_alpha(self.alpha)
            draw_set_color(self.placeholderColor)
            draw_rectangle(0, 0, guiWidth, guiHeight, false)
            draw_set_alpha(1)
            draw_set_color(c_white)
            draw_set_halign(fa_left)
            draw_set_valign(fa_top)
            //drawUiText(6, 6, "[" + self.name + "]", gh * 0.04)
            return
        }

        var spriteWidth = sprite_get_width(self.spr)
        var spriteHeight = sprite_get_height(self.spr)

        if (self.tiled) {
            var tileOffsetX = self.ox mod spriteWidth;
            if (tileOffsetX > 0) { tileOffsetX -= spriteWidth }    
            var tileOffsetY = scrollOffsetY mod spriteHeight; 
            if (tileOffsetY > 0) {
                tileOffsetY -= spriteHeight
            } 
            for (var tileY = tileOffsetY; tileY < guiHeight; tileY += spriteHeight) 
                for (var tileX = tileOffsetX; tileX < guiWidth; tileX += spriteWidth)
                    draw_sprite_ext(self.spr, 0, tileX, tileY, 1, 1, 0, c_white, self.alpha)
        } else {
            // Растянуть с оверсканом и центрированием, чтобы боб не оголял края.
            var scaledWidth = guiWidth * self.scale
            var scaledHeight = guiHeight * self.scale
            var baseX = (guiWidth - scaledWidth) * 0.5 + self.ox
            var baseY = (guiHeight - scaledHeight) * 0.5 + scrollOffsetY

            var visLeft = max(baseX, 0)
            var visTop = max(baseY, 0)
            var visRight = min(baseX + scaledWidth, guiWidth)
            var visBottom = min(baseY + scaledHeight, guiHeight)
            if (visRight <= visLeft || visBottom <= visTop) { return }

            var scaleX = scaledWidth / spriteWidth
            var scaleY = scaledHeight / spriteHeight
            draw_sprite_part_ext(self.spr, 0,
                (visLeft - baseX) / scaleX, (visTop - baseY) / scaleY,
                (visRight - visLeft) / scaleX, (visBottom - visTop) / scaleY,
                visLeft, visTop, scaleX, scaleY, c_white, self.alpha)
        }
    }
}

// Контроллер меню 
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

    // навигация
    self.moveBy = function(direction) {
        var itemCount = array_length(self.items)
        if (itemCount == 0) { return }
        var navIndex = self.index
        repeat (itemCount) { // перескакиваем выключенные пункты
            navIndex += direction
            if (self.wrap) { navIndex = (navIndex + itemCount) mod itemCount }
            else { navIndex = clamp(navIndex, 0, itemCount - 1) }
            if (self.items[navIndex].enabled) { break }
        }
        self.index = navIndex
    }
    self.moveNext = function() { self.moveBy(1) }
    self.movePrev = function() { self.moveBy(-1) }
    self.current  = function() { return self.items[self.index] }

    self.confirm = function() {
        if (array_length(self.items) == 0) { return false }
        var item = self.current()
        if (!item.enabled) { return false }
        if (item.onSelect != undefined) { item.onSelect(item) }
        return true
    }

    // Ввод: клавиатура (вверх/вниз/enter/space) + мышь (наведение/клик по hitRects) 
    // Возвращает true, если пункт подтверждён.
    self.handleInput = function(mouseX, mouseY, mouseMoved, mouseClicked) {
        if (keyboard_check_pressed(vk_up)   || keyboard_check_pressed(ord("W"))) { self.movePrev() }
        if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) { self.moveNext() }

        var confirmed = false
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) { confirmed = self.confirm() }

        for (var rectIndex = 0; rectIndex < array_length(self.hitRects); rectIndex++) {
            var hitRect = self.hitRects[rectIndex]
            if (pointInRect(mouseX, mouseY, hitRect.x, hitRect.y, hitRect.w, hitRect.h)) {
                if (self.items[hitRect.index].enabled) {
                    if (mouseMoved) {   self.index = hitRect.index }
                    if (mouseClicked) { self.index = hitRect.index; confirmed = self.confirm() }
                }
                break
            }
        }
        return confirmed
    }
    self.draw = function(guiWidth, guiHeight) {
        self.hitRects = []

        var textPx = guiHeight * self.textH
        var stepPx = guiHeight * self.spacing
        var iconPx = textPx * 1.15
        var gapPx  = guiHeight * self.iconGap
        var anchorPixelX = guiWidth * self.anchorX
        var startPixelY = guiHeight * self.startY

        draw_set_valign(fa_middle)
        draw_set_halign(fa_left)
        draw_set_font(uiFont())

        for (var itemIndex = 0; itemIndex < array_length(self.items); itemIndex++) {
            var item = self.items[itemIndex]
            var isSel = (itemIndex == self.index)
            var itemY = startPixelY + itemIndex * stepPx
            var icon = item.icon(isSel)
            var hasIcon = (icon != noone && sprite_exists(icon))

            var tScale = uiTextScale(item.label, textPx, guiWidth)
            var textW = string_width(item.label) * tScale
            var iconW = hasIcon ? iconPx : 0
            var groupW = iconW + (hasIcon ? gapPx : 0) + textW

            var left
            switch (self.halign) {
                case fa_center: 
                    left = anchorPixelX - groupW / 2
                    break
                case fa_right: 
                    left = anchorPixelX - groupW
                    break
                default: 
                    left = anchorPixelX
                    break
            }

            // иконка
            if (hasIcon) {
                var iconScale = iconPx / max(sprite_get_width(icon), sprite_get_height(icon))
                draw_sprite_ext(icon, 0, left, itemY - iconPx / 2, iconScale, iconScale, 0, c_white, 1)
            }

            // текст
            var textColor = !item.enabled ? self.colDisabled : (isSel ? self.colSelect : self.colNormal)
            draw_set_color(textColor)
            draw_text_transformed(left + (hasIcon ? iconW + gapPx : 0), itemY, item.label, tScale, tScale, 0)

            array_push(self.hitRects, { x: left, y: itemY - stepPx / 2, w: groupW, h: stepPx, index: itemIndex })
        }

        draw_set_halign(fa_left)
        draw_set_valign(fa_top)
        draw_set_color(c_white)
    }
}

//// Помощник композиции слоёв 
// Единый порядок отрисовки сцены меню
function menuDrawScene(backLayers, foreLayers, menu, itemsAboveForeground, guiWidth, guiHeight) {
    for (var layerIndex = 0; layerIndex < array_length(backLayers); layerIndex++) backLayers[layerIndex].draw(guiWidth, guiHeight)
    if (!itemsAboveForeground && menu != undefined) { menu.draw(guiWidth, guiHeight) }
    for (var layerIndex = 0; layerIndex < array_length(foreLayers); layerIndex++) foreLayers[layerIndex].draw(guiWidth, guiHeight)
    if (itemsAboveForeground && menu != undefined) { menu.draw(guiWidth, guiHeight) }
}

// Обновление анимации всех слоёв сцены (вызывать в Step)
function menuUpdateLayers(backLayers, foreLayers) {
    for (var layerIndex = 0; layerIndex < array_length(backLayers); layerIndex++) backLayers[layerIndex].update()
    for (var layerIndex = 0; layerIndex < array_length(foreLayers); layerIndex++) foreLayers[layerIndex].update()
}

// GUI-слой в аспекте 16:9
function menuEnsureCrispGui() {
    // В бою база GUI равна размеру вьюхи, меню поверх боя должно рисоваться в ней же
    if (instance_exists(Battle)) { setCrispGui(guiBaseWidth(), guiBaseHeight()) }
    else { setCrispGui(320, 180) }
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
    var displayWidth = display_get_width()
    var displayHeight = display_get_height()
    
    // Если по какой-то причине дисплей не определен
    if (displayWidth == 0 || displayHeight == 0) {
        return all_res
    }
    
    for (var resIndex = 0; resIndex < array_length(all_res); resIndex++) {
        if (all_res[resIndex][0] <= displayWidth && all_res[resIndex][1] <= displayHeight) {
            array_push(valid_res, all_res[resIndex])
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
    var displayWidth = display_get_width(), displayHeight = display_get_height()
    winW = min(winW, displayWidth)
    winH = min(winH, displayHeight)
    window_set_size(winW, winH)
    window_set_position((displayWidth - winW) div 2, max(0, (displayHeight - winH) div 2))
}

// Применяет настройки дисплея при старте
function initDisplaySettings() {
    if (variable_global_exists("displayModeReady") && global.displayModeReady) { return; }
    global.displayModeReady = true;
    
    ini_open("settings.ini")
    var resolutionIndex = ini_read_real("Display", "ResolutionIndex", 2)
    var fullscreen = ini_read_real("Display", "Fullscreen", 1)
    ini_close()

    var resolutions = menuGetResolutions()
    resolutionIndex = min(resolutionIndex, array_length(resolutions) - 1)
    if (resolutionIndex >= 0) {
        applyWindowMode(resolutions[resolutionIndex][0], resolutions[resolutionIndex][1], fullscreen)
    }
    global.displayFullscreen = fullscreen
}
