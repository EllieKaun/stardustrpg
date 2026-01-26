function createLana(){
    var starrior = createStarrior("Lana",    
            sprLanaBattleIdle, 
            sprLanaBattleSpell,
            30, 
            60, 
            70,
            70,
            1,
            1,
            2,
            4,
            12,
            8,
            [
                createPhysicalDamageVampirismChanceMultipleTargetCard(),
                createPhysicalDamageVampirismChanceMultipleTargetCard(),
                createPhysicalDamageVampirismChanceMultipleTargetCard(),
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
        30, 
        76, 
        50,
        50,
        1,
        1,
        4,
        2,
        8,
        14,
        [
        createPhysicalDamageSingleTargetCard(),
        createPhysicalDamageVampirismChanceMultipleTargetCard()
        ]
    )
}

function createEnemiesLevel1() {
    return [
        createStarrior(
            "Bird1",
            sprCrackerNutIdle, 
            sprCrackerNutIdle, 
            76, 
            76, 
            -1,
            -1,
            1,
            1,
            3,
            1,
            0,
            1,
            [createPhysicalDamageWeakeningChanseSingleTargetCard()]),
        createStarrior(
            "Bird1",
            sprCrackerNutIdle, 
            sprCrackerNutIdle, 
            76, 
            76, 
            -1,
            -1,
            1,
            1,
            4,
            2,
            8,
            14,
            [createPhysicalDamageWeakeningChanseSingleTargetCard()]), 
        createStarrior(
            "Bird1",
            sprCrackerNutIdle, 
            sprCrackerNutIdle, 
            76, 
            76, 
            -1,
            -1,
            1,
            1,
            4,
            2,
            8,
            14,
            [createPhysicalDamageWeakeningChanseSingleTargetCard()])
    ]
}