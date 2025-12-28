
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
for(var i = 0; i < maxCardsOnDeskNumber; i++) {
    var isSelected = selectedCard == cards[i]
    var drawY = isSelected ? cardY - 2 : cardY
     draw_sprite_stretched(
	    CardSprite,
	    0,
	    cardCurrentX,
	    drawY,
	    cardWidth,
	    cardHeight
    )
    if isSelected { 
        draw_line_width_colour(
            cardCurrentX - 1, 
            drawY - selectedBorderWidth, 
            cardCurrentX - 1 + cardWidth, 
            drawY - selectedBorderWidth, 
            selectedBorderWidth, 
            c_yellow, 
            c_yellow
        )
         draw_line_width_colour(
            cardCurrentX - selectedBorderWidth, 
            drawY - 1, 
            cardCurrentX - selectedBorderWidth , 
            drawY + cardHeight - 1, 
            selectedBorderWidth, 
            c_yellow, 
            c_yellow
        )
         draw_line_width_colour(
            cardCurrentX + cardWidth - 1, 
            drawY - 1, 
            cardCurrentX + cardWidth - 1, 
            drawY + cardHeight - 1, 
            selectedBorderWidth , 
            c_yellow, 
            c_yellow
        )
        draw_line_width_colour(
            cardCurrentX - 1, 
            drawY + cardHeight - 1, 
            cardCurrentX + cardWidth - 1, 
            drawY + cardHeight -1  , 
            selectedBorderWidth, 
            c_yellow, 
            c_yellow
        )
        draw_sprite(
            sPointer,
            0,
            cardCurrentX,
            drawY + cardHeight / 2
        )
    } 
    cardCurrentX += cardWidth + cardSpacing
}