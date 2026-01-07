function createLana(){
    var starrior = createStarrior("Lana",    
            sprLanaBattleIdle, 
            10, 
            10, 
            [createPhysicalDamageCardDefault(),
            createPhysicalDamageCardDefault(),
            createPhysicalDamageCardDefault(),
            createPhysicalDamageCardDefault(),
            createPhysicalDamageCardDefault()],
            1,
            1)
    starrior.spriteActionIdle = sprLanaBattleIdle
    starrior.spriteActionAttack = sprLanaBattleSpell
    return starrior
}

function createViv(){
    return createStarrior("Viv", sprVivBatlleIdle, 10, 10, [], 1, 1)
}

function createEnemiesLevel1() {
    return [
        createStarrior("Bird", sprCrackerNutIdle, 6, 6, [], 1, 1),
        createStarrior("Bird", sprCrackerNutIdle, 6, 6, [], 1, 1),
        createStarrior("Bird", sprCrackerNutIdle, 6, 6, [], 1, 1),
        createStarrior("Bird", sprCrackerNutIdle, 6, 6, [], 1, 1),
        createStarrior("Bird", sprCrackerNutIdle, 6, 6, [], 1, 1)
    ]
}