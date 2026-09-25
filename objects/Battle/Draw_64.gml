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

var currentState = stateAt(battleState)
if (currentState != undefined) {
    var drawUnder = currentState[StateHook.DrawUnder]
    if (drawUnder != undefined) { drawUnder() }
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
                if ((pass == 0) == isSelected) { continue }

                var card = hand[i]
                if (animatingCard != noone && card == animatingCard) { continue } // летит — не рисуем в руке
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

if (battleState != BattleStates.Victory && battleState != BattleStates.GameOver) {
    drawPartyPanels(heroes, selectedCharacter)
}

if (currentState != undefined) {
    var drawOver = currentState[StateHook.DrawOver]
    if (drawOver != undefined) { drawOver() }
}

// Летящие карты
for (var i = 0; i < array_length(activeCardAnims); i++) {
    activeCardAnims[i].draw()
}

if (tutorialActive && battleState == BattleStates.CharacterPlay && tutorial.isActive()) {
    tutorial.draw()
}

autosaveDrawIcon()
