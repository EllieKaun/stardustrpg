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

effects = []
weaknesses = []
strengths = []

deck = new Deck([])

actionState = StarriorStates.Idle
spriteActionIdle = sprLanaBattleIdle
spriteActionAttack = sprLanaBattleIdle
spriteActionCast = sprLanaBatlleCast
spriteKO = sprLanaBattleKO
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
        case StarriorStates.KnockOut:
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

function hasWeakness(weaknessType) {
    for(var i = 0; i < array_length(weaknesses); i++) {
        var weakness = weaknesses[i]
        if weakness == weaknessType {
            return true
        }
    }
    return false
}

function applyDamage(value) {
    hp -= value
    if hp <= 0 {
        changeActionState(StarriorStates.KnockOut, undefined)
    }
    var spawnX = irandom_range(bbox_left, bbox_right)
    var spawnY = irandom_range(bbox_top, bbox_bottom)
    drawDamageNumber(spawnX, spawnY, value, c_red)
}

function applyHeal(value) {
    hp += value
    var spawnX = irandom_range(bbox_left, bbox_right)
    var spawnY = irandom_range(bbox_top, bbox_bottom)
    drawDamageNumber(spawnX, spawnY, value, c_green)
}

function applyMana(value) {
    mana += value
    var spawnX = irandom_range(bbox_left, bbox_right)
    var spawnY = irandom_range(bbox_top, bbox_bottom)
    drawDamageNumber(spawnX, spawnY, value, c_blue)
}

function isKO() {
    return hp <= 0
}