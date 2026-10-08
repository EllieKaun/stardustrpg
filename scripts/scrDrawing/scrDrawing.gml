//// Battle high-res GUI helpers
// The battle draws its UI in the "logical" base resolution (global.guiBaseW/H)
// and scales it up into a higher-resolution GUI buffer with a world matrix.
// These return that base size, falling back to the raw GUI size outside battle.
function guiBaseWidth() { return variable_global_exists("guiBaseW") ? global.guiBaseW : display_get_gui_width()  }
function guiBaseHeight() { return variable_global_exists("guiBaseH") ? global.guiBaseH : display_get_gui_height() }

// Ставит GUI-слой в 16:9 аспекте
function setCrispGui(baseW, baseH) {
    var scale = max(1, min(window_get_width() / baseW, window_get_height() / baseH))
    var guiWidth = round(baseW * scale)
    var guiHeight = round(baseH * scale)
    if (display_get_gui_width() != guiWidth || display_get_gui_height() != guiHeight) {
        display_set_gui_size(guiWidth, guiHeight)
    }
}

// GUI приводится к нужному размеру
function guiSyncCrisp() {
    var camera = view_camera[0]
    setCrispGui(camera_get_view_width(camera), camera_get_view_height(camera))
}

// Видны ли HUD-элементы мира (монеты, прогресс квеста)
function worldHudVisible() {
    var shopOpen = instance_exists(oShop) && oShop.open
    var deckOpen = instance_exists(oDeckBuilder) && oDeckBuilder.open
    return !shopOpen && !deckOpen && !global.cutsceneActive
}

// Клип прямоугольником в GUI-координатах через поверхность
function guiClipBegin(surf, clipX, clipY, clipW, clipH) {
    clipW = max(1, ceil(clipW))
    clipH = max(1, ceil(clipH))
    if (surface_exists(surf) && (surface_get_width(surf) != clipW || surface_get_height(surf) != clipH)) {
        surface_free(surf)
    }
    if (!surface_exists(surf)) { surf = surface_create(clipW, clipH) }

    surface_set_target(surf)
    draw_clear_alpha(c_black, 0)
    matrix_set(matrix_world, matrix_build(-floor(clipX), -floor(clipY), 0, 0, 0, 0, 1, 1, 1))
    gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha)
    return surf
}

function guiClipEnd(surf, clipX, clipY) {
    gpu_set_blendmode(bm_normal)
    matrix_set(matrix_world, matrix_build_identity())
    surface_reset_target()

    gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha)
    draw_surface(surf, floor(clipX), floor(clipY))
    gpu_set_blendmode(bm_normal)
}

function drawButtonFrame(btnX, btnY, btnW, btnH) {
    draw_sprite_stretched(ShopBtn, 0, btnX, btnY, btnW, btnH)
}

// Попадание точки в повёрнутый прямоугольник (центр centerX,centerY; размер rectWidth,rectHeight; угол angle)
function pointInRotatedRect(pointX, pointY, centerX, centerY, rectWidth, rectHeight, angle) {
    var cosAngle = dcos(angle), sinAngle = dsin(angle)
    var offsetX = pointX - centerX, offsetY = pointY - centerY
    var localX = cosAngle * offsetX - sinAngle * offsetY // точка в локальных координатах карты
    var localY = sinAngle * offsetX + cosAngle * offsetY
    return (abs(localX) <= rectWidth * 0.5 && abs(localY) <= rectHeight * 0.5)
}



function drawHealthBar(barX, barY, width, height, hp, maxHp) {
    var percent = clamp(hp / maxHp, 0, 1)
    var borderThickness = 1
    draw_sprite_stretched(healthbar, 0, barX, barY, width, height)

    var barColor;

    if (percent >= 0.5) {
        var blend = (percent - 0.5) / 0.5
        barColor = merge_colour(c_yellow, c_lime, blend)
    } else {
        var blend = percent / 0.5
        barColor = merge_colour(c_red, c_yellow, blend)
    }
    draw_set_color(barColor)
    
    var inner_x1 = barX + borderThickness
    var inner_y1 = barY + borderThickness
    
    var inner_x2 = inner_x1 + (width - borderThickness * 2 - 1 ) * percent
    var inner_y2 = barY + height - borderThickness * 2
    
    draw_rectangle(inner_x1, inner_y1, inner_x2, inner_y2, false)
}

// pixelScale — во сколько раз увеличены пиксели арта
function drawHealthBarMana(barX, barY, width, height, hp, maxHp, mana, maxMana, pixelScale = 1) {
    var percentHp = clamp(hp / maxHp, 0, 1)
    var percentMana = (maxMana > 0) ? clamp(mana / maxMana, 0, 1) : 0
    var borderThickness = pixelScale

    draw_sprite_stretched(healthmanabar, 0, barX, barY, width, height)

    var barColor;
    if (percentHp >= 0.5) {
        var blend = (percentHp - 0.5) / 0.5
        barColor = merge_colour(c_yellow, c_lime, blend)
    } else {
        var blend = percentHp / 0.5
        barColor = merge_colour(c_red, c_yellow, blend)
    }
    draw_set_color(barColor)

    // Границы строк округляются, чтобы при дробном pixelScale заливка совпадала со спрайтом
    var healthRows = height / pixelScale - 4 // минус две рамки, разделитель и строка маны
    var innerX1 = floor(barX + borderThickness)
    var innerWidth = width - borderThickness * 2
    var healthTop = floor(barY + pixelScale)
    var healthBottom = floor(barY + (1 + healthRows) * pixelScale) - 1
    var manaTop = floor(barY + (2 + healthRows) * pixelScale) // после разделителя
    var manaBottom = floor(barY + (3 + healthRows) * pixelScale) - 1

    var innerX2 = floor(innerX1 + innerWidth * percentHp) - 1
    draw_rectangle(innerX1, healthTop, innerX2, healthBottom, false)

    draw_set_color(MANA_COLOR)

    var manaX2 = floor(innerX1 + innerWidth * percentMana) - 1
    draw_rectangle(innerX1, manaTop, manaX2, manaBottom, false)
}


function drawDamageNumber(numberX, numberY, value, color, maxWidth = 0) {
    var instance = instance_create_depth(numberX, numberY, depth - 1, oDamageNumber)
    instance.value = value
    instance.color = color
    instance.maxWidth = maxWidth
}

// Иконка статуса теперь берётся из реестра эффектов (scrEffectSystem).
function statusIconFor(effect) {
    return effectIcon(effect)
}

// returns {x, y, angle, scale} for card index of n, centered under the screen
function handCardTransform(cardIndex, handSize, hoveredIndex) {
    // tunables
    var spread  = 40 // px between card centers
    var arcLift = 3 // px each card dips toward the ends
    var arcTilt = 4 // degrees rotation per step from center

    var middleIndex = (handSize - 1) / 2
    var offsetFromMiddle = cardIndex - middleIndex // signed distance from the middle card

    var baseX = display_get_gui_width() / 2
    var baseY = display_get_gui_height() - 70

    var transform = {
        x: baseX + offsetFromMiddle * spread,
        y: baseY + abs(offsetFromMiddle) * arcLift, // ends dip down → arc
        angle: -offsetFromMiddle * arcTilt, // fan rotation
        scale: 1
    }

    // hovered/selected card overrides: lift, straighten, enlarge
    if (cardIndex == hoveredIndex) {
        transform.y -= 20
        transform.angle = 0
        transform.scale = 1.25
    }

    return transform
}

function drawCardTransformed(card, centerX, centerY, cardWidth, cardHeight, angle, scale, alpha = 1) {
    drawCardFace(card, centerX, centerY, cardWidth, cardHeight, angle, scale, alpha)
}

function drawSpriteOutline(sprite, subimage, drawX, drawY, xScale, yScale, angle, outlineColor) {
    gpu_set_fog(true, outlineColor, 0, 0)
    draw_sprite_ext(sprite, subimage, drawX - 1, drawY, xScale, yScale, angle, c_white, 1)
    draw_sprite_ext(sprite, subimage, drawX + 1, drawY, xScale, yScale, angle, c_white, 1)
    draw_sprite_ext(sprite, subimage, drawX, drawY - 1, xScale, yScale, angle, c_white, 1)
    draw_sprite_ext(sprite, subimage, drawX, drawY + 1, xScale, yScale, angle, c_white, 1)
    gpu_set_fog(false, outlineColor, 0, 0)
}

// Высота бейджа
#macro MENU_BADGE_H 10

function menuBadgeSize(label, badgeScale) {
    var aspect = sprite_get_width(ActionButtnBackground) / sprite_get_height(ActionButtnBackground)
    var base = MENU_BADGE_H * badgeScale
    var badgeHeight = base
    var textH = base * 0.9
    var padX = 4 * badgeScale
    var textScale = uiTextScale(label, textH, 100000)
    var badgeWidth = max(base * aspect, string_width(label) * textScale + padX * 2)
    return { w: badgeWidth, h: badgeHeight, textH: textH, scale: textScale }
}

function drawMenuBadge(badgeX, badgeY, badgeScale, label, hotkey, ballOnLeft, colorMain, colorPanel) {
    var size = menuBadgeSize(label, badgeScale)
    var badgeWidth = size.w
    var badgeHeight = size.h
    var scale = size.scale
    var flip = ballOnLeft ? 1 : -1
    var centerX = badgeX + badgeWidth * 0.5
    var centerY = badgeY + badgeHeight * 0.5
    var backgroundScaleX = badgeWidth / sprite_get_width(ActionButtnBackground)
    var backgroundScaleY = badgeHeight / sprite_get_height(ActionButtnBackground)
    var foregroundScaleX = badgeWidth / sprite_get_width(ActionButtonForeground)
    var foregroundScaleY = badgeHeight / sprite_get_height(ActionButtonForeground)
    // Рамку и шарик красим через fog в плоский colorMain: спрайты уже окрашены (#c70997), и image_blend
    // умножал бы их цвет на colorMain, из-за чего рамка выходила темнее текста, окрашенного тем же colorMain
    gpu_set_fog(true, colorMain, 0, 0)
    draw_sprite_ext(ActionButtnBackground, 0, centerX, centerY, backgroundScaleX * flip, backgroundScaleY, 0, c_white, 1)
    gpu_set_fog(false, c_white, 0, 0)
    draw_sprite_ext(ActionButtonForeground, 0, centerX, centerY, foregroundScaleX * flip, foregroundScaleY, 0, colorPanel, 1)

    var textShift = (ballOnLeft ? 1 : -1) * 2 * badgeScale
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)
    draw_set_color(colorMain)
    draw_text_transformed(floor(badgeX + badgeWidth * 0.5 + textShift), floor(badgeY + badgeHeight * 0.5), label, scale, scale, 0)

    var ballCenterX = ballOnLeft ? badgeX : badgeX + badgeWidth
    var ballCenterY = badgeY + badgeHeight * 0.5
    var ballScale = badgeHeight / sprite_get_height(ActionButtonCircle)
    gpu_set_fog(true, colorMain, 0, 0)
    draw_sprite_ext(ActionButtonCircle, 0, ballCenterX, ballCenterY, ballScale, ballScale, 0, c_white, 1)
    gpu_set_fog(false, c_white, 0, 0)

    draw_set_color(colorPanel)
    var hotkeyScale = uiTextScale(hotkey, size.textH, badgeHeight * 0.6)
    draw_text_transformed(floor(ballCenterX), floor(ballCenterY), hotkey, hotkeyScale, hotkeyScale, 0)

    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    draw_set_color(c_white)
    return size
}

// Показать окно награды с одной картой 
function showCardReward(cardStruct, title = loc("ui.newCard")) {
    if (cardStruct == undefined) { return }
    if (!instance_exists(oCardReward)) { instance_create_depth(0, 0, -15000, oCardReward) }
    with (oCardReward) {
        card = cardStruct
        rewardTitle = title
        active = true
        inputGuard = 2
    }
    global.uiModal = true
}

//// Панели героев
// Спрайты подключаются по имени:
//   sprCharacterPanelContent - панель, у выбранного героя красится его themeColor
//   sprCharacterPanelBorder - рамка поверх панели
//   sprCharacterPanelEnergy / sprCharacterPanelEnergyEmpty - шарик энергии: есть / нет
// У каждого героя голова - member.portrait
//
// Панель нарисована с пикселем в 4 раза крупнее пикселя арта боя, поэтому масштаб панели = guiScale() / 4,
// так она занимает на экране ту же долю, что в макете. Все размеры PARTY_PANEL_* ниже - в пикселях
// спрайта панели (212x80). Панели идут сверху вниз в порядке отряда и прижаты к левому нижнему углу

#macro PARTY_PANEL_SPRITE_PIXEL 4 // пикселей спрайта панели на один пиксель арта боя
#macro PARTY_PANEL_SIZE_BOOST 1.2 // во сколько раз панели крупнее, чем по макету
#macro PARTY_PANEL_DEFAULT_WIDTH 212 // размер панели без спрайта (как у sprCharacterPanelContent)
#macro PARTY_PANEL_DEFAULT_HEIGHT 80
#macro PARTY_PANEL_GAP 5 // между панелями
#macro PARTY_PANEL_MARGIN_BOTTOM 14
#macro PARTY_PANEL_HEAD_X 6 // левый край головы
#macro PARTY_PANEL_HEAD_BOTTOM 69 // низ головы (подбородок), выше головы выходят над панелью
#macro PARTY_PANEL_BAR_X 69 // левый край хп-маны бара
#macro PARTY_PANEL_BAR_CENTER_Y 50
#macro PARTY_PANEL_ENERGY_X 191 // центр шариков энергии
#macro PARTY_PANEL_ENERGY_Y 19 // центр верхнего шарика
#macro PARTY_PANEL_ENERGY_STEP 32 // расстояние между шариками
#macro PARTY_PANEL_ENERGY_SLOTS 2
#macro PARTY_PANEL_INACTIVE_ALPHA 0.8

function assetSpriteOrNoone(assetName) {
    var asset = asset_get_index(assetName)
    return (asset >= 0 && sprite_exists(asset)) ? asset : noone
}

function partyPanelSprites() {
    if (!variable_global_exists("partyPanelSpriteCache")) {
        global.partyPanelSpriteCache = {
            panel: assetSpriteOrNoone("sprCharacterPanelContent"),
            frame: assetSpriteOrNoone("sprCharacterPanelBorder"),
            energyFull: assetSpriteOrNoone("sprCharacterPanelEnergy"),
            energyEmpty: assetSpriteOrNoone("sprCharacterPanelEnergyEmpty")
        }
    }
    return global.partyPanelSpriteCache
}

// Спрайт целиком по центру
function drawSpriteCentered(sprite, centerX, centerY, scale) {
    var left = centerX - sprite_get_width(sprite) * scale * 0.5
    var topY = centerY - sprite_get_height(sprite) * scale * 0.5
    draw_sprite_ext(sprite, 0, left + sprite_get_xoffset(sprite) * scale, topY + sprite_get_yoffset(sprite) * scale,
        scale, scale, 0, c_white, 1)
}

function drawPartyPanels(party, activeChar) {
    var sprites = partyPanelSprites()

    var members = []
    for (var index = 0; index < array_length(party); index++) {
        if (!party[index].isPuppet) { array_push(members, party[index]) }
    }

    var panelScale = guiScale() / PARTY_PANEL_SPRITE_PIXEL * PARTY_PANEL_SIZE_BOOST
    var panelWidth = ((sprites.panel != noone) ? sprite_get_width(sprites.panel) : PARTY_PANEL_DEFAULT_WIDTH) * panelScale
    var panelHeight = ((sprites.panel != noone) ? sprite_get_height(sprites.panel) : PARTY_PANEL_DEFAULT_HEIGHT) * panelScale
    var panelStep = panelHeight + PARTY_PANEL_GAP * panelScale
    var panelX = 0
    var lastPanelY = display_get_gui_height() - PARTY_PANEL_MARGIN_BOTTOM * panelScale - panelHeight
    var firstPanelY = lastPanelY - (array_length(members) - 1) * panelStep

    // Сначала все панели, потом головы
    for (var index = 0; index < array_length(members); index++) {
        var panelY = floor(firstPanelY + index * panelStep)
        drawPartyPanelBody(panelX, panelY, panelWidth, panelHeight, panelScale, members[index], members[index] == activeChar, sprites)
    }
    for (var index = 0; index < array_length(members); index++) {
        var panelY = floor(firstPanelY + index * panelStep)
        drawPartyPanelHead(panelX, panelY, panelScale, members[index])
    }
}

function drawPartyPanelHead(panelX, panelY, panelScale, member) {
    if (!variable_instance_exists(member, "portrait") || !sprite_exists(member.portrait)) { return }
    var head = member.portrait
    var headLeft = panelX + PARTY_PANEL_HEAD_X * panelScale
    var headTop = panelY + (PARTY_PANEL_HEAD_BOTTOM - sprite_get_height(head)) * panelScale
    draw_sprite_ext(head, 0,
        headLeft + sprite_get_xoffset(head) * panelScale,
        headTop + sprite_get_yoffset(head) * panelScale,
        panelScale, panelScale, 0, c_white, 1)
}

function drawPartyPanelBody(panelX, panelY, panelWidth, panelHeight, panelScale, member, isActive, sprites) {
    // Выбранный персонаж: панель цвета персонажа
    var panelColor = isActive ? member.themeColor : c_white
    var panelAlpha = isActive ? 1 : PARTY_PANEL_INACTIVE_ALPHA
    if (sprites.panel != noone) {
        draw_sprite_stretched_ext(sprites.panel, 0, panelX, panelY, panelWidth, panelHeight, panelColor, panelAlpha)
    } else {
        var cornerRadius = panelHeight * 0.2
        draw_set_alpha(panelAlpha)
        draw_set_color(isActive ? merge_color(c_white, member.themeColor, 0.55) : c_white)
        draw_roundrect_ext(panelX, panelY, panelX + panelWidth - 1, panelY + panelHeight - 1, cornerRadius, cornerRadius, false)
        draw_set_color(merge_color(member.themeColor, c_black, 0.5))
        draw_roundrect_ext(panelX, panelY, panelX + panelWidth - 1, panelY + panelHeight - 1, cornerRadius, cornerRadius, true)
        draw_set_alpha(1)
        draw_set_color(c_white)
    }
    if (sprites.frame != noone) {
        draw_sprite_stretched(sprites.frame, 0, panelX, panelY, panelWidth, panelHeight)
    }

    // Хп и мана одним спрайтом healthmanabar, под головой. Пиксель бара - тот же, что у арта боя
    var barPixelScale = PARTY_PANEL_SPRITE_PIXEL * panelScale
    var barWidth = sprite_get_width(healthmanabar) * barPixelScale
    var barHeight = sprite_get_height(healthmanabar) * barPixelScale
    var barX = floor(panelX + PARTY_PANEL_BAR_X * panelScale)
    var barY = floor(panelY + PARTY_PANEL_BAR_CENTER_Y * panelScale - barHeight * 0.5)
    drawHealthBarMana(barX, barY, barWidth, barHeight, member.displayHp, member.maxHp,
        member.displayMana, member.maxMana, barPixelScale)

    // Энергия
    var energyX = panelX + PARTY_PANEL_ENERGY_X * panelScale
    for (var slotIndex = 0; slotIndex < PARTY_PANEL_ENERGY_SLOTS; slotIndex++) {
        var energyY = panelY + (PARTY_PANEL_ENERGY_Y + slotIndex * PARTY_PANEL_ENERGY_STEP) * panelScale
        var hasEnergy = (slotIndex < member.energy)
        var energySprite = hasEnergy ? sprites.energyFull : sprites.energyEmpty
        if (energySprite != noone) {
            drawSpriteCentered(energySprite, energyX, energyY, panelScale)
        } else {
            var ballRadius = 14 * panelScale
            draw_set_color(hasEnergy ? make_color_rgb(95, 195, 245) : make_color_rgb(40, 50, 70))
            draw_circle(energyX, energyY, ballRadius, false)
            draw_set_color(c_black)
            draw_circle(energyX, energyY, ballRadius, true)
            draw_set_color(c_white)
        }
    }
}

// Значок над головой персонажа когда есть квест (в draw end)
function drawQuestMarker(markerSprite, anchorX, anchorY) {
    if (markerSprite == noone || !sprite_exists(markerSprite)) { return }
    var frameCount = sprite_get_number(markerSprite)
    var framesPerSecond = sprite_get_speed(markerSprite)
    if (sprite_get_speed_type(markerSprite) == spritespeed_framespergameframe) {
        framesPerSecond *= game_get_speed(gamespeed_fps)
    }
    var frame = floor(current_time / 1000 * framesPerSecond) mod frameCount
    var bobOffset = round(sin(current_time / 250) * 1.5)
    draw_sprite(markerSprite, frame, round(anchorX), round(anchorY) + bobOffset)
}
