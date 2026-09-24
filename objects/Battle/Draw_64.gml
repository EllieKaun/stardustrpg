setCrispGui(guiBaseWidth(), guiBaseHeight())

var screenWidth  = display_get_gui_width()
var screenHeight = display_get_gui_height()
var scaleToGui = guiScale()

// Хит-боксы для мыши
cardHitRects = []
menuHitRects = []
infoCloseRect = undefined
cancelHitRect = undefined

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
tutorialCardsRect = { x: cardDeskStartX, y: cardDeskStartY, w: cardDeskWidth, h: cardDeskHeight }

if (battleState == BattleStates.CharacterPlay && selectedCharacter != noone) {
    var badgeScale = scaleToGui
    var badgeGap = 4 * scaleToGui
    var colMain = selectedCharacter.themeColor
    var colPanel = c_white

    var leftEdge = selectedCharacter.bbox_left * scaleToGui - 11 * scaleToGui
    var rightEdge = selectedCharacter.bbox_right * scaleToGui + 11 * scaleToGui
    var centerY = (selectedCharacter.bbox_top + selectedCharacter.bbox_bottom) * 0.5 * scaleToGui

    var shuffleSize = menuBadgeSize(loc("battle.shuffle"), badgeScale)
    var infoSize = menuBadgeSize(loc("battle.info"), badgeScale)
    var runSize = menuBadgeSize(loc("battle.run"), badgeScale)

    var rightStackH = shuffleSize.h + badgeGap + infoSize.h

    var shuffleX = rightEdge
    var shuffleY = centerY - rightStackH * 0.5
    drawMenuBadge(shuffleX, shuffleY, badgeScale, loc("battle.shuffle"), "S", true, colMain, colPanel)
    array_push(menuHitRects, { x: shuffleX, y: shuffleY, w: shuffleSize.w, h: shuffleSize.h, name: "Shuffle" })

    var infoX = rightEdge
    var infoY = shuffleY + shuffleSize.h + badgeGap
    drawMenuBadge(infoX, infoY, badgeScale, loc("battle.info"), "I", true, colMain, colPanel)
    array_push(menuHitRects, { x: infoX, y: infoY, w: infoSize.w, h: infoSize.h, name: "Info" })

    if (!(variable_global_exists("battleNoFlee") && global.battleNoFlee)) {
        var runX = leftEdge - runSize.w
        var runY = centerY - runSize.h * 0.5
        drawMenuBadge(runX, runY, badgeScale, loc("battle.run"), "R", false, colMain, colPanel)
        array_push(menuHitRects, { x: runX, y: runY, w: runSize.w, h: runSize.h, name: "Run" })
    }
}

if ((battleState == BattleStates.EnemyTargetSelection
  || battleState == BattleStates.AllyTargetSelection)
  && selectedCharacter != noone) {
    var cancelBadgeScale = scaleToGui
    var cancelColMain = selectedCharacter.themeColor
    var cancelSize = menuBadgeSize(loc("battle.cancel"), cancelBadgeScale)
    var cancelLeftEdge = selectedCharacter.bbox_left * scaleToGui - 11 * scaleToGui
    var cancelCenterY = (selectedCharacter.bbox_top + selectedCharacter.bbox_bottom) * 0.5 * scaleToGui
    var cancelX = max(0, cancelLeftEdge - cancelSize.w)
    var cancelY = cancelCenterY - cancelSize.h * 0.5
    drawMenuBadge(cancelX, cancelY, cancelBadgeScale, loc("battle.cancel"), "C", false, cancelColMain, c_white)
    cancelHitRect = { x: cancelX, y: cancelY, w: cancelSize.w, h: cancelSize.h }
}

// Рисуем карты
if (battleState == BattleStates.EnemysTurn || battleState == BattleStates.PuppetTurn || battleState == BattleStates.StunnedTurn) {
    draw_set_color(c_white)
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)
    var waitLabel = (battleState == BattleStates.StunnedTurn) ? unitDisplayName(selectedCharacter.name) + loc("battle.stunnedSuffix") : loc("battle.waiting")
    drawUiText(cardDeskStartX + cardDeskWidth / 2, cardDeskStartY + cardDeskHeight / 2, waitLabel, cardDeskHeight * 0.18)
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
} else {
    if (selectedCharacter != noone) {
        var hand = selectedCharacter.getCardsInHand()
        var handSize = min(array_length(hand), maxCardsOnDeskNumber)

        var verticalPadding = 8 * scaleToGui
        var drawCardH = cardDeskHeight - verticalPadding * 2
        var drawCardW = drawCardH * 2 / 3

        var handCenterX = cardDeskStartX + cardDeskWidth / 2
        var handCenterY = cardDeskStartY + cardDeskHeight / 2 + cardDeskHeight * 0.08
        var spread = min(drawCardW * 0.8, (cardDeskWidth - drawCardW) / max(1, handSize))
        var middleIndex = (handSize - 1) / 2

        var arcLift = 2 * scaleToGui
        var arcTilt = 5 // поворот

        // Рисуем карты в две фазы, невыбранные, затем выбранная, чтобы поверх рисовать выбранную
        for (var pass = 0; pass < 2; pass++) {
            for (var i = 0; i < handSize; i++) {
                var isSelected = (selectedCard == i)
                if ((pass == 0) == isSelected) continue 

                var card = hand[i]
                if (animatingCard != noone && card == animatingCard) continue // летит — не рисуем в руке
                var offsetFromMiddle  = i - middleIndex

                // сначала расчет оффсетов и поворотов, потом по выделению оффсет, потом скейлим к ui 
                var cardCenterX = handCenterX + offsetFromMiddle * spread
                var cardCenterY = handCenterY - abs(offsetFromMiddle) * arcLift
                var angle = -offsetFromMiddle * arcTilt
                var scale = 1

                if (isSelected) { 
                    cardCenterY -= 6 * scaleToGui
                    scale = 1.12 
                    angle = 0
                }
                
                drawCardFace(card, cardCenterX, cardCenterY, drawCardW, drawCardH, angle, scale, 1, isSelected)

                // хит-бокс карты для мыши (координаты окна, с учётом наклона)
                array_push(cardHitRects, {
                    x: cardCenterX, y: cardCenterY,
                    w: drawCardW * scale, h: drawCardH * scale,
                    angle: angle, index: i
                })

                if (isSelected && focusArea == FocusArea.Deck) {
                    var selectedCardWidth = drawCardW * scale
                    draw_sprite_ext(sPointer, 0, cardCenterX - selectedCardWidth / 2, cardCenterY, scaleToGui, scaleToGui, 0, c_white, 1)
                }
            }
        }

        // Колода героя справа — только в его ход, вместе с рукой
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
                var deckCardX = deckX - i * deckStep
                var deckCardY = deckBottomY - deckH - i * deckStep
                draw_sprite_stretched(CardBack, 0, deckCardX, deckCardY, deckW, deckH)
            }
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
        var spriteWidth = sprite_get_width(selectedTarget.sprite_index)
        var spriteHeight = sprite_get_height(selectedTarget.sprite_index)
        var spriteScale = min(spriteBoxSize / spriteWidth, spriteBoxSize / spriteHeight)
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
    var targetName = unitDisplayName(selectedTarget.name)
    if (variable_instance_exists(selectedTarget, "isIgnited") && selectedTarget.isIgnited) targetName = loc("unit.ignitePrefix") + targetName
    drawUiText(statsX, statsY, loc("battle.name") + targetName, popupTextH)
    drawUiText(statsX, statsY + lineH, loc("battle.hp") + string(selectedTarget.hp) + "/" + string(selectedTarget.maxHp), popupTextH)
    drawUiText(statsX, statsY + lineH * 2, loc("battle.mp") + string(selectedTarget.mana) + "/" + string(selectedTarget.maxMana), popupTextH)
    drawUiText(statsX, statsY + lineH * 3, loc("battle.aura") + string(selectedTarget.aura), popupTextH)
    drawUiText(statsX, statsY + lineH * 4, loc("battle.guts") + string(selectedTarget.guts), popupTextH)

    // Слабости врага
    var weaknessY = statsY + lineH * 5
    draw_set_halign(fa_left)
    var weaknessLabelText = loc("battle.weakness")
    var lblScale = drawUiText(statsX, weaknessY, weaknessLabelText, popupTextH)
    var weaknessX = statsX + string_width(weaknessLabelText) * lblScale + 6 * scaleToGui
    var weaknessList = variable_instance_exists(selectedTarget, "weaknesses") ? selectedTarget.weaknesses : []
    if (array_length(weaknessList) == 0) {
        drawUiText(weaknessX, weaknessY, loc("ui.none"), popupTextH)
    } else {
        var wIconSize = popupTextH
        for (var weaknessIndex = 0; weaknessIndex < array_length(weaknessList); weaknessIndex++) {
            var statusName = weaknessList[weaknessIndex]
            var statusIcon = weaknessIcon(statusName)
            if (statusIcon != noone) {
                draw_sprite_stretched(statusIcon, 0, weaknessX, weaknessY, wIconSize, wIconSize)
                weaknessX += wIconSize + 3 * scaleToGui
            }
            var statusLabel = weaknessLabel(statusName)
            var labelScale = drawUiText(weaknessX, weaknessY, statusLabel, popupTextH)
            weaknessX += string_width(statusLabel) * labelScale + 8 * scaleToGui
        }
    }
    draw_set_color(c_white)

    // Close Button
    var btnWidth = 48 * scaleToGui
    var btnHeight = 16 * scaleToGui
    var btnX = floor(popupX + popupWidth / 2 - btnWidth / 2)
    var btnY = floor(popupY + popupHeight + 4 * scaleToGui) 

    drawButtonFrame(btnX, btnY, btnWidth, btnHeight)
    draw_set_halign(fa_center)
    draw_set_valign(fa_middle)
    drawUiText(btnX + btnWidth / 2, btnY + btnHeight / 2, loc("ui.close"), btnHeight * 0.6)
    draw_set_valign(fa_top)
    draw_set_halign(fa_left)
    infoCloseRect = { x: btnX, y: btnY, w: btnWidth, h: btnHeight }

    // Pointer on Close Button
    draw_sprite_ext(sPointer, 0, btnX - 12 * scaleToGui, btnY + btnHeight / 2, scaleToGui, scaleToGui, 0, c_white, 1)
}

if (battleState != BattleStates.Victory && battleState != BattleStates.GameOver) {
    drawPartyPanels(heroes, selectedCharacter)
}

if (battleState == BattleStates.Victory) drawVictoryScreen()
if (battleState == BattleStates.GameOver) drawGameOverScreen()

// Летящие карты
for (var i = 0; i < array_length(activeCardAnims); i++) {
    activeCardAnims[i].draw()
}

if (tutorialActive && battleState == BattleStates.CharacterPlay && tutorial.isActive()) {
    tutorial.draw()
}

autosaveDrawIcon()
