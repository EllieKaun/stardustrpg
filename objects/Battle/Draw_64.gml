var screenWidth = display_get_gui_width()
var screenHeight = display_get_gui_height()



/**
 *  Рисуем стол с картами
 */

// Стол
var cardDeskWidth = screenWidth * 0.5
var cardDeskHeight = screenHeight / 4 
var cardSpacing = 16 
var cardWidth = (cardDeskWidth - cardSpacing * (maxCardsOnDeskNumber + 1)) / maxCardsOnDeskNumber
var cardDeskStartX = cardDeskWidth * 0.5
var cardDeskStartY = cardDeskHeight
draw_sprite_stretched(
	sprCardDesk,
	0,
	cardDeskStartX,
	cardDeskStartY,
	cardDeskWidth,
	cardDeskHeight
);
