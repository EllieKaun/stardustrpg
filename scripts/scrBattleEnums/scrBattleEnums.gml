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
    Buff
}
enum ModifiersToBuff {
    PhysicalDamage,
    MagicalDamage,
    AnyDamage
}
enum Timing {
	Instant,
    EndOfTurn,
    Overtime,
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
