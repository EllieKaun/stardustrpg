function Deck(originalDeck) constructor {
    self.originalDeck = originalDeck
    self.shuffeledDeck = []
    self.cardsInHand = []
}

function shuffleDeckAndTake4(character) {
    var originalDeck = character.getOriginalDeck()
    var shuffeledDeck = array_shuffle(originalDeck)
    var top4Cards = take4CardsFromDeckTop(shuffeledDeck, [])
    character.deck.shuffeledDeck = shuffeledDeck
    character.deck.cardsInHand = top4Cards

}

function take4CardsFromDeckTop(shuffledDeck, cardsInHand) {
    var top4Cards = []
    for(var i = array_length(cardsInHand); 
        i < maxCardsOnDeskNumber && array_length(shuffledDeck) > 0; 
        i++) {
        array_push(top4Cards, array_shift(shuffledDeck))
    }  
    return top4Cards     
}