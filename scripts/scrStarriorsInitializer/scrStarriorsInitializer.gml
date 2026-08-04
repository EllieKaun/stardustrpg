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
