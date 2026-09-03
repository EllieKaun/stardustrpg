function createCrackerNut() { 
    return createStarrior("CrackerNut",
        sprCrackerNutIdle, sprCrackerNutHit, sprCrackerNutCast, sprCrackerNutCast, sprCrackerNutIdle, noone,
        16, 16,  0, 0,  1, 1, /*str*/9, /*int*/3, /*aura*/3, /*guts*/3,
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
        20, 20,  0, 0,  1, 1,  /*str*/6, /*int*/6, /*aura*/3, /*guts*/3,
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
        12, 12,  0, 0,  1, 1,  /*str*/10, /*int*/3, /*aura*/3, /*guts*/3,
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
        12, 12,  0, 0,  1, 1,  /*str*/6, /*int*/10, /*aura*/3, /*guts*/3,
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
        40, 40,  0, 0,  2, 2,  /*str*/10, /*int*/12, /*aura*/6, /*guts*/6,
        [
            createMagicalDamageSingleTargetCard(),
            createSummonAttackPuppetCard(),
            createSummonHealPuppetCard(),
        ])
}