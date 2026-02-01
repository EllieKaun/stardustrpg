#macro ENEMYS_TURN 0 

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
    Resurrection
}

function effectTypeToString(type) {
    switch (type) {
        case EffectTypes.Damage:        return "Damage";
        case EffectTypes.Heal:          return "Heal";
        case EffectTypes.Stun:          return "Stun";
        case EffectTypes.Buff:          return "Buff";
        case EffectTypes.RemoveEffect:  return "Remove Effect";
        case EffectTypes.ManaGain:      return "Mana Gain";
        case EffectTypes.Weakening:     return "Weakening";
        case EffectTypes.Debuff:        return "Debuff";
        case EffectTypes.CopyCard:      return "Copy Card";
        case EffectTypes.AddEnergy:     return "Add Energy";
        case EffectTypes.ShuffleDeck:   return "Shuffle Deck";
        case EffectTypes.Resurrection:  return "Resurrection";
        default:                        return "Unknown";
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
    EnemysTurn
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
