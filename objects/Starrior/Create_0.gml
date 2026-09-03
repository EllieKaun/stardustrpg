name = ""
isActive = false
isTarget = false
themeColor = c_fuchsia

hp = 0
maxHp = 0
mana = 0
maxMana = 0
energy = 0
maxEnergy = 0

// Плавная анимация полосок хп и маны
displayHp = 0
displayMana = 0
hpBarReady = false

// Характеристики 
intelligence = 0
strength = 0
guts = 0
aura = 0
resistense = 0
isEnemy = false
isPuppet = false
effects = []
weaknesses = []
strengths = []
effectNotifications = []

deck = new Deck([])

// Исчезновение врага при смерти
disappearing = false
disappearTimer = 0
gone = false
disappearSurf = -1
disappearMaskSpr = sprDisappear 

// Спрайты
actionState = StarriorStates.Idle
spriteActionIdle = sprLanaBattleIdle
spriteActionAttack = sprLanaBattleIdle
spriteActionCast = sprLanaBatlleCast
spriteActionSpell = sprLanaBattleSpell
spriteActionSpawn = noone
spriteActionDance = noone
spriteActionKO = sprLanaBattleKO

// Коллбэк
actionCallback = undefined

function changeActionState(state, callback, spriteOverride = noone) {
    actionState = state
    actionCallback = callback

    switch (actionState) {
        case StarriorStates.Idle: 
            sprite_index = spriteActionIdle
        break 
        case StarriorStates.Attack:
            sprite_index = spriteActionAttack
            image_index = 0
            image_speed = 1
        break
        case StarriorStates.Cast:
            sprite_index = spriteActionCast
            image_index = 0
            image_speed = 1
        break
        case StarriorStates.Spell:
            sprite_index = spriteActionSpell
            image_index = 0
            image_speed = 1
        break
        case StarriorStates.Spawn:
            sprite_index = spriteActionSpawn
            image_index = 0
            image_speed = 1
        break
        case StarriorStates.Dance:
            sprite_index = spriteActionDance
            image_index = 0
            image_speed = 1
        break
        case StarriorStates.KnockOut:
            sprite_index = spriteActionKO
            image_index = 0;
            if image_number > 1 {
                image_speed = 1
            } else {
                image_speed = 0
            }
        break
    }

    if (spriteOverride != noone) {
        sprite_index = spriteOverride
        image_index = 0
        image_speed = 1
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

    if (hp <= 0 && isEnemy && !isPuppet && !disappearing && !gone) {
        disappearing = true
        disappearTimer = 0
    }
    var spawnX = irandom_range(bbox_left, bbox_right)
    var spawnY = irandom_range(bbox_top, bbox_bottom)
    drawDamageNumber(spawnX, spawnY, value, c_red)
}

function applyHeal(value) {
    var healed = min(value, max(0, maxHp - hp))   // не выше максимума
    hp += healed
    var spawnX = irandom_range(bbox_left, bbox_right)
    var spawnY = irandom_range(bbox_top, bbox_bottom)
    drawDamageNumber(spawnX, spawnY, healed, c_green)
}

function applyMana(value) {
    var gained = min(value, max(0, maxMana - mana))   // не выше максимума
    mana += gained
    var spawnX = irandom_range(bbox_left, bbox_right)
    var spawnY = irandom_range(bbox_top, bbox_bottom)
    drawDamageNumber(spawnX, spawnY, gained, c_blue)
}

function isKO() {
    return hp <= 0
}

function showEffectNotification(effect, dismissMode, duration) {
    if (variable_instance_exists(effect, "sound") && effect.sound != noone) {
        playSfx(effect.sound, 1, false)
    }
    if !variable_instance_exists(effect, "sprite") { return }
    var inst = instance_create_depth(x, y, depth - 1, oEffectVisualizer)
    inst.sprite_index = effect.sprite
    inst.image_speed = 1
    inst.image_index = 0
    inst.dismissMode = dismissMode
    inst.target = id
    
    if (dismissMode == EffectVisualizerType.TimeBased) {
        inst.alarm[0] = duration * game_get_speed(gamespeed_fps)
    }
}