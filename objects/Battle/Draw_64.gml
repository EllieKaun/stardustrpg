// GUI matched to the window so text stays crisp (a larger GUI would be downscaled).
if (display_get_gui_width() != window_get_width() || display_get_gui_height() != window_get_height())
    display_set_gui_size(max(window_get_width(), guiBaseWidth()), max(window_get_height(), guiBaseHeight()))

// Весь UI боя рисуется ПРЯМО в координатах GUI (окна) — без матрицы, одно
// пространство координат. s — множитель дизайн→окно (guiW / базовая ширина),
// применяется к абсолютным константам (как раньше делала матрица). Относительные
// величины (screenWidth*0.6, screenHeight/3, …) масштабируются сами.
var screenWidth  = display_get_gui_width()
var screenHeight = display_get_gui_height()
var s = screenWidth / guiBaseWidth()

// Хит-боксы для мыши (координаты GUI/окна, читаются в Step).
cardHitRects  = []
menuHitRects  = []
infoCloseRect = undefined

var cardDeskHeight = screenHeight / 3
var topSpacing = (3 + 2) * s
var bottomSpacing = 3 * s
var cardSpacing = 6 * s
var cardHeight = cardDeskHeight - (topSpacing + bottomSpacing)
var cardWidth = cardHeight * 2 / 3

// Стол
var cardDeskWidth = cardWidth * maxCardsOnDeskNumber + cardSpacing * (maxCardsOnDeskNumber + 1)
var cardDeskStartX = (screenWidth - cardDeskWidth) / 2
var cardDeskStartY = screenHeight - cardDeskHeight

// Дополнительные UI боксы слева и справа
var sideBoxWidth = floor(cardDeskStartX)
var sideBoxHeight = floor(cardDeskHeight * 0.8)

// Левый бокс
draw_sprite_stretched(sprCardDesk, 0, 0, floor(screenHeight - sideBoxHeight), sideBoxWidth, sideBoxHeight)

// Меню в левом боксе
var menuPadding = 6 * s
var menuItemHeight = 16 * s

if (battleState != BattleStates.EnemysTurn) {
	draw_set_halign(fa_right)
	for (var i = 0; i < array_length(menuItems); i++) {
	    var isMenuItemSelected = (focusArea == FocusArea.Menu && selectedMenuItem == i)
	    draw_set_color(isMenuItemSelected ? c_yellow : c_white)

	    var textX = floor(sideBoxWidth - menuPadding)
	    var textY = floor(screenHeight - sideBoxHeight + menuPadding + i * menuItemHeight)

	    var mScale = drawUiText(textX, textY, menuItems[i], menuItemHeight * 0.62)
	    array_push(menuHitRects, { x: 0, y: textY, w: sideBoxWidth, h: menuItemHeight, index: i })

	    if (isMenuItemSelected) {
	        var textW = string_width(menuItems[i]) * mScale
	        draw_sprite_ext(sPointer, 0, floor(textX - textW - 12 * s), floor(textY + menuItemHeight / 2), s, s, 0, c_white, 1)
	    }
	}
}
draw_set_halign(fa_left)

// Правый бокс
draw_sprite_stretched(sprCardDesk, 0, floor(cardDeskStartX + cardDeskWidth), floor(screenHeight - sideBoxHeight), sideBoxWidth, sideBoxHeight)

// Инфо о карте в ПРАВОМ боксе
if (focusArea == FocusArea.Deck && selectedCharacter != noone && battleState != BattleStates.EnemysTurn) {
	var cardsInHand = selectedCharacter.getCardsInHand()
	if (selectedCard < array_length(cardsInHand)) {
		var card = cardsInHand[selectedCard]
		draw_set_halign(fa_left)
		draw_set_color(c_white)

		var infoX = floor(cardDeskStartX + cardDeskWidth + menuPadding)
		var infoY = floor(screenHeight - sideBoxHeight + menuPadding)
		var infoLineH = 12 * s
		var infoTextH = infoLineH * 0.9

		// Название и Тип
		drawUiText(infoX, infoY, prettifyCardName(card.name), infoTextH)
		drawUiText(infoX, infoY + infoLineH, "Type: " + (card.actionType == StarriorStates.Attack ? "Attack" : "Cast"), infoTextH)

		var currentY = infoY + infoLineH * 2

		// Damage/Heal Range
		var rangeStr = ""
		for (var i = 0; i < array_length(card.effects); i++) {
			var effect = card.effects[i]
			if (effect.type == EffectTypes.Damage || effect.type == EffectTypes.Heal) {
				var minNum = 1
				var maxNum = 0
				var isAll = (card.target == TargetTypes.AllEnemies || card.target == TargetTypes.AllAllies)

				switch (card.rarity) {
					case CardsRarity.Default: maxNum = isAll ? 2 : 4; break;
					case CardsRarity.Unusual: maxNum = isAll ? 4 : 6; break;
					case CardsRarity.Rare: maxNum = isAll ? 6 : 8; break;
					case CardsRarity.Epic: maxNum = isAll ? 8 : 12; break;
				}

				var label = (effect.type == EffectTypes.Damage) ? "Damage: " : "Heal: "
				rangeStr = label + string(minNum) + "-" + string(maxNum)
				drawUiText(infoX, currentY, rangeStr, infoTextH)
				currentY += infoLineH
				break
			}
		}

		// Effects
		var effectStr = ""
		for (var i = 0; i < array_length(card.effects); i++) {
			var effect = card.effects[i]
			if (effect.type != EffectTypes.Damage && effect.type != EffectTypes.Heal) {
				effectStr += effectTypeToString(effect.type) + " "
			}
		}
		if (effectStr != "") {
			drawUiText(infoX, currentY, "Effects: " + effectStr, infoTextH)
			currentY += infoLineH
		}

		// Cost
		var costLabel = (card.costType() == CostType.Mana) ? "MP: " : "HP: "
		drawUiText(infoX, currentY, "Cost: " + string(card.costValue()) + " " + costLabel, infoTextH)
	}
}

// Центральный стол
draw_sprite_stretched(sprCardDesk, 0, cardDeskStartX, cardDeskStartY, cardDeskWidth, cardDeskHeight)

// Рисуем карты
var selectedBorderWidth = max(1, 1 * s)

if (battleState == BattleStates.EnemysTurn || battleState == BattleStates.PuppetTurn) {
    draw_set_color(c_white)
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)
    drawUiText(cardDeskStartX + cardDeskWidth / 2, cardDeskStartY + cardDeskHeight / 2, "Waiting...", cardDeskHeight * 0.18)
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
} else {
    if (selectedCharacter != noone) {
        var hand = selectedCharacter.getCardsInHand()
        var n    = min(array_length(hand), maxCardsOnDeskNumber)

        // card size: clamp to desk with padding
        var vPad      = 8 * s
        var drawCardH = cardDeskHeight - vPad * 2
        var drawCardW = drawCardH * 2 / 3

        var handCenterX = cardDeskStartX + cardDeskWidth / 2
        var handCenterY = cardDeskStartY + cardDeskHeight / 2   // desk vertical middle
        var spread      = min(drawCardW * 0.8, (cardDeskWidth - drawCardW) / max(1, n))
        var mid         = (n - 1) / 2

        var arcLift = 2 * s
        var arcTilt = 5    // угол (градусы) — НЕ масштабируем

        // two passes: non-selected first, selected last so it draws on top
        for (var pass = 0; pass < 2; pass++) {
            for (var i = 0; i < n; i++) {
                var isSelected = (selectedCard == i)
                if ((pass == 0) == isSelected) continue   // pass 0 = others, pass 1 = selected

                var card = hand[i]
                if (animatingCard != noone && card == animatingCard) continue // летит — не рисуем в руке
                var off  = i - mid

                // compute transform, THEN apply selected overrides, THEN derive scale
                var cx    = handCenterX + off * spread
                var cy    = handCenterY - abs(off) * arcLift
                var angle = -off * arcTilt
                var scale = 1

                if (isSelected) { cy -= 6 * s; scale = 1.12; angle = 0; }

                // Middle-Centre origin → draw at CENTER (cx/cy), pass real angle
                var sx = (drawCardW / sprite_get_width(card.cardBaseSpr))  * scale
                var sy = (drawCardH / sprite_get_height(card.cardBaseSpr)) * scale

                draw_sprite_ext(card.cardBaseSpr,         0, cx, cy, sx, sy, angle, c_white, 1)
                draw_sprite_ext(card.cardIllustrationSpr, 0, cx, cy, sx, sy, angle, c_white, 1)
                draw_sprite_ext(card.cardBorderSpr,       0, cx, cy, sx, sy, angle, c_white, 1)
                draw_sprite_ext(card.cardTokenSpr,        0, cx, cy, sx, sy, angle, c_white, 1)

                // хит-бокс карты для мыши (координаты окна, с учётом наклона)
                array_push(cardHitRects, {
                    x: cx, y: cy,
                    w: drawCardW * scale, h: drawCardH * scale,
                    angle: angle, index: i
                })

                // статы поверх ЭТОЙ карты (координаты уже оконные, шрифт fnUI —
                // чётко); задние карты не перекрывают передние, т.к. рисуем внутри цикла
                drawCardStats(cx, cy, drawCardW * scale, drawCardH * scale, angle, card)

                if (isSelected && focusArea == FocusArea.Deck) {
                    var bw = drawCardW * scale
                    var bh = drawCardH * scale
                    drawBorderAroundCard(cx - bw / 2, cy - bh / 2, selectedBorderWidth, bw, bh)
                    draw_sprite_ext(sPointer, 0, cx - bw / 2, cy, s, s, 0, c_white, 1)
                }
            }
        }
    }
}

// Enemy Info Popup
if (battleState == BattleStates.EnemyInfoDisplay && selectedTarget != noone) {
    var popupWidth = screenWidth * 0.6
    var popupHeight = screenHeight * 0.5
    var popupX = (screenWidth - popupWidth) / 2
    var popupY = (screenHeight - popupHeight) / 2

    draw_sprite_stretched(sprCardDeskFull, 0, popupX, popupY, popupWidth, popupHeight)

    var margin = 16 * s
    var spriteBoxSize = 64 * s
    var spriteBoxX = popupX + margin
    var spriteBoxY = popupY + margin

    draw_set_color(c_white)
    draw_rectangle(spriteBoxX, spriteBoxY, spriteBoxX + spriteBoxSize, spriteBoxY + spriteBoxSize, false)

    if (sprite_exists(selectedTarget.sprite_index)) {
        var sw = sprite_get_width(selectedTarget.sprite_index)
        var sh = sprite_get_height(selectedTarget.sprite_index)
        var spriteScale = min(spriteBoxSize / sw, spriteBoxSize / sh)
        draw_sprite_ext(selectedTarget.sprite_index, 0,
            spriteBoxX + spriteBoxSize / 2,
            spriteBoxY + spriteBoxSize / 2,
            spriteScale, spriteScale, 0, c_white, 1)
    }

    var statsX = spriteBoxX + spriteBoxSize + margin
    var statsY = spriteBoxY
    var lineH = 14 * s
    var popupTextH = lineH * 0.72
    draw_set_color(c_white)
    draw_set_halign(fa_left)
    drawUiText(statsX, statsY, "Name: " + string(selectedTarget.name), popupTextH)
    drawUiText(statsX, statsY + lineH, "HP: " + string(selectedTarget.hp) + "/" + string(selectedTarget.maxHp), popupTextH)
    drawUiText(statsX, statsY + lineH * 2, "MP: " + string(selectedTarget.mana) + "/" + string(selectedTarget.maxMana), popupTextH)
    drawUiText(statsX, statsY + lineH * 3, "Aura: " + string(selectedTarget.aura), popupTextH)
    drawUiText(statsX, statsY + lineH * 4, "Guts: " + string(selectedTarget.guts), popupTextH)

    // Close Button (Positioned below the popup)
    var btnWidth = 48 * s
    var btnHeight = 16 * s
    var btnX = floor(popupX + popupWidth / 2 - btnWidth / 2)
    var btnY = floor(popupY + popupHeight + 4 * s) // 4 pixels below the popup

    draw_sprite_stretched(sprCardDeskFull, 0, btnX, btnY, btnWidth, btnHeight)
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)
    drawUiText(btnX + btnWidth / 2, btnY + btnHeight / 2, "CLOSE", btnHeight * 0.6)
    draw_set_valign(fa_top)
    draw_set_halign(fa_left)
    infoCloseRect = { x: btnX, y: btnY, w: btnWidth, h: btnHeight }

    // Pointer on Close Button
    draw_sprite_ext(sPointer, 0, btnX - 12 * s, btnY + btnHeight / 2, s, s, 0, c_white, 1)
}

if (battleState == BattleStates.Victory) drawVictoryScreen()
if (battleState == BattleStates.GameOver) drawGameOverScreen()

// Летящие карты — поверх всего интерфейса
for (var i = 0; i < array_length(activeCardAnims); i++) {
    activeCardAnims[i].draw()
}
