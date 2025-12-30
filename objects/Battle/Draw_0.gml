
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
if selectedCharacter != noone {
for(var i = 0; i < min(array_length(selectedCharacter.deck), maxCardsOnDeskNumber); i++) {
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
    // Выделение
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
}

/// draw heroes
for (var i = 0; i < array_length(heroes); i++) {
    var h = heroes[i];
    draw_sprite(h.spr, 0, h.x, h.y);
}

/// draw enemies
for (var i = 0; i < array_length(enemies); i++) {
    var e = enemies[i];
    draw_sprite(e.spr, 0, e.x, e.y);
}
