function createCrackerNut() { 
    return createStarrior("CrackerNut",
        sprCrackerNutIdle, sprCrackerNutHit, sprCrackerNutCast, sprCrackerNutCast, sprCrackerNutIdle, noone,
        10, 10,  0, 0,  1, 1, /*str*/2, /*int*/0, /*aura*/0, /*guts*/0,
        [
            createPhysicalDamageSingleTargetCard(),
            createPhysicalDamageStunChanseSingleTargetCard(),
            createCardBuffPhysicalDamageSingleTarget()
        ],
        [ StatusNames.Stun ]); // слабость: Оглушение
}

function createLeaf() {
    return createStarrior("Leaf",
        HealLeafIdle, HealLeafAtk, HealLeafCast, HealLeafCast, HealLeafIdle, noone,
        12, 12,  0, 0,  1, 1,  /*str*/1, /*int*/1, /*aura*/0, /*guts*/0,
        [
            createPhysicalDamageSingleTargetCard(),
            createPhysicalDamageWeakeningChanseSingleTargetCard(),
            createInstantHealSingleTargetCard()
        ],
        [ StatusNames.Burn ]) // слабость: Огонь
}

function createMushroom() {
    return createStarrior("Mushroom",
        sprMushroomIdle, sprMushroomAttack, sprMushroomCast, sprMushroomCast, sprMushroomIdle, noone,
        8, 8,  0, 0,  1, 1,  /*str*/3, /*int*/0, /*aura*/0, /*guts*/0,
        [
            createPhysicalDamageSingleTargetCard(),
            createPhysicalDamageVampirismChanseSingleTargetCard(),
            createCardDebuffPhysicalProtectionSingleTarget()
        ],
        [ StatusNames.Bomb ]) // слабость: Взрыв
}

function createFlower() {
    return createStarrior("Flower",
        sprPowerFlowerIdle, sprPowerFlowerAttack, sprPowerFlowerSpell, sprPowerFlowerCast, sprPowerFlowerIdle, noone,
        8, 8,  0, 0,  1, 1,  /*str*/1, /*int*/3, /*aura*/0, /*guts*/0,
        [
            createPhysicalDamageSingleTargetCard(),
            createMagicalDamageStunChanseSingleTargetCard(),
            createCardBuffMagicalDamageSingleTarget()
        ],
        [ StatusNames.Freeze ]) // слабость: Лёд
}

function createPuppetMaster() {
    return createStarrior("Puppet Master",
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
}