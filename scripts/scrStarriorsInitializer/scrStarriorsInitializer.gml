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
            [
                createPhysicalDamageVampirismChanceMultipleTargetCard(),
                createPhysicalDamageVampirismChanceMultipleTargetCard(),
                createPhysicalDamageVampirismChanceMultipleTargetCard(),
                createAddEnergyCard()
           // createOvertimeHealSingleTargetCard(),
           // createPhysicalDamageCardDefault(),
            //createPhysicalDamageCardDefault(),
            //createPhysicalDamageCardDefault()
        ])
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
        [
        createPhysicalDamageSingleTargetCard(),
        createPhysicalDamageVampirismChanceMultipleTargetCard()
        ]
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
            10, 
            10, 
            -1,
            -1,
            1,
            1,
            10,
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
            76, 
            76, 
            -1,
            -1,
            1,
            1,
            10,
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
            76, 
            76, 
            -1,
            -1,
            1,
            1,
            10,
            0,
            0,
            0,
            [createPhysicalDamageWeakeningChanseSingleTargetCard()])
    ]
}