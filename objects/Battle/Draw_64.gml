// Keep the GUI buffer matched to the window so overlaid text stays pixel-crisp
// (a GUI larger than the window gets downscaled and looks ragged).
if (display_get_gui_width() != window_get_width() || display_get_gui_height() != window_get_height())
    display_set_gui_size(max(window_get_width(), guiBaseWidth()), max(window_get_height(), guiBaseHeight()))

// Draw the whole battle UI in the base (low-res) coordinate space, then scale it
// up into the high-res GUI buffer with a world matrix. This keeps every element
// pixel-identical to before, while letting us render the card stats at full
// GUI resolution on top (see the stats pass below) so they stay crisp.
var screenWidth  = guiBaseWidth()
var screenHeight = guiBaseHeight()
var uiScale      = display_get_gui_width() / screenWidth

var _matIdentity = matrix_get(matrix_world)
var _matScale    = matrix_build(0, 0, 0, 0, 0, 0, uiScale, uiScale, 1)
matrix_set(matrix_world, _matScale)

var cardDeskHeight = screenHeight / 3
var topSpacing = 3 + 2
var bottomSpacing = 3
var cardSpacing = 6
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
draw_sprite_stretched(
	sprCardDesk,
	0,
	0,
	floor(screenHeight - sideBoxHeight),
	sideBoxWidth,
	sideBoxHeight
)

// Меню в левом боксе
var menuPadding = 6
var menuItemHeight = 16

if (battleState != BattleStates.EnemysTurn) {
	draw_set_halign(fa_right)
	draw_set_font(fnM3x6_14)
	for (var i = 0; i < array_length(menuItems); i++) {
	    var isMenuItemSelected = (focusArea == FocusArea.Menu && selectedMenuItem == i)
	    draw_set_color(isMenuItemSelected ? c_yellow : c_white)
	    
	    var textX = floor(sideBoxWidth - menuPadding)
	    var textY = floor(screenHeight - sideBoxHeight + menuPadding + i * menuItemHeight)
	    
	    draw_text(textX, textY, menuItems[i])
	    
	    if (isMenuItemSelected) {
	        var textW = string_width(menuItems[i])
	        draw_sprite(
	            sPointer,
	            0,
	            floor(textX - textW - 12),
	            floor(textY + menuItemHeight / 2)
	        )
	    }
	}
}
draw_set_halign(fa_left)

// Правый бокс
draw_sprite_stretched(
	sprCardDesk,
	0,
	floor(cardDeskStartX + cardDeskWidth),
	floor(screenHeight - sideBoxHeight),
	sideBoxWidth,
	sideBoxHeight
)

// Инфо о карте в ПРАВОМ боксе
if (focusArea == FocusArea.Deck && selectedCharacter != noone && battleState != BattleStates.EnemysTurn) {
	var cardsInHand = selectedCharacter.getCardsInHand()
	if (selectedCard < array_length(cardsInHand)) {
		var card = cardsInHand[selectedCard]
		draw_set_halign(fa_left)
		draw_set_font(fnM3x6_14)
		draw_set_color(c_white)
		
		var infoX = floor(cardDeskStartX + cardDeskWidth + menuPadding)
		var infoY = floor(screenHeight - sideBoxHeight + menuPadding)
		var infoLineH = 12
		
		// Название и Тип
		draw_text(infoX, infoY, prettifyCardName(card.name))
		draw_text(infoX, infoY + infoLineH, "Type: " + (card.actionType == StarriorStates.Attack ? "Attack" : "Cast"))
		
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
				draw_text(infoX, currentY, rangeStr)
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
			draw_text(infoX, currentY, "Effects: " + effectStr)
			currentY += infoLineH
		}
		
		// Cost
		var costLabel = (card.costType() == CostType.Mana) ? "MP: " : "HP: "
		draw_text(infoX, currentY, "Cost: " + string(card.costValue()) + " " + costLabel)
	}
}

// Центральный стол
draw_sprite_stretched(
	sprCardDesk,
	0,
	cardDeskStartX,
	cardDeskStartY,
	cardDeskWidth,
	cardDeskHeight
)

// Рисуем карты
var cardY = cardDeskStartY + topSpacing
var selectedBorderWidth = 1

if (battleState == BattleStates.EnemysTurn || battleState == BattleStates.PuppetTurn) {
    draw_set_color(c_white)
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)
    drawFitTextInArea("Waiting...",
        cardDeskStartX + cardDeskWidth / 2,
        cardDeskStartY + cardDeskHeight / 2,
        cardDeskWidth,
        cardDeskHeight)
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
} else {
    if (selectedCharacter != noone) {
        var hand = selectedCharacter.getCardsInHand()
        var n    = min(array_length(hand), maxCardsOnDeskNumber)

        // card size: clamp to desk with padding
        var vPad      = 8
        var drawCardH = cardDeskHeight - vPad * 2
        var drawCardW = drawCardH * 2 / 3

        var handCenterX = cardDeskStartX + cardDeskWidth / 2
        var handCenterY = cardDeskStartY + cardDeskHeight / 2   // desk vertical middle
        var spread      = min(drawCardW * 0.8, (cardDeskWidth - drawCardW) / max(1, n))
        var mid         = (n - 1) / 2

        var arcLift = 2
        var arcTilt = 5    // fan rotation — raise for more tilt, 0 for a flat row

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

                if (isSelected) { cy -= 6; scale = 1.12; angle = 0; }

                // Middle-Centre origin → draw at CENTER (cx/cy), pass real angle
                var sx = (drawCardW / sprite_get_width(card.cardBaseSpr))  * scale
                var sy = (drawCardH / sprite_get_height(card.cardBaseSpr)) * scale

                draw_sprite_ext(card.cardBaseSpr,         0, cx, cy, sx, sy, angle, c_white, 1)
                draw_sprite_ext(card.cardIllustrationSpr, 0, cx, cy, sx, sy, angle, c_white, 1)
                draw_sprite_ext(card.cardBorderSpr,       0, cx, cy, sx, sy, angle, c_white, 1)
                draw_sprite_ext(card.cardTokenSpr,        0, cx, cy, sx, sy, angle, c_white, 1)

                // stats at full GUI resolution, drawn right on top of THIS card
                // (identity matrix) so back cards' text never covers front cards.
                matrix_set(matrix_world, _matIdentity)
                drawCardStats(
                    cx * uiScale, cy * uiScale,
                    drawCardW * scale * uiScale, drawCardH * scale * uiScale,
                    angle, card
                )
                matrix_set(matrix_world, _matScale)

                if (isSelected && focusArea == FocusArea.Deck) {
                    var bw = drawCardW * scale
                    var bh = drawCardH * scale
                    drawBorderAroundCard(cx - bw / 2, cy - bh / 2, selectedBorderWidth, bw, bh)
                    draw_sprite(sPointer, 0, cx - bw / 2, cy)
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
    
    var margin = 16
    var spriteBoxSize = 64
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
    var lineH = 14
    draw_set_font(fnM3x6_14)
    draw_set_color(c_white)
    draw_set_halign(fa_left)
    draw_text(statsX, statsY, "Name: " + string(selectedTarget.name))
    draw_text(statsX, statsY + lineH, "HP: " + string(selectedTarget.hp) + "/" + string(selectedTarget.maxHp))
    draw_text(statsX, statsY + lineH * 2, "MP: " + string(selectedTarget.mana) + "/" + string(selectedTarget.maxMana))
    draw_text(statsX, statsY + lineH * 3, "Aura: " + string(selectedTarget.aura))
    draw_text(statsX, statsY + lineH * 4, "Guts: " + string(selectedTarget.guts))
    // Close Button (Positioned below the popup)
    var btnWidth = 48
    var btnHeight = 16
    var btnX = floor(popupX + popupWidth / 2 - btnWidth / 2)
    var btnY = floor(popupY + popupHeight + 4) // 4 pixels below the popup
    
    draw_sprite_stretched(sprCardDeskFull, 0, btnX, btnY, btnWidth, btnHeight)
    draw_set_halign(fa_center)
    draw_text(btnX + btnWidth / 2, btnY + 2, "CLOSE")
    
    // Pointer on Close Button
    draw_sprite(sPointer, 0, btnX - 12, btnY + btnHeight / 2)
}

if (battleState == BattleStates.Victory) drawVictoryScreen()
if (battleState == BattleStates.GameOver) drawGameOverScreen()

// Летящие карты — поверх всего интерфейса
for (var i = 0; i < array_length(activeCardAnims); i++) {
    activeCardAnims[i].draw()
}

// Restore the world matrix so later events / instances draw normally.
matrix_set(matrix_world, _matIdentity)