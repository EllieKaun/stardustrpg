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
            35,
            35,
            1,
            1,
            4,
            10,
            2,
            1,
            playerDeckFor(Characters.Lana)
    )
    starrior.themeColor = make_color_rgb(105, 93, 164)
    starrior.portrait = sprCharacterPanelLanaHead
    return starrior
}


function safarFixedDeck() {
    return [
        createPhysicalDamageSingleTargetCard(),
        createPhysicalDamageSingleTargetCard(),
        createMagicalDamageSingleTargetCard(),
        createInstantHealSingleTargetCard(),
        createCardBuffPhysicalDamageSingleTarget(),
        createPhysicalDamageStunChanseSingleTargetCard()
    ]
}

function createSafar(){
    var starrior = createStarrior(
        "Safar",
        SafarIdle,
        SafarAttack,
        SafarCast,
        SafarCast,
        SafarKO,
        noone,
        50,
        50,
        40,
        40,
        1,
        1,
        8,
        8,
        2,
        2,
        safarFixedDeck()
    )
    starrior.themeColor = make_color_rgb(60, 145, 174)
    starrior.portrait = sprCharacterPanelSafarHead
    return starrior
}


function foxBattleSprite(name, fallback) {
    var spr = asset_get_index(name)
    return sprite_exists(spr) ? spr : fallback
}

function foxFixedDeck() {
    return [
        createInstantManaGainSingleTargetCard(),
        createInstantMultipleTargetsManaGainCard(),
        createOvertimeManaGainSingleTargetCard(),
        createMagicalDamageSingleTargetCard(),
        createInstantHealSingleTargetCard(),
        createCardBuffMagicalDamageSingleTarget()
    ]
}

function createFox(){
    var starrior = createStarrior(
        "Fox",
        foxBattleSprite("FoxIdle",   SafarIdle),
        foxBattleSprite("FoxAttack", SafarAttack),
        foxBattleSprite("FoxSpell",  SafarCast),
        foxBattleSprite("FoxCast",   SafarCast),
        foxBattleSprite("FoxKO",     SafarKO),
        noone,
        45,
        45,
        50,
        50,
        1,
        1,
        6,
        10,
        2,
        2,
        foxFixedDeck()
    )
    starrior.themeColor = make_color_rgb(214, 126, 60)
    var portrait = asset_get_index("sprCharacterPanelFoxHead")
    starrior.portrait = sprite_exists(portrait) ? portrait : sprCharacterPanelSafarHead
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
        sprVivBattleDance,
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
    starrior.themeColor = make_color_rgb(199, 9, 151)
    starrior.portrait = sprCharacterPanelVivHead
    return starrior
}
