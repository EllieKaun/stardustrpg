#macro ENEMYS_TURN 0
#macro PUPPET_TURN 1
#macro HERO_DRAW_DELAY 2
#macro MAX_PUPPETS 3

// Слабые места: модификатор урона (слабость +, сила −) и бонус к шансу статуса
#macro WEAKNESS_DAMAGE_MODIFIER 0.1
#macro WEAKNESS_STATUS_CHANCE_BONUS 0.1

// Лечение всего здоровья
#macro HEAL_FULL 999999

// Восстановление всей маны
#macro MANA_FULL 999999

enum CardsRarity {
    Default,
    Unusual,
    Rare,
    Epic
}

enum TargetTypes {
    SingleEnemyTarget,
    AllAllies,
    SingleAllyTarget,
    AllEnemies,
    Self
}

enum DamageTypes {
    Physical,
    Magical
}

enum ProtectionTypes {
    Physical,
    Magical
}

enum EffectTypes {
	Damage,
    Heal,
    Stun,
    Buff,
    RemoveEffect,
    ManaGain,
    Weakening,
    Debuff,
    CopyCard,
    AddEnergy,
    ShuffleDeck,
    Resurrection,
    IgnoreWeakness,
    CreateTemporaryWeakness,
    CreatePuppet
}

function effectTypeToString(type) {
    switch (type) {
        case EffectTypes.Damage: return "Damage"
        case EffectTypes.Heal: return "Heal"
        case EffectTypes.Stun: return "Stun"
        case EffectTypes.Buff: return "Buff"
        case EffectTypes.RemoveEffect: return "Remove Effect"
        case EffectTypes.ManaGain: return "Mana Gain"
        case EffectTypes.Weakening: return "Weakening"
        case EffectTypes.Debuff: return "Debuff"
        case EffectTypes.CopyCard: return "Copy Card"
        case EffectTypes.AddEnergy: return "Add Energy"
        case EffectTypes.ShuffleDeck: return "Shuffle Deck"
        case EffectTypes.Resurrection: return "Resurrection" 
        case EffectTypes.CreatePuppet: return "CreatePuppet"
        default: return "Unknown"
    }
}

enum StatusNames {
	Burn,
    Shock,
    Freeze,
    Bleeding,
    Stun,
    Bomb,
    Vampirism,
    Weakening
}

enum ModifiersToBuff {
    PhysicalDamage,
    MagicalDamage,
    AnyDamage,
    PhysicalProtection,
    MagicalProtection,
    AnyProtection
}

enum Timing {
	Instant,
    EndOfTurn,
    Overtime,
    OnActions
}

enum BattleStates {
    Preparing,
    DeckPreparing,
    CharacterPreparing,
    CharacterPlay,
    PlayProcess,
    PlayResult,
    AfterPlayChecks,
    BattleOver,
    EnemyTargetSelection,
    AllyTargetSelection,
    EnemysTurn,
    EnemyInfoSelection,
    EnemyInfoDisplay,
    Victory,
    GameOver,
    PuppetTurn,
    CardAnimating
}

enum StarriorStates {
	Idle,
    Attack,
    Cast,
    KnockOut,
    Spell,
    Spawn,
    Dance
}

enum CostType {
    Mana,
    Health
}

enum FocusArea {
    Menu,
    Deck
}

enum EffectVisualizerType {
    AnimationEnd,
    TimeBased
}

enum CardCategory { Attack, Magic, Heal, Buff, Special }

// Категория карты — данные реестра
function cardCategoryOf(_card) {
    if (is_struct(_card) && variable_struct_exists(_card, "cardId") && cardExists(_card.cardId)) {
        var def = global.cardRegistry[$ _card.cardId]
        if (variable_struct_exists(def, "category")) return def.category
    }
   
    if (_card.cardBaseSpr == atcCard) return CardCategory.Attack
    if (_card.cardBaseSpr == mgcCard) return CardCategory.Magic
    if (_card.cardBaseSpr == healCard) return CardCategory.Heal
    if (_card.cardBaseSpr == buffCard) return CardCategory.Buff
    return CardCategory.Attack
}

// Анимация кастера по категории карты: 
function cardAnimState(card) {
    switch (cardCategoryOf(card)) {
        case CardCategory.Attack: return StarriorStates.Attack
        case CardCategory.Magic: return StarriorStates.Spell
        default: return StarriorStates.Cast
    }
}

// Спрайт каста при призыве марионетки (по её категории), иначе noone
// Позволяет мастеру играть свою анимацию призыва под конкретную марионетку
function cardCastSpriteOverride(card) {
    for (var i = 0; i < array_length(card.effects); i++) {
        var e = card.effects[i]
        if (e.type == EffectTypes.CreatePuppet) {
            switch (e.puppetCategory) {
                case CardCategory.Attack: return MasterPuppetCreateAtc
                case CardCategory.Magic: return MasterPuppetCreateMgc
                case CardCategory.Heal: return MasterPuppetCreateHeal
                case CardCategory.Buff: return MasterPuppetCreateBuff
            }
        }
    }
    return noone
}

// Цвет категории
function categoryColor(category) {
    switch (category) {
        case CardCategory.Magic: return #9c65c8
        case CardCategory.Buff: return #77cce0
        case CardCategory.Heal: return #83c073
        case CardCategory.Attack: return #d56463
        case CardCategory.Special: return #c4c4c4
        default: return #c4c4c4
    }
}
