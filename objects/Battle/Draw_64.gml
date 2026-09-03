setCrispGui(guiBaseWidth(), guiBaseHeight())

var screenWidth  = display_get_gui_width()
var screenHeight = display_get_gui_height()
var scaleToGui = screenWidth / guiBaseWidth()

// Хит-боксы для мыши
cardHitRects = []
menuHitRects = []
infoCloseRect = undefined

var cardDeskHeight = screenHeight / 3
var topSpacing = (3 + 2) * scaleToGui
var bottomSpacing = 3 * scaleToGui
var cardSpacing = 6 * scaleToGui
var cardHeight = cardDeskHeight - (topSpacing + bottomSpacing)
var cardWidth = cardHeight * 2 / 3

// Стол
var cardDeskWidth = cardWidth * maxCardsOnDeskNumber + cardSpacing * (maxCardsOnDeskNumber + 1)
var cardDeskStartX = (screenWidth - cardDeskWidth) / 2
var cardDeskStartY = screenHeight - cardDeskHeight

if (battleState == BattleStates.CharacterPlay && selectedCharacter != noone) {
    var badgeScale = scaleToGui
    var badgeGap = 4 * scaleToGui
    var colMain = selectedCharacter.themeColor
    var colPanel = c_white

    var leftEdge = selectedCharacter.bbox_left * scaleToGui - 11 * scaleToGui
    var rightEdge = selectedCharacter.bbox_right * scaleToGui + 11 * scaleToGui
    var centerY = (selectedCharacter.bbox_top + selectedCharacter.bbox_bottom) * 0.5 * scaleToGui

    var shuffleSize = menuBadgeSize("SHUFFLE", badgeScale)
    var infoSize = menuBadgeSize("INFO", badgeScale)
    var runSize = menuBadgeSize("RUN", badgeScale)

    var rightStackH = shuffleSize.h + badgeGap + infoSize.h

    var shuffleX = rightEdge
    var shuffleY = centerY - rightStackH * 0.5
    drawMenuBadge(shuffleX, shuffleY, badgeScale, "SHUFFLE", "S", true, colMain, colPanel)
    array_push(menuHitRects, { x: shuffleX, y: shuffleY, w: shuffleSize.w, h: shuffleSize.h, name: "Shuffle" })

    var infoX = rightEdge
    var infoY = shuffleY + shuffleSize.h + badgeGap
    drawMenuBadge(infoX, infoY, badgeScale, "INFO", "I", true, colMain, colPanel)
    array_push(menuHitRects, { x: infoX, y: infoY, w: infoSize.w, h: infoSize.h, name: "Info" })

    var runX = leftEdge - runSize.w
    var runY = centerY - runSize.h * 0.5
    drawMenuBadge(runX, runY, badgeScale, "RUN", "R", false, colMain, colPanel)
    array_push(menuHitRects, { x: runX, y: runY, w: runSize.w, h: runSize.h, name: "Run" })
}

// Рисуем карты
var selectedBorderWidth = max(1, 1 * scaleToGui)

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
        var n = min(array_length(hand), maxCardsOnDeskNumber)

        var vPad = 8 * scaleToGui
        var drawCardH = cardDeskHeight - vPad * 2
        var drawCardW = drawCardH * 2 / 3

        var handCenterX = cardDeskStartX + cardDeskWidth / 2
        var handCenterY = cardDeskStartY + cardDeskHeight / 2 + cardDeskHeight * 0.08
        var spread = min(drawCardW * 0.8, (cardDeskWidth - drawCardW) / max(1, n))
        var mid = (n - 1) / 2

        var arcLift = 2 * scaleToGui
        var arcTilt = 5 // поворот

        // Рисуем карты в две фазы, невыбранные, затем выбранная, чтобы поверх рисовать выбранную
        for (var pass = 0; pass < 2; pass++) {
            for (var i = 0; i < n; i++) {
                var isSelected = (selectedCard == i)
                if ((pass == 0) == isSelected) continue 

                var card = hand[i]
                if (animatingCard != noone && card == animatingCard) continue // летит — не рисуем в руке
                var off  = i - mid

                // сначала расчет оффсетов и поворотов, потом по выделению оффсет, потом скейлим к ui 
                var cx = handCenterX + off * spread
                var cy = handCenterY - abs(off) * arcLift
                var angle = -off * arcTilt
                var scale = 1

                if (isSelected) { 
                    cy -= 6 * scaleToGui
                    scale = 1.12 
                    angle = 0
                }
                
                drawCardFace(card, cx, cy, drawCardW, drawCardH, angle, scale, 1, isSelected)

                // хит-бокс карты для мыши (координаты окна, с учётом наклона)
                array_push(cardHitRects, {
                    x: cx, y: cy,
                    w: drawCardW * scale, h: drawCardH * scale,
                    angle: angle, index: i
                })

                if (isSelected && focusArea == FocusArea.Deck) {
                    var bw = drawCardW * scale
                    draw_sprite_ext(sPointer, 0, cx - bw / 2, cy, scaleToGui, scaleToGui, 0, c_white, 1)
                }
            }
        }
    }
}

if (selectedCharacter != noone) {
    var deckCount = array_length(selectedCharacter.getShuffeledDeck())
    if (deckCount > 0) {
        var deckH = cardDeskHeight * 0.7
        var deckScale = deckH / sprite_get_height(CardBack)
        var deckW = sprite_get_width(CardBack) * deckScale
        var deckMargin = 8 * scaleToGui
        var deckStep = 2 * scaleToGui
        var deckX = screenWidth - deckMargin - deckW
        var deckBottomY = screenHeight - deckMargin

        for (var i = 0; i < deckCount; i++) {
            var dx = deckX - i * deckStep
            var dy = deckBottomY - deckH - i * deckStep
            draw_sprite_stretched(CardBack, 0, dx, dy, deckW, deckH)
        }
    }
}

// Информация о враге
if (battleState == BattleStates.EnemyInfoDisplay && selectedTarget != noone) {
    var popupWidth = screenWidth * 0.6
    var popupHeight = screenHeight * 0.5
    var popupX = (screenWidth - popupWidth) / 2
    var popupY = (screenHeight - popupHeight) / 2

    draw_sprite_stretched(box, 0, popupX, popupY, popupWidth, popupHeight)

    var margin = 16 * scaleToGui
    var spriteBoxSize = 64 * scaleToGui
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
    var lineH = 14 * scaleToGui
    var popupTextH = lineH * 0.72
    draw_set_color(c_white)
    draw_set_halign(fa_left)
    drawUiText(statsX, statsY, "Name: " + string(selectedTarget.name), popupTextH)
    drawUiText(statsX, statsY + lineH, "HP: " + string(selectedTarget.hp) + "/" + string(selectedTarget.maxHp), popupTextH)
    drawUiText(statsX, statsY + lineH * 2, "MP: " + string(selectedTarget.mana) + "/" + string(selectedTarget.maxMana), popupTextH)
    drawUiText(statsX, statsY + lineH * 3, "Aura: " + string(selectedTarget.aura), popupTextH)
    drawUiText(statsX, statsY + lineH * 4, "Guts: " + string(selectedTarget.guts), popupTextH)

    // Close Button (Positioned below the popup)
    var btnWidth = 48 * scaleToGui
    var btnHeight = 16 * scaleToGui
    var btnX = floor(popupX + popupWidth / 2 - btnWidth / 2)
    var btnY = floor(popupY + popupHeight + 4 * scaleToGui) // 4 pixels below the popup

    draw_sprite_stretched(box, 0, btnX, btnY, btnWidth, btnHeight)
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)
    drawUiText(btnX + btnWidth / 2, btnY + btnHeight / 2, "CLOSE", btnHeight * 0.6)
    draw_set_valign(fa_top)
    draw_set_halign(fa_left)
    infoCloseRect = { x: btnX, y: btnY, w: btnWidth, h: btnHeight }

    // Pointer on Close Button
    draw_sprite_ext(sPointer, 0, btnX - 12 * scaleToGui, btnY + btnHeight / 2, scaleToGui, scaleToGui, 0, c_white, 1)
}

if (battleState == BattleStates.Victory) drawVictoryScreen()
if (battleState == BattleStates.GameOver) drawGameOverScreen()

// Летящие карты — поверх всего интерфейса
for (var i = 0; i < array_length(activeCardAnims); i++) {
    activeCardAnims[i].draw()
}
