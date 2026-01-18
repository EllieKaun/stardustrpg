function createLana(){
    var starrior = createStarrior("Lana",    
            sprLanaBattleIdle, 
            sprLanaBattleSpell,
            60, 
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
                createMagicalDamageBurnChanseSingleTargetCard()
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
        76, 
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
            50,
            50,
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
            50,
            50,
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
            50,
            50,
            1,
            1,
            4,
            2,
            8,
            14,
            [createPhysicalDamageBleedingChanseSingleTargetCard()])
    ]
}