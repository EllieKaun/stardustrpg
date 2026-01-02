
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
    var card = selectedCharacter.deck[i]
    var isSelected = selectedCard == i
    var drawY = isSelected ? cardY - 2 : cardY
    draw_sprite_stretched(
	    card.cardBaseScr,
	    0,
	    cardCurrentX,
	    drawY,
	    cardWidth,
	    cardHeight
    )
    draw_sprite_stretched(
	    card.cardBorderScr,
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

/// draw heroes
for (var i = 0; i < array_length(heroes); i++) {
    var h = heroes[i];
    draw_sprite(h.spr, 0, h.x, h.y);
}

/// draw enemies
for (var i = 0; i < array_length(enemies); i++) {
    var e = enemies[i];
    draw_sprite(e.spr, 0, e.x, e.y);
    
    var pc = (e.hp / e.maxhp) * 100;
    draw_healthbar(e.x - 16, e.y - 16 - 6, e.x + 16, e.y - 16 - 4, pc, c_black, c_red, c_lime, 0, true, true)
}
