name = ""
isActive = false 
isTarget = false

hp = 0 
maxHp = 0 
mana = 0 
maxMana = 0 
energy = 0
maxEnergy = 0

intelligense = 0 
strength = 0
guts = 0
aura = 0
resistense = 0

debuffs = []
buggs = []
weaknesses = []

deck = new Deck([])

actionState = StarriorStates.Idle
spriteActionIdle = sprLanaBattleIdle
spriteActionAttack = sprLanaBattleIdle
actionCallback = undefined
function changeActionState(state, callback) {
    actionState = state
    actionCallback = callback
    
    switch (actionState) { 
        case StarriorStates.Idle: 
            sprite_index = spriteActionIdle
        break 
        case StarriorStates.Attack:
            sprite_index = spriteActionAttack
            image_index = 0; 
            image_speed = 1;
        break   
        case StarriorStates.Cast:
            sprite_index = spriteActionAttack
            image_index = 0; 
            image_speed = 1;
        break      
    }
}

function getOriginalDeck() {
    return deck.originalDeck
}

function getCardsInHand() {
    return deck.cardsInHand
}

function getShuffeledDeck() {
    return deck.shuffeledDeck
}