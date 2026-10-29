function createCrackerNut() {
    var starrior = createStarrior("CrackerNut",
        sprCrackerNutIdle, sprCrackerNutHit, sprCrackerNutCast, sprCrackerNutCast, sprCrackerNutIdle, noone,
        10, 10,  0, 0,  1, 1, /*str*/2, /*int*/0, /*aura*/0, /*guts*/0,
        [
            createPhysicalDamageSingleTargetCard(),
            createPhysicalDamageStunChanseSingleTargetCard(),
            createCardBuffPhysicalDamageSingleTarget()
        ],
        [ StatusNames.Stun ]); // слабость: Оглушение
    starrior.kind = EnemyKind.CrackerNut
    starrior.brain = brainPreset(AiBrainType.Brute)
    return starrior
}

function createLeaf() {
    var starrior = createStarrior("Leaf",
        HealLeafIdle, HealLeafAtk, HealLeafCast, HealLeafCast, HealLeafIdle, noone,
        12, 12,  0, 0,  1, 1,  /*str*/1, /*int*/1, /*aura*/0, /*guts*/0,
        [
            createPhysicalDamageSingleTargetCard(),
            createPhysicalDamageWeakeningChanseSingleTargetCard(),
            createInstantHealSingleTargetCard()
        ],
        [ StatusNames.Burn ]) // слабость: Огонь
    starrior.kind = EnemyKind.Leaf
    starrior.brain = brainPreset(AiBrainType.Healer)
    return starrior
}

function createMushroom() {
    var starrior = createStarrior("Mushroom",
        sprMushroomIdle, sprMushroomAttack, sprMushroomCast, sprMushroomCast, sprMushroomIdle, noone,
        8, 8,  0, 0,  1, 1,  /*str*/3, /*int*/0, /*aura*/0, /*guts*/0,
        [
            createPhysicalDamageSingleTargetCard(),
            createPhysicalDamageVampirismChanseSingleTargetCard(),
            createCardDebuffPhysicalProtectionSingleTarget()
        ],
        [ StatusNames.Bomb ]) // слабость: Взрыв
    starrior.kind = EnemyKind.Mushroom
    starrior.brain = brainPreset(AiBrainType.Brute)
    return starrior
}

function createFlower() {
    var starrior = createStarrior("Flower",
        sprPowerFlowerIdle, sprPowerFlowerAttack, sprPowerFlowerSpell, sprPowerFlowerCast, sprPowerFlowerIdle, noone,
        8, 8,  0, 0,  1, 1,  /*str*/1, /*int*/3, /*aura*/0, /*guts*/0,
        [
            createPhysicalDamageSingleTargetCard(),
            createMagicalDamageStunChanseSingleTargetCard(),
            createCardBuffMagicalDamageSingleTarget()
        ],
        [ StatusNames.Freeze ]) // слабость: Лёд
    starrior.kind = EnemyKind.Flower
    starrior.brain = brainPreset(AiBrainType.Skirmisher)
    return starrior
}

function createPuppetMaster() {
    var starrior = createStarrior("Puppet Master",
        MasterPuppetIdle, MasterPuppetAtk, MasterPuppetCast, MasterPuppetCast, MasterPuppetIdle, noone,
        40, 40,  0, 0,  2, 2,  /*str*/10, /*int*/12, /*aura*/6, /*guts*/6,
        [
            createMagicalDamageSingleTargetCard(),
            createPhysicalDamageVampirismChanseSingleTargetCard(),
            createPhysicalDamageSingleTargetCard(),
            createSummonAttackPuppetCard(),
            createSummonMagicPuppetCard(),
            createSummonBuffPuppetCard(),
            createSummonAttackPuppetCard(),
            createSummonHealPuppetCard(),
        ])
    starrior.kind = EnemyKind.PuppetMaster
    starrior.brain = brainPreset(AiBrainType.Boss)
    return starrior
}