#macro ENEMYS_TURN 0 

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
    AllEnemies
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
    CreateTemporaryWeakness
}

function effectTypeToString(type) {
    switch (type) {
        case EffectTypes.Damage:        return "Damage"
        case EffectTypes.Heal:          return "Heal"
        case EffectTypes.Stun:          return "Stun"
        case EffectTypes.Buff:          return "Buff"
        case EffectTypes.RemoveEffect:  return "Remove Effect"
        case EffectTypes.ManaGain:      return "Mana Gain"
        case EffectTypes.Weakening:     return "Weakening"
        case EffectTypes.Debuff:        return "Debuff"
        case EffectTypes.CopyCard:      return "Copy Card"
        case EffectTypes.AddEnergy:     return "Add Energy"
        case EffectTypes.ShuffleDeck:   return "Shuffle Deck"
        case EffectTypes.Resurrection:  return "Resurrection"
        default:                        return "Unknown"
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
    GameOver
}

enum StarriorStates {
	Idle,
    Attack,
    Cast,
    KnockOut
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

enum CardCategory { Attack, Magic, Heal, Buff }

function cardCategoryOf(_card) {
    if (_card.cardBaseSpr == atcCard)  return CardCategory.Attack;
    if (_card.cardBaseSpr == mgcCard)  return CardCategory.Magic;
    if (_card.cardBaseSpr == healCard) return CardCategory.Heal;
    if (_card.cardBaseSpr == buffCard) return CardCategory.Buff;
    return CardCategory.Attack;
}
