#macro ENEMYS_TURN 0
#macro PUPPET_TURN 1
#macro HERO_DRAW_DELAY 2
#macro STUN_TURN 3 // alarm конца хода оглушённого персонажа

// Сколько секунд ход оглушённого персонажа виден до передачи следующему
#macro STUN_TURN_SECONDS 3

// Через сколько секунд простоя выбранный герой начинает танцевать
#macro IDLE_DANCE_SECONDS 5
#macro MAX_PUPPETS 3

#macro MAX_STARRIORS_PER_SIDE 5

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
        case EffectTypes.Damage: return loc("effect.Damage")
        case EffectTypes.Heal: return loc("effect.Heal")
        case EffectTypes.Stun: return loc("effect.Stun")
        case EffectTypes.Buff: return loc("effect.Buff")
        case EffectTypes.RemoveEffect: return loc("effect.RemoveEffect")
        case EffectTypes.ManaGain: return loc("effect.ManaGain")
        case EffectTypes.Weakening: return loc("effect.Weakening")
        case EffectTypes.Debuff: return loc("effect.Debuff")
        case EffectTypes.CopyCard: return loc("effect.CopyCard")
        case EffectTypes.AddEnergy: return loc("effect.AddEnergy")
        case EffectTypes.ShuffleDeck: return loc("effect.ShuffleDeck")
        case EffectTypes.Resurrection: return loc("effect.Resurrection")
        case EffectTypes.CreatePuppet: return loc("effect.CreatePuppet")
        default: return loc("effect.Unknown")
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
    CharacterPlay,
    PlayProcess,
    AfterPlayChecks,
    EnemyTargetSelection,
    AllyTargetSelection,
    EnemysTurn,
    EnemyInfoSelection,
    EnemyInfoDisplay,
    Victory,
    GameOver,
    PuppetTurn,
    CardAnimating,
    StunnedTurn
}

enum StateHook {
    OnEnter,
    OnExit,
    Step,
    DrawUnder,
    DrawOver,
    OnCancel,
    Reentrant,
    Count
}

enum BattleMenuAction {
    Shuffle,
    Run,
    Info
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
        var cardDefinition = global.cardRegistry[$ _card.cardId]
        if (variable_struct_exists(cardDefinition, "category")) { return cardDefinition.category }
    }

    if (!is_struct(_card) || !variable_struct_exists(_card, "cardBaseSpr")) { return CardCategory.Attack }

    if (_card.cardBaseSpr == atcCard) { return CardCategory.Attack }
    if (_card.cardBaseSpr == mgcCard) { return CardCategory.Magic }
    if (_card.cardBaseSpr == healCard) { return CardCategory.Heal }
    if (_card.cardBaseSpr == buffCard) { return CardCategory.Buff }
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

// Спрайт каста при призыве марионетки (по её категории)
// Спрайты MasterPuppetCreate* - анимация босса и смотрит влево, поэтому подменяем только у врага.
// Герой (например, с украденной у босса картой) кастует своей обычной анимацией
function cardCastSpriteOverride(card, caster) {
    if (!caster.isEnemy) { return noone }
    for (var i = 0; i < array_length(card.effects); i++) {
        var effect = card.effects[i]
        if (variable_struct_exists(effect, "type") && effect.type == EffectTypes.CreatePuppet) {
            switch (effect.puppetCategory) {
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
