enum TargetTypes {
    SingleTarget,
    AllTargets
}

enum DamageTypes {
    Physical,
    Magical
}

enum ProtectionTypes {
    Physical,
    Magical
}

enum MagicalDamageTypes {
    Fire,
    Ice,
    Electricity,
    Stars
}

enum PhysicalDamageEffectTypes {
    Bleeding,
    Explosion,
    ActionWeakening,
    Vampirism,
    Stun
}

enum MagicalDamageEffectTypes {
    Burn,
    Freezing,
    Shock
}

enum CardAbilityTypes {
    Attack,
    AttackWithPhysicalEffect,
    BuffDamage,
    BuffProtection,
    DebuffDamage,
    DebuffProtection,
    CreateWeakness,
    InstantHealHp,
    OvertimeHealHp,
    InstantManaGain,
    RemoveEffect,
    Revival,
    AttackWithMagicalEffect,
    CopyNexPlayedCard,
    AddEnergyToPlayer,
    ShuffleDeck,
    FindWeakness,
    RemoveWeaknessForXTurns
}

enum BattleStates { 
    Preparing, 
    DeckPreparing, 
    CharacterPreparing,
    CharacterPlay, 
    PlayProcess, 
    PlayResult, 
    AfterPlayChecks, 
    BattleOver 
}