function createLana(){
    var starrior = createStarrior("Lana",    
            sprLanaBattleIdle, 
            sprLanaBattleAttack, 
            sprLanaBattleSpell,
            sprLanaBatlleCast,
            sprLanaBattleKO,
            sprLanaBattleDance,
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
    starrior.themeColor = make_color_rgb(214, 36, 140)
    return starrior
}


function createViv(){
    var starrior = createStarrior(
        "Viv",
        sprVivBatlleIdle,
        sprVivBattleAttack,
        sprVivBattleSpell,
        sprVivBattleCast,
        sprVivBattleKO,
        noone,
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
    starrior.themeColor = make_color_rgb(60, 140, 220)
    return starrior
}
