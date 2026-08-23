function createLana(){
    var starrior = createStarrior("Lana",    
            sprLanaBattleIdle, 
            sprLanaBattleAttack, 
            sprLanaBattleSpell,
            sprLanaBatlleCast,
            sprLanaBattleKO,
            sprLanaBattleDance,
            30,
            30,
            70,
            70,
            1,
            1,
            4,
            10,
            2,
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
        70,
        70,
        30,
        30,
        1,
        1,
        10,
        4,
        1,
        2,
        playerDeckFor(Characters.Viv)
    )
    starrior.themeColor = make_color_rgb(60, 140, 220)
    return starrior
}
