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
    Magical,
    True
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
    CreatePuppet,
    Deflect,
    DrawCard,
    GainIngredient,
    DiscardRandomCard,
    Provoke,
    BonusHp,
    ExtendNegative,
    RemoveNegative,
    AddRandomCards
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
        case EffectTypes.Deflect: return loc("effect.Deflect")
        case EffectTypes.DrawCard: return loc("effect.DrawCard")
        case EffectTypes.GainIngredient: return loc("effect.GainIngredient")
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
    Weakening,
    Deflect,
    Poison,
    Provoke
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
    StunnedTurn,
    RunConfirm
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
    Info,
    Skip
}

enum BattleOutcome {
    Win,
    Lose
}

enum ZoneId {
    Forest
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

enum EnemyKind { None, CrackerNut, Leaf, Mushroom, Flower, PuppetMaster }

enum AiBrainType { Default, Brute, Skirmisher, Healer, Controller, Boss }

enum AiPolicy { Argmax, Softmax }

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

// Сила зависящая от карт в руке
enum HandScaling {
    None,
    MoreCard,
    FewerCards
}

// Ингредиенты в Лесном наборе
enum Ingredient {
	Flower, Mushroom, Leaf
}

// Комбинации ингредиентов для пустой колбы в зависимости от запаса ингредиентов
enum FlaskForm { Empty, Flower, Mushroom, Leaf, FlowerMushroom, FlowerLeaf, MushroomLeaf }

// Виды чармов
enum HandCharmKind { StatBonus }