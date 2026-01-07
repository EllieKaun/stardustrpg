function createLana(){
    var starrior = createStarrior("Lana",    
            sprLanaBattleIdle, 
            sprLanaBattleSpell,
            10, 
            10, 
            [createPhysicalDamageCardDefault(),
            createInstantHealCardDefault(),
            createPhysicalDamageCardDefault(),
            createPhysicalDamageCardDefault(),
            createPhysicalDamageCardDefault()],
            1,
            1)
    return starrior
}

function createViv(){
    return createStarrior("Viv", sprVivBatlleIdle, sprVivBattleAttack, 10, 10, [], 1, 1)
}

function createEnemiesLevel1() {
    return [
        createStarrior("Bird", sprCrackerNutIdle, sprCrackerNutIdle, 6, 6, [createPhysicalDamageCardDefault()], 1, 1),
        createStarrior("Bird", sprCrackerNutIdle, sprCrackerNutIdle, 6, 6, [], 1, 1),
        createStarrior("Bird", sprCrackerNutIdle, sprCrackerNutIdle, 6, 6, [], 1, 1),
        createStarrior("Bird", sprCrackerNutIdle, sprCrackerNutIdle, 6, 6, [], 1, 1),
        createStarrior("Bird", sprCrackerNutIdle, sprCrackerNutIdle, 6, 6, [], 1, 1)
    ]
}