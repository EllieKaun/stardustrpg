function createLana(){
    var starrior = createStarrior("Lana",    
            sprLanaBattleIdle, 
            sprLanaBattleSpell,
            sprLanaBatlleCast,
            sprLanaBattleKO,
            30, 
            60, 
            70,
            70,
            1,
            1,
            2,
            4,
            3,
            1,
            playerDeckFor(Characters.Lana) 
    )
    return starrior
}


function createViv(){
    return createStarrior(
        "Viv", 
        sprVivBatlleIdle,
        sprVivBattleAttack,
        sprVivBattleAttack,
        sprVivBattleKO,
        30, 
        76, 
        50,
        50,
        1,
        1,
        4,
        2,
        1,
        3,
        playerDeckFor(Characters.Viv) 
    )
}

function createEnemiesLevel1() {
    return [
        createStarrior(
            "Cracker1",
            sprCrackerNutIdle, 
            sprCrackerNutIdle, 
            sprCrackerNutIdle, 
            sprCrackerNutIdle, 
            1, 
            10, 
            -1,
            -1,
            1,
            1,
            1,
            0,
            0,
            0,
            [createPhysicalDamageWeakeningChanseSingleTargetCard()]),
        createStarrior(
            "Cracker2",
            sprCrackerNutIdle, 
            sprCrackerNutIdle,
            sprCrackerNutIdle, 
            sprCrackerNutIdle,  
            1, 
            10, 
            -1,
            -1,
            1,
            1,
            1,
            0,
            0,
            0,
            [createPhysicalDamageWeakeningChanseSingleTargetCard()]), 
        createStarrior(
            "Cracker3",
            sprCrackerNutIdle, 
            sprCrackerNutIdle, 
            sprCrackerNutIdle, 
            sprCrackerNutIdle, 
            1, 
            10, 
            -1,
            -1,
            1,
            1,
            1,
            0,
            0,
            0,
            [createPhysicalDamageWeakeningChanseSingleTargetCard()])
    ]
}


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
        ]);
}

function createMushroom() {
    return createStarrior("Mushroom",
        sprMushroom, sprMushroom, sprMushroom, sprMushroom,
        12, 12,  0, 0,  1, 1,  /*str*/3, /*int*/0, /*aura*/0, /*guts*/0,
        [
            createPhysicalDamageSingleTargetCard(),
            createPhysicalDamageVampirismChanseSingleTargetCard(),
            createCardDebuffPhysicalProtectionSingleTarget() 
        ]);
}

function createFlower() {
    return createStarrior("Flower",
        PowerFlower, PowerFlower, PowerFlower, PowerFlower,
        12, 12,  0, 0,  1, 1,  /*str*/1, /*int*/3, /*aura*/0, /*guts*/0,
        [
            createPhysicalDamageSingleTargetCard(), 
            createMagicalDamageSingleTargetCard(),
            createCardBuffMagicalDamageSingleTarget()
        ]);
}
