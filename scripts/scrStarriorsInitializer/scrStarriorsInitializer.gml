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


