
var screenWidth = camera_get_view_width(view_camera[0])
var screenHeight = camera_get_view_height(view_camera[0])

/**
 *  Рисуем стол с картами
 */
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
draw_sprite_stretched(
	sprCardDesk,
	0,
	cardDeskStartX,
	cardDeskStartY,
	cardDeskWidth,
	cardDeskHeight
)

// Рисуем карты
var cardCurrentX = cardDeskStartX + cardSpacing
var cardY = cardDeskStartY + topSpacing 
var selectedBorderWidth = 1
if battleState == BattleStates.EnemysTurn {
    drawFitTextInArea("Waiting...",
    cardDeskStartX + spacingBetweenStarriors, 
    cardDeskStartY, 
    cardDeskWidth, 
    cardDeskHeight)
} else {
if selectedCharacter != noone  {
    for(var i = 0; i < min(array_length(selectedCharacter.getCardsInHand()), maxCardsOnDeskNumber); i++) {
        var card = selectedCharacter.getCardsInHand()[i]
        var isSelected = selectedCard == i
        var drawY = isSelected ? cardY - 2 : cardY
        draw_sprite_stretched(
    	    card.cardBaseSpr,
    	    0,
    	    cardCurrentX,
    	    drawY,
    	    cardWidth,
    	    cardHeight
        )
        draw_sprite_stretched(
    	    card.cardIllustrationSpr,
    	    0,
    	    cardCurrentX,
    	    drawY,
    	    cardWidth,
    	    cardHeight
        )
        draw_sprite_stretched(
    	    card.cardBorderSpr,
    	    0,
    	    cardCurrentX,
    	    drawY,
    	    cardWidth,
    	    cardHeight
        )
        draw_sprite_stretched(
    	    card.cardTokenSpr,
    	    0,
    	    cardCurrentX,
    	    drawY,
    	    cardWidth,
    	    cardHeight
        )
        // Выделение
        if isSelected { 
            // Рамка вокруг выбранной карты
            drawBorderAroundCard(
                cardCurrentX,
                drawY,
                selectedBorderWidth,
                cardWidth,
                cardHeight
            )
            
            // Указатель на выбранную карту
            draw_sprite(
                sPointer,
                0,
                cardCurrentX,
                drawY + cardHeight / 2
            )
        } 
        cardCurrentX += cardWidth + cardSpacing
    }
}
}