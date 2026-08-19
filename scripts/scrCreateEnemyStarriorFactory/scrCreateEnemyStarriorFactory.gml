function createCrackerNut() { 
    return createStarrior("CrackerNut",
        sprCrackerNutIdle, sprCrackerNutHit, sprCrackerNutCast, sprCrackerNutCast, sprCrackerNutIdle, noone,
        16, 16,  0, 0,  1, 1, /*str*/3, /*int*/1, /*aura*/0, /*guts*/0,
        [
            createPhysicalDamageSingleTargetCard(),
            createPhysicalDamageStunChanseSingleTargetCard(),
            createCardBuffPhysicalDamageSingleTarget()
        ],
        [ StatusNames.Stun ]);   // слабость: Оглушение
}

function createLeaf() {
    return createStarrior("Leaf",
        HealLeafIdle, HealLeafAtk, HealLeafCast, HealLeafCast, HealLeafIdle, noone,
        20, 20,  0, 0,  1, 1,  /*str*/2, /*int*/2, /*aura*/0, /*guts*/0,
        [
            createPhysicalDamageSingleTargetCard(),
            createPhysicalDamageWeakeningChanseSingleTargetCard(),
            createInstantHealSingleTargetCard()
        ],
        [ StatusNames.Burn ])   // слабость: Огонь
}

function createMushroom() {
    return createStarrior("Mushroom",
        sprMushroomIdle, sprMushroomAttack, sprMushroomCast, sprMushroomCast, sprMushroomIdle, noone,
        12, 12,  0, 0,  1, 1,  /*str*/4, /*int*/1, /*aura*/0, /*guts*/0,
        [
            createPhysicalDamageSingleTargetCard(),
            createPhysicalDamageVampirismChanseSingleTargetCard(),
            createCardDebuffPhysicalProtectionSingleTarget()
        ],
        [ StatusNames.Bomb ])   // слабость: Взрыв
}

function createFlower() {
    return createStarrior("Flower",
        sprPowerFlowerIdle, sprPowerFlowerAttack, sprPowerFlowerSpell, sprPowerFlowerCast, sprPowerFlowerIdle, noone,
        12, 12,  0, 0,  1, 1,  /*str*/2, /*int*/4, /*aura*/0, /*guts*/0,
        [
            createPhysicalDamageSingleTargetCard(),
            createMagicalDamageStunChanseSingleTargetCard(),
            createCardBuffMagicalDamageSingleTarget()
        ],
        [ StatusNames.Freeze ])   // слабость: Лёд
}

function createPuppetMaster() {
    return createStarrior("Puppet Master",
        MasterPuppetIdle, MasterPuppetAtk, MasterPuppetCast, MasterPuppetCast, MasterPuppetIdle, noone,
        40, 40,  0, 0,  2, 2,  /*str*/4, /*int*/5, /*aura*/2, /*guts*/2,
        [
            createMagicalDamageSingleTargetCard(),
            createSummonAttackPuppetCard(),
            createSummonHealPuppetCard(),
        ])
}