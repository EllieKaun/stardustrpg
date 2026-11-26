function createCrackerNut() {
    var variant = crackerNutVariant()
    var starrior = createStarrior("CrackerNut",
        sprCrackerNutIdle, sprCrackerNutHit, sprCrackerNutCast, sprCrackerNutCast, sprCrackerNutIdle, noone,
        variant.hp, variant.hp,  0, 0,  1, 1, variant.strength, variant.intelligence, variant.aura, variant.guts,
        variant.deck,
        [ StatusNames.Stun ]); // слабость: Оглушение
    starrior.kind = EnemyKind.CrackerNut
    starrior.brain = brainPreset(AiBrainType.Brute)
    return starrior
}

function crackerNutVariant() {
    switch (irandom(2)) {
        case 0: return {
            hp: 9, strength: 3, intelligence: 0, aura: 0, guts: 0,
            deck: [
                createPhysicalDamageSingleTargetCard(),
                createPhysicalDamageSingleTargetCard(),
                createCardBuffPhysicalDamageSingleTarget(),
                createPhysicalDamageBleedingChanseSingleTargetCard(),
                createPhysicalDamageWeakeningChanseSingleTargetCard(),
                createPhysicalDamageStunChanseSingleTargetCard()
            ]
        }
        case 1: return {
            hp: 11, strength: 2, intelligence: 0, aura: 0, guts: 1,
            deck: [
                createPhysicalDamageStunChanseSingleTargetCard(),
                createPhysicalDamageStunChanseSingleTargetCard(),
                createPhysicalDamageSingleTargetCard(),
                createPhysicalDamageSingleTargetCard(),
                createPhysicalDamageBombChanseSingleTargetCard(),
                createCardBuffPhysicalDamageSingleTarget()
            ]
        }
        default: return {
            hp: 10, strength: 2, intelligence: 0, aura: 0, guts: 1,
            deck: [
                createPhysicalDamageMultipleTargetCard(),
                createPhysicalDamageStunChanseMultipleTargetCard(),
                createPhysicalDamageSingleTargetCard(),
                createPhysicalDamageSingleTargetCard(),
                createCardBuffPhysicalDamageSingleTarget(),
                createPhysicalDamageBleedingChanseSingleTargetCard()
            ]
        }
    }
}

function createLeaf() {
    var variant = leafVariant()
    var starrior = createStarrior("Leaf",
        HealLeafIdle, HealLeafAtk, HealLeafCast, HealLeafCast, HealLeafIdle, noone,
        variant.hp, variant.hp,  0, 0,  1, 1,  variant.strength, variant.intelligence, variant.aura, variant.guts,
        variant.deck,
        [ StatusNames.Burn ]) // слабость: Огонь
    starrior.kind = EnemyKind.Leaf
    starrior.brain = brainPreset(AiBrainType.Healer)
    return starrior
}

function leafVariant() {
    switch (irandom(2)) {
        case 0: return {
            hp: 13, strength: 1, intelligence: 1, aura: 1, guts: 0,
            deck: [
                createInstantHealSingleTargetCard(),
                createOvertimeHealSingleTargetCard(),
                createCardBuffMagicalProtectionSingleTarget(),
                createPhysicalDamageSingleTargetCard(),
                createPhysicalDamageSingleTargetCard(),
                createRemoveStatusBurnSingleTargetCard()
            ]
        }
        case 1: return {
            hp: 11, strength: 2, intelligence: 1, aura: 0, guts: 0,
            deck: [
                createPhysicalDamageWeakeningChanseSingleTargetCard(),
                createPhysicalDamageWeakeningChanseSingleTargetCard(),
                createCardDebuffPhysicalDamageSingleTarget(),
                createCardDebuffMagicalDamageSingleTarget(),
                createInstantHealSingleTargetCard(),
                createPhysicalDamageSingleTargetCard()
            ]
        }
        default: return {
            hp: 14, strength: 1, intelligence: 1, aura: 1, guts: 1,
            deck: [
                createInstantMultipleTargetsHealCard(),
                createCardBuffAnyProtectionMultipleTarget(),
                createInstantHealSingleTargetCard(),
                createOvertimeHealSingleTargetCard(),
                createRemoveStatusBurnSingleTargetCard(),
                createPhysicalDamageSingleTargetCard()
            ]
        }
    }
}

function createMushroom() {
    var variant = mushroomVariant()
    var starrior = createStarrior("Mushroom",
        sprMushroomIdle, sprMushroomAttack, sprMushroomCast, sprMushroomCast, sprMushroomIdle, noone,
        variant.hp, variant.hp,  0, 0,  1, 1,  variant.strength, variant.intelligence, variant.aura, variant.guts,
        variant.deck,
        [ StatusNames.Bomb ]) // слабость: Взрыв
    starrior.kind = EnemyKind.Mushroom
    starrior.brain = brainPreset(AiBrainType.Brute)
    return starrior
}

function mushroomVariant() {
    switch (irandom(2)) {
        case 0: return {
            hp: 9, strength: 3, intelligence: 0, aura: 0, guts: 0,
            deck: [
                createPhysicalDamageVampirismChanseSingleTargetCard(),
                createPhysicalDamageVampirismChanseSingleTargetCard(),
                createPhysicalDamageSingleTargetCard(),
                createCardDebuffPhysicalProtectionSingleTarget(),
                createCardBuffPhysicalDamageSingleTarget(),
                createPhysicalDamageBleedingChanseSingleTargetCard()
            ]
        }
        case 1: return {
            hp: 9, strength: 2, intelligence: 0, aura: 0, guts: 1,
            deck: [
                createCardDebuffPhysicalProtectionSingleTarget(),
                createCardDebuffPhysicalProtectionSingleTarget(),
                createCardDebuffMagicalProtectionSingleTarget(),
                createPhysicalDamageSingleTargetCard(),
                createPhysicalDamageSingleTargetCard(),
                createPhysicalDamageVampirismChanseSingleTargetCard()
            ]
        }
        default: return {
            hp: 8, strength: 2, intelligence: 0, aura: 0, guts: 0,
            deck: [
                createPhysicalDamageVampirismChanceMultipleTargetCard(),
                createPhysicalDamageBleedingChanseMultipleTargetCard(),
                createPhysicalDamageVampirismChanseSingleTargetCard(),
                createCardDebuffPhysicalProtectionSingleTarget(),
                createPhysicalDamageSingleTargetCard(),
                createPhysicalDamageSingleTargetCard()
            ]
        }
    }
}

function createFlower() {
    var variant = flowerVariant()
    var starrior = createStarrior("Flower",
        sprPowerFlowerIdle, sprPowerFlowerAttack, sprPowerFlowerSpell, sprPowerFlowerCast, sprPowerFlowerIdle, noone,
        variant.hp, variant.hp,  0, 0,  1, 1,  variant.strength, variant.intelligence, variant.aura, variant.guts,
        variant.deck,
        [ StatusNames.Freeze ]) // слабость: Лёд
    starrior.kind = EnemyKind.Flower
    starrior.brain = brainPreset(AiBrainType.Skirmisher)
    return starrior
}

function flowerVariant() {
    switch (irandom(2)) {
        case 0: return {
            hp: 8, strength: 1, intelligence: 3, aura: 0, guts: 0,
            deck: [
                createMagicalDamageBurnChanseSingleTargetCard(),
                createMagicalDamageBurnChanseSingleTargetCard(),
                createMagicalDamageSingleTargetCard(),
                createCardBuffMagicalDamageSingleTarget(),
                createMagicalDamageStunChanseSingleTargetCard(),
                createPhysicalDamageSingleTargetCard()
            ]
        }
        case 1: return {
            hp: 9, strength: 1, intelligence: 3, aura: 1, guts: 0,
            deck: [
                createMagicalDamageFreezingChanceSingleTargetCard(),
                createMagicalDamageFreezingChanceSingleTargetCard(),
                createMagicalDamageStunChanseSingleTargetCard(),
                createMagicalDamageSingleTargetCard(),
                createCardCreateTemporaryWeaknessMagicalDamageSingleTarget(),
                createCardBuffMagicalDamageSingleTarget()
            ]
        }
        default: return {
            hp: 8, strength: 1, intelligence: 3, aura: 0, guts: 0,
            deck: [
                createCardCreateTemporaryWeaknessMagicalDamageSingleTarget(),
                createMagicalDamageMultipleTargetCard(),
                createMagicalDamageStunChanseSingleTargetCard(),
                createMagicalDamageSingleTargetCard(),
                createMagicalDamageSingleTargetCard(),
                createCardBuffMagicalDamageSingleTarget()
            ]
        }
    }
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
