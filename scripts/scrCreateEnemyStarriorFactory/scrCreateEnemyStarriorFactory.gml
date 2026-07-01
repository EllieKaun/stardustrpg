function createCrackerNut() { 
    return createStarrior("CrackerNut",
        sprCrackerNutIdle, sprCrackerNutIdle, sprCrackerNutIdle, sprCrackerNutIdle, 
        16, 16,  0, 0,  1, 1, /*str*/2, /*int*/0, /*aura*/0, /*guts*/0,
        [
            createPhysicalDamageSingleTargetCard(), 
            createPhysicalDamageStunChanseSingleTargetCard(),
            createCardBuffPhysicalDamageSingleTarget() 
        ]);
}

function createLeaf() {
    return createStarrior("Leaf",
        HealLeaf, HealLeaf, HealLeaf, HealLeaf,
        20, 20,  0, 0,  1, 1,  /*str*/1, /*int*/1, /*aura*/0, /*guts*/0,
        [
            createPhysicalDamageSingleTargetCard(), 
            createPhysicalDamageWeakeningChanseSingleTargetCard(),
            createInstantHealSingleTargetCard() 
        ])
}

function createMushroom() {
    return createStarrior("Mushroom",
        sprMushroom, sprMushroom, sprMushroom, sprMushroom,
        12, 12,  0, 0,  1, 1,  /*str*/3, /*int*/0, /*aura*/0, /*guts*/0,
        [
            createPhysicalDamageSingleTargetCard(),
            createPhysicalDamageVampirismChanseSingleTargetCard(),
            createCardDebuffPhysicalProtectionSingleTarget() 
        ])
}

function createFlower() {
    return createStarrior("Flower",
        PowerFlower, PowerFlower, PowerFlower, PowerFlower,
        12, 12,  0, 0,  1, 1,  /*str*/1, /*int*/3, /*aura*/0, /*guts*/0,
        [
            createPhysicalDamageSingleTargetCard(), 
            createMagicalDamageSingleTargetCard(),
            createCardBuffMagicalDamageSingleTarget()
        ])
}

function createPuppetMaster() {
    return createStarrior("Puppet Master",
        sprCrackerNutIdle, sprCrackerNutIdle, sprCrackerNutIdle, sprCrackerNutIdle,
        40, 40,  0, 0,  2, 2,  /*str*/3, /*int*/4, /*aura*/2, /*guts*/2,
        [
            createMagicalDamageSingleTargetCard(),
            createSummonAttackPuppetCard(),
            createSummonHealPuppetCard(),
        ])
}