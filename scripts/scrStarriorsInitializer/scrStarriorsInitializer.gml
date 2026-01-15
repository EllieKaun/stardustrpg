function createLana(){
    var starrior = createStarrior("Lana",    
            sprLanaBattleIdle, 
            sprLanaBattleSpell,
            5, 
            10, 
            [createPhysicalDamageSingleTargetCard(),
            createRemoveStatusBleedingSingleTargetCard(),
           // createPhysicalDamageCardDefault(),
            //createPhysicalDamageCardDefault(),
            //createPhysicalDamageCardDefault()
        ],
            1,
            1)
    return starrior
}

function createViv(){
    return createStarrior("Viv", sprVivBatlleIdle, sprVivBattleAttack, 5, 10, [
        createPhysicalDamageSingleTargetCard(),
        createRemoveStatusBleedingSingleTargetCard()
    ], 1, 1)
}

function createEnemiesLevel1() {
    return [
        createStarrior("Bird1", sprCrackerNutIdle, sprCrackerNutIdle, 6, 6, [createPhysicalDamageBleedingChanseSingleTargetCard()], 1, 1),
        createStarrior("Bird2", sprCrackerNutIdle, sprCrackerNutIdle, 6, 6, [], 1, 1),
        createStarrior("Bird3", sprCrackerNutIdle, sprCrackerNutIdle, 6, 6, [], 1, 1),
        createStarrior("Bird4", sprCrackerNutIdle, sprCrackerNutIdle, 6, 6, [], 1, 1),
        createStarrior("Bird5", sprCrackerNutIdle, sprCrackerNutIdle, 6, 6, [], 1, 1)
    ]
}