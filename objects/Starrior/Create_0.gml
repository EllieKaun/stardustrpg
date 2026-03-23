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
effectNotifications = []

deck = new Deck([])

actionState = StarriorStates.Idle
spriteActionIdle = sprLanaBattleIdle
spriteActionAttack = sprLanaBattleIdle
spriteActionCast = sprLanaBatlleCast
spriteActionKO = sprLanaBattleKO
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
            sprite_index = spriteActionKO
            image_index = 0; 
            if image_number > 1 {
                image_speed = 1;
            } else {
                image_speed = 0;
            }
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
    if hp <= 0 && actionState != StarriorStates.KnockOut {
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

function showEffectNotification(effect, dismissMode, duration) {
    var effectType = effect.type
    var statusName = variable_instance_exists(effect, "statusName") ? effect.statusName : undefined
    var spr = getEffectSprite(effectType, statusName)
    
    var inst = instance_create_depth(x, y, depth - 1, oEffectVisualizer)
    inst.sprite_index = spr
    inst.image_speed = 1
    inst.image_index = 0
    inst.dismissMode = dismissMode
    inst.target = id
    
    if (dismissMode == EffectVisualizerType.TimeBased) {
        inst.alarm[0] = duration * game_get_speed(gamespeed_fps)
    }
}

function getEffectSprite(effectType, statusName) {
    if !is_undefined(statusName) {
        switch(statusName) {
            case StatusNames.Burn: return removeBleedingEffect
            case StatusNames.Shock: return removeBleedingEffect
            case StatusNames.Freeze: return removeBleedingEffect
            case StatusNames.Bleeding: return removeBleedingEffect
            case StatusNames.Stun: return removeBleedingEffect
            case StatusNames.Bomb: return removeBleedingEffect
            case StatusNames.Vampirism: return removeBleedingEffect
            case StatusNames.Weakening: return removeBleedingEffect
        }
    }
    
    switch(effectType) {
        case EffectTypes.Damage: return removeBleedingEffect
        case EffectTypes.Heal: return removeBleedingEffect
        case EffectTypes.Buff: return removeBleedingEffect
        case EffectTypes.Debuff: return removeBleedingEffect
        case EffectTypes.ManaGain: return removeBleedingEffect
        case EffectTypes.Weakening: return removeBleedingEffect
        case EffectTypes.CopyCard: return removeBleedingEffect
        case EffectTypes.AddEnergy: return removeBleedingEffect
        case EffectTypes.ShuffleDeck: return removeBleedingEffect
        default: return removeBleedingEffect
    }
}