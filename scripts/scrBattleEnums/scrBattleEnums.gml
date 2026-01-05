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

enum EffectTypes {
	Damage
}

enum Timing {
	Instant,
    EndOfTurn
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

enum StarriorStates {
	Idle,
    Attack,
    Cast,
    KnockOut
}
