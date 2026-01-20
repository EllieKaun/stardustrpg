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
                createPhysicalDamageVampirismChanceMultipleTargetCard()
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
        createRemoveStatusBleedingSingleTargetCard()
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
            4,
            2,
            8,
            14,
            [createPhysicalDamageBombChanseMultipleTargetCard()]),
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
            [createPhysicalDamageBleedingChanseSingleTargetCard()]), 
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
            [createPhysicalDamageBleedingChanseSingleTargetCard()])
    ]
}