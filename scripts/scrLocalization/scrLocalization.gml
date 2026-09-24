// Локализация
// Инициализация
function locEnsure() {
    if (!variable_global_exists("locStrings")) {
        locInit()
    }
}

function locInit() {
    global.locStrings = {}
    global.locLangs = ["en", "ru"]
    global.locFallback = "en"
    locDefineEn()
    locDefineRu()
    global.language = locLoadLang()
}

// Уточнение языка
function locLoadLang() {
    ini_open("settings.ini")
    var saved = ini_read_string("General", "Language", "")
    ini_close()
    if (saved == "en" || saved == "ru") return saved
    return (os_get_language() == "ru") ? "ru" : "en"
}

// Установка языка
function setLanguage(lang) {
    if (!array_contains(global.locLangs, lang)) { 
        return
    }
    global.language = lang
    ini_open("settings.ini")
    ini_write_string("General", "Language", lang)
    ini_close()
    locInvalidateCaches()
}

function locCycleLanguage() {
    locEnsure()
    var index = 0
    for (var i = 0; i < array_length(global.locLangs); i++) {
        if (global.locLangs[i] == global.language) { 
            index = i 
            break 
        }
    }
    var next = global.locLangs[(index + 1) mod array_length(global.locLangs)]
    setLanguage(next)
    return next
}

// Очистить сохраненные локали
function locInvalidateCaches() {
    if (variable_global_exists("cardFaceLayouts")) global.cardFaceLayouts = {}
}

// Достать перевод по ключу
function loc(key) {
    return locDef(key, key)
}

// Инициализация переводов
function locDef(key, def) {
    locEnsure()
    var table = global.locStrings[$ global.language]
    if (table != undefined && variable_struct_exists(table, key)) return table[$ key]
    var fallback = global.locStrings[$ global.locFallback]
    if (fallback != undefined && variable_struct_exists(fallback, key)) return fallback[$ key]
    return def
}

// Инициализация имен карт
function locBuildCardNameMap() {
    global.locCardNameToId = {}
    if (!variable_global_exists("cardRegistry")) return
    var ids = variable_struct_get_names(global.cardRegistry)
    for (var i = 0; i < array_length(ids); i++) {
        var def = global.cardRegistry[$ ids[i]]
        var built = def.build(CardsRarity.Default)
        if (is_struct(built) && variable_struct_exists(built, "name")) {
            global.locCardNameToId[$ built.name] = ids[i]
        }
    }
}

// Взять ID из имени
function locCardIdFromName(rawName) {
    if (!variable_global_exists("cardRegistry")) return ""
    if (!variable_global_exists("locCardNameToId")) locBuildCardNameMap()
    return variable_struct_exists(global.locCardNameToId, rawName) ? global.locCardNameToId[$ rawName] : ""
}

// Локализация ключа карты
function locKeyForCard(card) {
    if (is_struct(card) && variable_struct_exists(card, "cardId")) return string(card.cardId)
    if (is_struct(card) && variable_struct_exists(card, "name")) {
        var mapped = locCardIdFromName(card.name)
        if (mapped != "") return mapped
        return string(card.name)
    }
    return ""
}

// Имя карты
function cardDisplayName(card) {
    var fallback = (is_struct(card) && variable_struct_exists(card, "name")) ? card.name : ""
    return locDef("card.name." + locKeyForCard(card), fallback)
}

// Описание карты
function cardDisplayDesc(card) {
    var fallback = (is_struct(card) && variable_struct_exists(card, "description")) ? card.description : ""
    return locDef("card.desc." + locKeyForCard(card), fallback)
}

// Имя игрока
function unitDisplayName(rawName) {
    return locDef("unit." + string(rawName), string(rawName))
}

// Имя спискера в диалоге
function speakerDisplayName(rawName) {
    return locDef("speaker." + string(rawName), string(rawName))
}

// Название языка
function languageNativeName(lang) {
    switch (lang) {
        case "en": return "English"
        case "ru": return "Русский"
    }
    return lang
}

// Определение английских локалей
function locDefineEn() {
    var t = {}

    t[$ "ui.victory"] = "VICTORY"
    t[$ "ui.gameover"] = "UNLUCKY"
    t[$ "ui.noRewards"] = "No rewards — press Enter"
    t[$ "ui.retry"] = "RETRY"
    t[$ "ui.exit"] = "EXIT"
    t[$ "ui.close"] = "CLOSE"
    t[$ "ui.none"] = "None"
    t[$ "ui.clickContinue"] = "Click to continue"
    t[$ "ui.newCard"] = "New card!"
    t[$ "ui.pressTabDeck"] = "Press TAB to open your deck"
    t[$ "ui.noCardsYet"] = "No cards yet"
    t[$ "ui.spaceNext"] = "SPACE >"

    t[$ "screen.mainMenu"] = "MAIN MENU"
    t[$ "screen.paused"] = "PAUSED"
    t[$ "screen.settings"] = "SETTINGS"
    t[$ "screen.album"] = "ALBUM"

    t[$ "menu.continue"] = "Continue"
    t[$ "menu.newGame"] = "New Game"
    t[$ "menu.album"] = "Album"
    t[$ "menu.settings"] = "Settings"
    t[$ "menu.quit"] = "Quit"
    t[$ "menu.resume"] = "Resume"
    t[$ "menu.mainMenu"] = "Main Menu"
    t[$ "menu.overwriteSave"] = "Overwrite your save?"
    t[$ "menu.noKeepPlaying"] = "No, keep playing"
    t[$ "menu.yesNewGame"] = "Yes, start new game"
    t[$ "menu.resolution"] = "Resolution"
    t[$ "menu.fullscreen"] = "Fullscreen"
    t[$ "menu.masterVol"] = "Master Vol"
    t[$ "menu.musicVol"] = "Music Vol"
    t[$ "menu.soundsVol"] = "Sounds Vol"
    t[$ "menu.apply"] = "Apply"
    t[$ "menu.cancel"] = "Cancel"
    t[$ "menu.back"] = "Back"
    t[$ "menu.language"] = "Language"
    t[$ "menu.on"] = "On"
    t[$ "menu.off"] = "Off"

    t[$ "battle.shuffle"] = "SHUFFLE"
    t[$ "battle.info"] = "INFO"
    t[$ "battle.run"] = "RUN"
    t[$ "battle.cancel"] = "CANCEL"
    t[$ "battle.waiting"] = "Waiting..."
    t[$ "battle.stunnedSuffix"] = " is stunned..."
    t[$ "battle.stunned"] = "STUNNED"
    t[$ "battle.name"] = "Name: "
    t[$ "battle.hp"] = "HP: "
    t[$ "battle.mp"] = "MP: "
    t[$ "battle.aura"] = "Aura: "
    t[$ "battle.guts"] = "Guts: "
    t[$ "battle.weakness"] = "Weakness:"

    t[$ "shop.title"] = "STORE"
    t[$ "shop.tabCards"] = "CARDS"
    t[$ "shop.tabOther"] = "OTHER"
    t[$ "shop.newSlot"] = "New deck slot"
    t[$ "shop.slotDesc1"] = "Adds a deck card slot"
    t[$ "shop.slotDesc2"] = "for both heroes"
    t[$ "shop.type"] = "Type: "
    t[$ "shop.typeAtc"] = "Atc"
    t[$ "shop.typeCast"] = "Cast"
    t[$ "shop.cost"] = "Cost: "
    t[$ "shop.mp"] = "mp"
    t[$ "shop.hp"] = "hp"
    t[$ "shop.damageType"] = "Damage Type: "
    t[$ "shop.magical"] = "magical"
    t[$ "shop.physical"] = "physical"

    t[$ "reward.type"] = "Type: "
    t[$ "reward.attack"] = "Attack"
    t[$ "reward.cast"] = "Cast"
    t[$ "reward.damage"] = "Damage: "
    t[$ "reward.heal"] = "Heal: "
    t[$ "reward.effects"] = "Effects: "
    t[$ "reward.cost"] = "Cost: "
    t[$ "reward.mp"] = "MP"
    t[$ "reward.hp"] = "HP"

    t[$ "deck.magic"] = "MAGIC"
    t[$ "deck.buff"] = "BUFF"
    t[$ "deck.heal"] = "HEAL"
    t[$ "deck.attack"] = "ATTACK"
    t[$ "deck.special"] = "SPECIAL"
    t[$ "deck.lana"] = "LANA"
    t[$ "deck.viv"] = "VIV"

    t[$ "effect.Damage"] = "Damage"
    t[$ "effect.Heal"] = "Heal"
    t[$ "effect.Stun"] = "Stun"
    t[$ "effect.Buff"] = "Buff"
    t[$ "effect.RemoveEffect"] = "Remove Effect"
    t[$ "effect.ManaGain"] = "Mana Gain"
    t[$ "effect.Weakening"] = "Weakening"
    t[$ "effect.Debuff"] = "Debuff"
    t[$ "effect.CopyCard"] = "Copy Card"
    t[$ "effect.AddEnergy"] = "Add Energy"
    t[$ "effect.ShuffleDeck"] = "Shuffle Deck"
    t[$ "effect.Resurrection"] = "Resurrection"
    t[$ "effect.CreatePuppet"] = "CreatePuppet"
    t[$ "effect.Unknown"] = "Unknown"

    t[$ "weakness.Stun"] = "Stun"
    t[$ "weakness.Burn"] = "Burn"
    t[$ "weakness.Freeze"] = "Freeze"
    t[$ "weakness.Bleeding"] = "Bleed"
    t[$ "weakness.Shock"] = "Shock"
    t[$ "weakness.Bomb"] = "Bomb"
    t[$ "weakness.Vampirism"] = "Vampirism"
    t[$ "weakness.Weakening"] = "Weaken"
    t[$ "weakness.Unknown"] = "?"

    t[$ "unit.Lana"] = "Lana"
    t[$ "unit.Viv"] = "Viv"
    t[$ "unit.Safar"] = "Safar"
    t[$ "unit.CrackerNut"] = "CrackerNut"
    t[$ "unit.Leaf"] = "Leaf"
    t[$ "unit.Mushroom"] = "Mushroom"
    t[$ "unit.Flower"] = "Flower"
    t[$ "unit.Puppet Master"] = "Puppet Master"
    t[$ "unit.ignitePrefix"] = "Ignite "

    t[$ "speaker.Lana"] = "Lana"
    t[$ "speaker.Viv"] = "Viv"
    t[$ "speaker.Safar"] = "Safar"
    t[$ "speaker.Chest"] = "Chest"

    t[$ "chest.goldPre"] = "You found "
    t[$ "chest.goldPost"] = " gold!"
    t[$ "chest.cardPre"] = "You found a card: "
    t[$ "chest.cardPost"] = "!"
    t[$ "chest.aCard"] = "a card"
    t[$ "chest.trap"] = "It's a trap!"

    t[$ "dlg.tut.ow1"] = "Wait - a wild Starrior! A good chance to learn how to fight."
    t[$ "dlg.tut.ow2"] = "Don't worry, it's easy once you get the hang of the cards."
    t[$ "dlg.tut.ow3"] = "Let's go. I'll walk you through it once the battle starts."
    t[$ "dlg.tut.deck1"] = "Nice work! Now let's set up your deck for next time."
    t[$ "dlg.tut.deck2"] = "Press Tab to open the deck builder."
    t[$ "dlg.tut.battle1"] = "These are your cards. Each one is an action you can play on your turn."
    t[$ "dlg.tut.battle2"] = "This is INFO - use it to inspect an enemy's stats before you act."
    t[$ "dlg.tut.battle3"] = "This is SHUFFLE - it redraws your whole hand for this turn."
    t[$ "dlg.tut.battle4"] = "That's everything. Now defeat this Starrior on your own. Good luck!"
    t[$ "dlg.tut.db1"] = "This is your collection - every card you own. Cards already used in a deck are marked with an owner icon."
    t[$ "dlg.tut.db2"] = "These are your decks. Select a card here to take it back out of the deck."
    t[$ "dlg.tut.db3"] = "That's it - build your deck however you like. Press Tab to close it."

    t[$ "dlg.safar.q1"] = "You need a companion on your journey?"
    t[$ "dlg.safar.q2"] = "Help would be welcome."
    t[$ "dlg.safar.q3"] = "Can't help you with that."
    t[$ "dlg.safar.q4"] = "Then why even ask?!"
    t[$ "dlg.safar.q5"] = "Fine - find my spear and I'll join you."
    t[$ "dlg.safar.q6"] = "And where do we find it?"
    t[$ "dlg.safar.q7"] = "A monster ran off with it while I slept. Without it I can't fight them."
    t[$ "dlg.safar.optYes"] = "Alright, we'll find your spear"
    t[$ "dlg.safar.optNo"] = "We're too busy right now"
    t[$ "dlg.safar.waiting"] = "Found my spear yet? Use a Steal card on the monster carrying it."
    t[$ "dlg.safar.done1"] = ":0 ... you actually all found it."
    t[$ "dlg.safar.done2"] = "You can count on my skills now."

    t[$ "card.name.physicalDamageSingleTarget"] = "Physical Strike"
    t[$ "card.name.physicalDamageMultipleTarget"] = "Physical Strike (Group)"
    t[$ "card.name.physicalDamageStunChanceSingleTarget"] = "Stunning Strike"
    t[$ "card.name.physicalDamageStunChanceMultiTarget"] = "Stunning Strike (Group)"
    t[$ "card.name.physicalDamageBleedChanceSingleTarget"] = "Bleeding Strike"
    t[$ "card.name.physicalDamageBleedChanceMultiTarget"] = "Bleeding Strike (Group)"
    t[$ "card.name.physicalDamageBombChanceSingleTarget"] = "Explosive Strike"
    t[$ "card.name.physicalDamageBombChanceMultiTarget"] = "Explosive Strike (Group)"
    t[$ "card.name.physicalDamageWeakenChanceSingleTarget"] = "Weakening Strike"
    t[$ "card.name.physicalDamageWeakenChanceMultiTarget"] = "Weakening Strike (Group)"
    t[$ "card.name.physicalDamageVampChanceSingleTarget"] = "Exhausting Strike"
    t[$ "card.name.physicalDamageVampChanceMultiTarget"] = "Exhausting Strike (Group)"
    t[$ "card.name.magicalDamageSingleTarget"] = "Star Strike"
    t[$ "card.name.magicalDamageMultipleTarget"] = "Star Strike (Group)"
    t[$ "card.name.magicalDamageStunChanceSingleTarget"] = "Lightning"
    t[$ "card.name.magicalDamageStunChanceMultiTarget"] = "Lightning (Group)"
    t[$ "card.name.magicalDamageBurnChanceSingleTarget"] = "Fire Strike"
    t[$ "card.name.magicalDamageBurnChanceMultiTarget"] = "Fire Strike (Group)"
    t[$ "card.name.magicalDamageFreezeChanceSingleTarget"] = "Frost Strike"
    t[$ "card.name.magicalDamageFreezeChanceMultiTarget"] = "Frost Strike (Group)"
    t[$ "card.name.buffPhysicalDamageSingleTarget"] = "Buff Physical damage"
    t[$ "card.name.buffMagicalDamageSingleTarget"] = "Buff Magical Damage"
    t[$ "card.name.buffAnyDamageMultiTarget"] = "Buff Any damage"
    t[$ "card.name.buffPhysicalProtectionSingleTarget"] = "Buff physical protection"
    t[$ "card.name.buffMagicalProtectionSingleTarget"] = "Buff magical protection"
    t[$ "card.name.buffAnyProtectionMultiTarget"] = "Buff any protection"
    t[$ "card.name.debuffPhysicalDamageSingleTarget"] = "Debuff physical damage"
    t[$ "card.name.debuffMagicalDamageSingleTarget"] = "Debuff magical damage"
    t[$ "card.name.debuffPhysicalProtectionSingleTarget"] = "Debuff physical protection"
    t[$ "card.name.debuffMagicalProtectionSingleTarget"] = "Debuff magical protection"
    t[$ "card.name.weaknessMagicalDamageSingleTarget"] = "Magic Vulnerability"
    t[$ "card.name.weaknessPhysicalDamageSingleTarget"] = "Physical Vulnerability"
    t[$ "card.name.ignoreWeaknessSingleTarget"] = "Show weakness"
    t[$ "card.name.instantHealSingleTarget"] = "Heal"
    t[$ "card.name.instantHealMultiTarget"] = "Heal (Group)"
    t[$ "card.name.overtimeHealSingleTarget"] = "Heal overtime"
    t[$ "card.name.instantManaGainSingleTarget"] = "Mana restore"
    t[$ "card.name.instantManaGainMultiTarget"] = "Mana restore (Group)"
    t[$ "card.name.overtimeManaGainSingleTarget"] = "Mana restore overtime"
    t[$ "card.name.copyNextPlayedCard"] = "Copy next played card"
    t[$ "card.name.addEnergy"] = "Extra Energy"
    t[$ "card.name.shuffleDeck"] = "Shuffle"
    t[$ "card.name.stealCard"] = "Steal"
    t[$ "card.name.removeShock"] = "Cleanse: Shock"
    t[$ "card.name.removeBurn"] = "Cleanse: Burn"
    t[$ "card.name.removeFreeze"] = "Cleanse: Freeze"
    t[$ "card.name.removeBleeding"] = "Cleanse: Bleed"
    t[$ "card.name.removeStun"] = "Cleanse: Stun"
    t[$ "card.name.resurrection"] = "Resurrection"
    t[$ "card.name.summonAttackPuppet"] = "Attack Puppet"
    t[$ "card.name.summonMagicPuppet"] = "Magic Puppet"
    t[$ "card.name.summonHealPuppet"] = "Heal Puppet"
    t[$ "card.name.summonBuffPuppet"] = "Buff Puppet"
    t[$ "card.name.bossClone"] = "Clone"

    t[$ "card.desc.physicalDamageSingleTarget"] = "deals minor physical damage (single)"
    t[$ "card.desc.physicalDamageMultipleTarget"] = "deals minor physical damage (group)"
    t[$ "card.desc.physicalDamageStunChanceSingleTarget"] = "deals minor physical damage, may stun (single)"
    t[$ "card.desc.physicalDamageStunChanceMultiTarget"] = "deals minor physical damage, may stun (group)"
    t[$ "card.desc.physicalDamageBleedChanceSingleTarget"] = "deals minor physical damage, may cause bleeding (single)"
    t[$ "card.desc.physicalDamageBleedChanceMultiTarget"] = "deals minor physical damage, may cause bleeding (group)"
    t[$ "card.desc.physicalDamageBombChanceSingleTarget"] = "deals minor physical damage with a bomb blast (single)"
    t[$ "card.desc.physicalDamageBombChanceMultiTarget"] = "deals minor physical damage with a bomb blast (group)"
    t[$ "card.desc.physicalDamageWeakenChanceSingleTarget"] = "deals minor physical damage, may weaken (single)"
    t[$ "card.desc.physicalDamageWeakenChanceMultiTarget"] = "deals minor physical damage, may weaken (group)"
    t[$ "card.desc.physicalDamageVampChanceSingleTarget"] = "deals minor physical damage, drains health (single)"
    t[$ "card.desc.physicalDamageVampChanceMultiTarget"] = "deals minor physical damage, drains health (group)"
    t[$ "card.desc.magicalDamageSingleTarget"] = "deals minor star energy damage (single)"
    t[$ "card.desc.magicalDamageMultipleTarget"] = "deals minor star energy damage (group)"
    t[$ "card.desc.magicalDamageStunChanceSingleTarget"] = "deals minor lightning damage (single)"
    t[$ "card.desc.magicalDamageStunChanceMultiTarget"] = "deals minor lightning damage (group)"
    t[$ "card.desc.magicalDamageBurnChanceSingleTarget"] = "deals minor fire damage (single)"
    t[$ "card.desc.magicalDamageBurnChanceMultiTarget"] = "deals minor fire damage (group)"
    t[$ "card.desc.magicalDamageFreezeChanceSingleTarget"] = "deals minor ice damage (single)"
    t[$ "card.desc.magicalDamageFreezeChanceMultiTarget"] = "deals minor ice damage (group)"
    t[$ "card.desc.buffPhysicalDamageSingleTarget"] = "slightly boosts physical damage (4 turns)"
    t[$ "card.desc.buffMagicalDamageSingleTarget"] = "slightly boosts magic damage (1 turn)"
    t[$ "card.desc.buffAnyDamageMultiTarget"] = "slightly boosts damage (1 turn)"
    t[$ "card.desc.buffPhysicalProtectionSingleTarget"] = "slightly boosts physical defense (1 turn)"
    t[$ "card.desc.buffMagicalProtectionSingleTarget"] = "slightly boosts magical defense (1 turn)"
    t[$ "card.desc.buffAnyProtectionMultiTarget"] = "slightly boosts defense (1 turn)"
    t[$ "card.desc.debuffPhysicalDamageSingleTarget"] = "slightly reduces physical damage (1 turn)"
    t[$ "card.desc.debuffMagicalDamageSingleTarget"] = "slightly reduces magic damage (1 turn)"
    t[$ "card.desc.debuffPhysicalProtectionSingleTarget"] = "slightly reduces physical defense (1 turn)"
    t[$ "card.desc.debuffMagicalProtectionSingleTarget"] = "slightly reduces magical defense (1 turn)"
    t[$ "card.desc.weaknessMagicalDamageSingleTarget"] = "vulnerability to magic damage (1 turn)"
    t[$ "card.desc.weaknessPhysicalDamageSingleTarget"] = "vulnerability to physical damage (1 turn)"
    t[$ "card.desc.ignoreWeaknessSingleTarget"] = "ignores weaknesses (2 turns)"
    t[$ "card.desc.instantHealSingleTarget"] = "restores a small amount of health (single)"
    t[$ "card.desc.instantHealMultiTarget"] = "restores a small amount of health (group)"
    t[$ "card.desc.overtimeHealSingleTarget"] = "restores a small amount of health over 2 turns"
    t[$ "card.desc.instantManaGainSingleTarget"] = "restores a small amount of mana (single)"
    t[$ "card.desc.instantManaGainMultiTarget"] = "restores a small amount of mana (group)"
    t[$ "card.desc.overtimeManaGainSingleTarget"] = "restores a small amount of mana over 2 turns"
    t[$ "card.desc.copyNextPlayedCard"] = "copy next played card in hand"
    t[$ "card.desc.addEnergy"] = "adds extra energy"
    t[$ "card.desc.shuffleDeck"] = "shuffle"
    t[$ "card.desc.stealCard"] = "copy a card from the enemy's hand"
    t[$ "card.desc.removeShock"] = "remove the Shock status"
    t[$ "card.desc.removeBurn"] = "remove the Burn status"
    t[$ "card.desc.removeFreeze"] = "remove the Freeze status"
    t[$ "card.desc.removeBleeding"] = "remove the Bleeding status"
    t[$ "card.desc.removeStun"] = "remove the Stun status"
    t[$ "card.desc.resurrection"] = "resurrection"
    t[$ "card.desc.summonAttackPuppet"] = "create a weak puppet"
    t[$ "card.desc.summonMagicPuppet"] = "create a weak puppet"
    t[$ "card.desc.summonHealPuppet"] = "create a weak puppet"
    t[$ "card.desc.summonBuffPuppet"] = "create a weak puppet"
    t[$ "card.desc.bossClone"] = "clones itself into all empty slots"

    global.locStrings[$ "en"] = t
}

// Определение русских локалей
function locDefineRu() {
    var t = {}

    t[$ "ui.victory"] = "ПОБЕДА"
    t[$ "ui.gameover"] = "НЕПОВЕЗЛО"
    t[$ "ui.noRewards"] = "Нет наград — нажмите Enter"
    t[$ "ui.retry"] = "ЗАНОВО"
    t[$ "ui.exit"] = "ВЫЙТИ"
    t[$ "ui.close"] = "ЗАКРЫТЬ"
    t[$ "ui.none"] = "Нет"
    t[$ "ui.clickContinue"] = "Нажмите, чтобы продолжить"
    t[$ "ui.newCard"] = "Новая карта!"
    t[$ "ui.pressTabDeck"] = "Нажмите TAB, чтобы открыть колоду"
    t[$ "ui.noCardsYet"] = "Пока нет карт"
    t[$ "ui.spaceNext"] = "ПРОБЕЛ >"

    t[$ "screen.mainMenu"] = "ГЛАВНОЕ МЕНЮ"
    t[$ "screen.paused"] = "ПАУЗА"
    t[$ "screen.settings"] = "НАСТРОЙКИ"
    t[$ "screen.album"] = "АЛЬБОМ"

    t[$ "menu.continue"] = "Продолжить"
    t[$ "menu.newGame"] = "Новая игра"
    t[$ "menu.album"] = "Альбом"
    t[$ "menu.settings"] = "Настройки"
    t[$ "menu.quit"] = "Выход"
    t[$ "menu.resume"] = "Продолжить"
    t[$ "menu.mainMenu"] = "Главное меню"
    t[$ "menu.overwriteSave"] = "Перезаписать сохранение?"
    t[$ "menu.noKeepPlaying"] = "Нет, продолжить игру"
    t[$ "menu.yesNewGame"] = "Да, начать заново"
    t[$ "menu.resolution"] = "Разрешение"
    t[$ "menu.fullscreen"] = "Полный экран"
    t[$ "menu.masterVol"] = "Общая громкость"
    t[$ "menu.musicVol"] = "Музыка"
    t[$ "menu.soundsVol"] = "Звуки"
    t[$ "menu.apply"] = "Применить"
    t[$ "menu.cancel"] = "Отмена"
    t[$ "menu.back"] = "Назад"
    t[$ "menu.language"] = "Язык"
    t[$ "menu.on"] = "Вкл"
    t[$ "menu.off"] = "Выкл"

    t[$ "battle.shuffle"] = "ЗАМЕШАТЬ"
    t[$ "battle.info"] = "ИНФО"
    t[$ "battle.run"] = "ПОБЕГ"
    t[$ "battle.cancel"] = "ОТМЕНА"
    t[$ "battle.waiting"] = "Ожидание..."
    t[$ "battle.stunnedSuffix"] = " оглушён..."
    t[$ "battle.stunned"] = "ОГЛУШЕН"
    t[$ "battle.name"] = "Имя: "
    t[$ "battle.hp"] = "ЗДОРОВЬЕ: "
    t[$ "battle.mp"] = "МАНА: "
    t[$ "battle.aura"] = "Аура: "
    t[$ "battle.guts"] = "Стойкость: "
    t[$ "battle.weakness"] = "Слабости:"

    t[$ "shop.title"] = "МАГАЗИН"
    t[$ "shop.tabCards"] = "КАРТЫ"
    t[$ "shop.tabOther"] = "ПРОЧЕЕ"
    t[$ "shop.newSlot"] = "Новый слот колоды"
    t[$ "shop.slotDesc1"] = "Добавляет слот карты"
    t[$ "shop.slotDesc2"] = "для обоих героев"
    t[$ "shop.type"] = "Тип: "
    t[$ "shop.typeAtc"] = "Атака"
    t[$ "shop.typeCast"] = "Магия"
    t[$ "shop.cost"] = "Цена: "
    t[$ "shop.mp"] = "мана"
    t[$ "shop.hp"] = "здоровье"
    t[$ "shop.damageType"] = "Тип урона: "
    t[$ "shop.magical"] = "магический"
    t[$ "shop.physical"] = "физический"

    t[$ "reward.type"] = "Тип: "
    t[$ "reward.attack"] = "Атака"
    t[$ "reward.cast"] = "Магия"
    t[$ "reward.damage"] = "Урон: "
    t[$ "reward.heal"] = "Лечение: "
    t[$ "reward.effects"] = "Эффекты: "
    t[$ "reward.cost"] = "Цена: "
    t[$ "reward.mp"] = "МАНА"
    t[$ "reward.hp"] = "ЗДОРОВЬЕ"

    t[$ "deck.magic"] = "МАГИЯ"
    t[$ "deck.buff"] = "БАФФ"
    t[$ "deck.heal"] = "ЛЕЧЕНИЕ"
    t[$ "deck.attack"] = "АТАКА"
    t[$ "deck.special"] = "ОСОБЫЕ"
    t[$ "deck.lana"] = "ЛАНА"
    t[$ "deck.viv"] = "ВИВ"

    t[$ "effect.Damage"] = "Урон"
    t[$ "effect.Heal"] = "Лечение"
    t[$ "effect.Stun"] = "Оглушение"
    t[$ "effect.Buff"] = "Усиление"
    t[$ "effect.RemoveEffect"] = "Снятие эффекта"
    t[$ "effect.ManaGain"] = "Восст. маны"
    t[$ "effect.Weakening"] = "Ослабление"
    t[$ "effect.Debuff"] = "Дебафф"
    t[$ "effect.CopyCard"] = "Копия карты"
    t[$ "effect.AddEnergy"] = "Доп. энергия"
    t[$ "effect.ShuffleDeck"] = "Замешать"
    t[$ "effect.Resurrection"] = "Воскрешение"
    t[$ "effect.CreatePuppet"] = "Марионетка"
    t[$ "effect.Unknown"] = "Неизвестно"

    t[$ "weakness.Stun"] = "Оглушение"
    t[$ "weakness.Burn"] = "Поджог"
    t[$ "weakness.Freeze"] = "Заморозка"
    t[$ "weakness.Bleeding"] = "Кровотечение"
    t[$ "weakness.Shock"] = "Шок"
    t[$ "weakness.Bomb"] = "Взрыв"
    t[$ "weakness.Vampirism"] = "Вампиризм"
    t[$ "weakness.Weakening"] = "Слабость"
    t[$ "weakness.Unknown"] = "?"

    t[$ "unit.Lana"] = "Лана"
    t[$ "unit.Viv"] = "Вив"
    t[$ "unit.Safar"] = "Сафар"
    t[$ "unit.CrackerNut"] = "КрэкерНат"
    t[$ "unit.Leaf"] = "Лиф"
    t[$ "unit.Mushroom"] = "Машрум"
    t[$ "unit.Flower"] = "Флоуер"
    t[$ "unit.Puppet Master"] = "Паппет Мастер"
    t[$ "unit.ignitePrefix"] = "Горящий "

    t[$ "speaker.Lana"] = "Лана"
    t[$ "speaker.Viv"] = "Вив"
    t[$ "speaker.Safar"] = "Сафар"
    t[$ "speaker.Chest"] = "Сундук"

    t[$ "chest.goldPre"] = "Вы нашли "
    t[$ "chest.goldPost"] = " золота!"
    t[$ "chest.cardPre"] = "Вы нашли карту: "
    t[$ "chest.cardPost"] = "!"
    t[$ "chest.aCard"] = "карту"
    t[$ "chest.trap"] = "Это ловушка!"

    t[$ "dlg.tut.ow1"] = "Стой, Боец!  Давай научимся сражаться."
    t[$ "dlg.tut.ow2"] = "Не переживай, с картами всё просто, нужно только освоиться."
    t[$ "dlg.tut.ow3"] = "Идём. Я всё объясню, как только начнётся бой."
    t[$ "dlg.tut.deck1"] = "Отличная работа! Теперь соберём твою колоду."
    t[$ "dlg.tut.deck2"] = "Нажми Tab, чтобы открыть конструктор колоды."
    t[$ "dlg.tut.battle1"] = "Это твои карты. Каждая - действие, которое можно сыграть в свой ход."
    t[$ "dlg.tut.battle2"] = "Это ИНФОРМАЦИЯ - просмотри характеристики врага перед тем, как действовать."
    t[$ "dlg.tut.battle3"] = "Это ЗАМЕШАТЬ - позволяет тебе собрать все карты вместе (включая сыгранные) и взять в руку"
    t[$ "dlg.tut.battle4"] = "Вот и всё. Теперь одолей этого противника сам. Удачи!"
    t[$ "dlg.tut.db1"] = "Это твоя коллекция - все карты, что у тебя есть. Карты, уже занятые в колоде, помечены значком владельца."
    t[$ "dlg.tut.db2"] = "Это твои колоды. Выбери карту здесь, чтобы вернуть её из колоды."
    t[$ "dlg.tut.db3"] = "Вот и всё - собирай колоду как хочешь. Нажми Tab или Esc, чтобы закрыть."

    t[$ "dlg.safar.q1"] = "Нужен спутник в дорогу?"
    t[$ "dlg.safar.q2"] = "Помощь бы не помешала."
    t[$ "dlg.safar.q3"] = "С этим ничем не помогу."
    t[$ "dlg.safar.q4"] = "Тогда зачем вообще спрашивать?!"
    t[$ "dlg.safar.q5"] = "Ладно - найдите моё копьё, и я к вам присоединюсь."
    t[$ "dlg.safar.q6"] = "И где нам его искать?"
    t[$ "dlg.safar.q7"] = "Монстр утащил его, пока я спал. Без него мне с ними не справиться."
    t[$ "dlg.safar.optYes"] = "Хорошо, мы найдём твоё копьё"
    t[$ "dlg.safar.optNo"] = "Сейчас нам не до этого"
    t[$ "dlg.safar.waiting"] = "Уже нашли моё копьё? Примени карту Кража на монстре, что его несёт."
    t[$ "dlg.safar.done1"] = ":0 ... вы и правда его нашли."
    t[$ "dlg.safar.done2"] = "Теперь можете рассчитывать на мои умения."

    t[$ "card.name.physicalDamageSingleTarget"] = "Физический удар"
    t[$ "card.name.physicalDamageMultipleTarget"] = "Физический удар (группа)"
    t[$ "card.name.physicalDamageStunChanceSingleTarget"] = "Оглушающий удар"
    t[$ "card.name.physicalDamageStunChanceMultiTarget"] = "Оглушающий удар (группа)"
    t[$ "card.name.physicalDamageBleedChanceSingleTarget"] = "Удар с кровотечением"
    t[$ "card.name.physicalDamageBleedChanceMultiTarget"] = "Удар с кровотечением (группа)"
    t[$ "card.name.physicalDamageBombChanceSingleTarget"] = "Взрывной удар"
    t[$ "card.name.physicalDamageBombChanceMultiTarget"] = "Взрывной удар (группа)"
    t[$ "card.name.physicalDamageWeakenChanceSingleTarget"] = "Ослабляющий удар"
    t[$ "card.name.physicalDamageWeakenChanceMultiTarget"] = "Ослабляющий удар (группа)"
    t[$ "card.name.physicalDamageVampChanceSingleTarget"] = "Удар вампира"
    t[$ "card.name.physicalDamageVampChanceMultiTarget"] = "Удар вампира (группа)"
    t[$ "card.name.magicalDamageSingleTarget"] = "Звёздный удар"
    t[$ "card.name.magicalDamageMultipleTarget"] = "Звёздный удар (группа)"
    t[$ "card.name.magicalDamageStunChanceSingleTarget"] = "Молния"
    t[$ "card.name.magicalDamageStunChanceMultiTarget"] = "Молния (группа)"
    t[$ "card.name.magicalDamageBurnChanceSingleTarget"] = "Огненный удар"
    t[$ "card.name.magicalDamageBurnChanceMultiTarget"] = "Огненный удар (группа)"
    t[$ "card.name.magicalDamageFreezeChanceSingleTarget"] = "Ледяной удар"
    t[$ "card.name.magicalDamageFreezeChanceMultiTarget"] = "Ледяной удар (группа)"
    t[$ "card.name.buffPhysicalDamageSingleTarget"] = "Усиление физической силы"
    t[$ "card.name.buffMagicalDamageSingleTarget"] = "Усиление магии"
    t[$ "card.name.buffAnyDamageMultiTarget"] = "Усиление любого урона"
    t[$ "card.name.buffPhysicalProtectionSingleTarget"] = "Бафф физической защиты"
    t[$ "card.name.buffMagicalProtectionSingleTarget"] = "Бафф магической защиты"
    t[$ "card.name.buffAnyProtectionMultiTarget"] = "Бафф всей защиты"
    t[$ "card.name.debuffPhysicalDamageSingleTarget"] = "Ослабить физическую силу"
    t[$ "card.name.debuffMagicalDamageSingleTarget"] = "Ослабить магию"
    t[$ "card.name.debuffPhysicalProtectionSingleTarget"] = "Ослабить физическую защиту"
    t[$ "card.name.debuffMagicalProtectionSingleTarget"] = "Ослабить магическую защиту"
    t[$ "card.name.weaknessMagicalDamageSingleTarget"] = "Создать слабость к магии"
    t[$ "card.name.weaknessPhysicalDamageSingleTarget"] = "Создать слабость к физ. атакам"
    t[$ "card.name.ignoreWeaknessSingleTarget"] = "Игнорирование слабостей"
    t[$ "card.name.instantHealSingleTarget"] = "Лечение"
    t[$ "card.name.instantHealMultiTarget"] = "Лечение (группа)"
    t[$ "card.name.overtimeHealSingleTarget"] = "Лечение со временем"
    t[$ "card.name.instantManaGainSingleTarget"] = "Восстановить ману"
    t[$ "card.name.instantManaGainMultiTarget"] = "Восстановить ману (группа)"
    t[$ "card.name.overtimeManaGainSingleTarget"] = "Восстановить ману со временем"
    t[$ "card.name.copyNextPlayedCard"] = "Копировать следующую разыгранную карту"
    t[$ "card.name.addEnergy"] = "Доп. энергия"
    t[$ "card.name.shuffleDeck"] = "Замешать"
    t[$ "card.name.stealCard"] = "Украсть карту"
    t[$ "card.name.removeShock"] = "Снять шок"
    t[$ "card.name.removeBurn"] = "Снять поджог"
    t[$ "card.name.removeFreeze"] = "Снять заморозку"
    t[$ "card.name.removeBleeding"] = "Снять кровотечение"
    t[$ "card.name.removeStun"] = "Снять оглушение"
    t[$ "card.name.resurrection"] = "Воскрешение"
    t[$ "card.name.summonAttackPuppet"] = "Создать Марионетку-бойца"
    t[$ "card.name.summonMagicPuppet"] = "Создать Марионетку-мага"
    t[$ "card.name.summonHealPuppet"] = "Создать Марионетку-лекаря"
    t[$ "card.name.summonBuffPuppet"] = "Создать усиливающую Марионетку"
    t[$ "card.name.bossClone"] = "Клонирование"

    t[$ "card.desc.physicalDamageSingleTarget"] = "наносит небольшой физический урон (одна цель)"
    t[$ "card.desc.physicalDamageMultipleTarget"] = "наносит небольшой физический урон (группа)"
    t[$ "card.desc.physicalDamageStunChanceSingleTarget"] = "физический урон, шанс оглушения (одна цель)"
    t[$ "card.desc.physicalDamageStunChanceMultiTarget"] = "физический урон, шанс оглушения (группа)"
    t[$ "card.desc.physicalDamageBleedChanceSingleTarget"] = "физический урон, шанс кровотечения (одна цель)"
    t[$ "card.desc.physicalDamageBleedChanceMultiTarget"] = "физический урон, шанс кровотечения (группа)"
    t[$ "card.desc.physicalDamageBombChanceSingleTarget"] = "физический урон со взрывом (одна цель)"
    t[$ "card.desc.physicalDamageBombChanceMultiTarget"] = "физический урон со взрывом (группа)"
    t[$ "card.desc.physicalDamageWeakenChanceSingleTarget"] = "физический урон, шанс ослабить (одна цель)"
    t[$ "card.desc.physicalDamageWeakenChanceMultiTarget"] = "физический урон, шанс ослабить (группа)"
    t[$ "card.desc.physicalDamageVampChanceSingleTarget"] = "физический урон, крадёт здоровье (одна цель)"
    t[$ "card.desc.physicalDamageVampChanceMultiTarget"] = "физический урон, крадёт здоровье (группа)"
    t[$ "card.desc.magicalDamageSingleTarget"] = "урон звёздной энергией (одна цель)"
    t[$ "card.desc.magicalDamageMultipleTarget"] = "урон звёздной энергией (группа)"
    t[$ "card.desc.magicalDamageStunChanceSingleTarget"] = "урон молнией (одна цель)"
    t[$ "card.desc.magicalDamageStunChanceMultiTarget"] = "урон молнией (группа)"
    t[$ "card.desc.magicalDamageBurnChanceSingleTarget"] = "урон огнём (одна цель)"
    t[$ "card.desc.magicalDamageBurnChanceMultiTarget"] = "урон огнём (группа)"
    t[$ "card.desc.magicalDamageFreezeChanceSingleTarget"] = "урон льдом (одна цель)"
    t[$ "card.desc.magicalDamageFreezeChanceMultiTarget"] = "урон льдом (группа)"
    t[$ "card.desc.buffPhysicalDamageSingleTarget"] = "немного усиливает физ. урон (4 хода)"
    t[$ "card.desc.buffMagicalDamageSingleTarget"] = "немного усиливает маг. урон (1 ход)"
    t[$ "card.desc.buffAnyDamageMultiTarget"] = "немного усиливает урон (1 ход)"
    t[$ "card.desc.buffPhysicalProtectionSingleTarget"] = "немного усиливает физ. защиту (1 ход)"
    t[$ "card.desc.buffMagicalProtectionSingleTarget"] = "немного усиливает маг. защиту (1 ход)"
    t[$ "card.desc.buffAnyProtectionMultiTarget"] = "немного усиливает защиту (1 ход)"
    t[$ "card.desc.debuffPhysicalDamageSingleTarget"] = "немного снижает физ. урон врага (1 ход)"
    t[$ "card.desc.debuffMagicalDamageSingleTarget"] = "немного снижает маг. урон врага (1 ход)"
    t[$ "card.desc.debuffPhysicalProtectionSingleTarget"] = "немного снижает физ. защиту врага (1 ход)"
    t[$ "card.desc.debuffMagicalProtectionSingleTarget"] = "немного снижает маг. защиту врага (1 ход)"
    t[$ "card.desc.weaknessMagicalDamageSingleTarget"] = "уязвимость к маг. урону (1 ход)"
    t[$ "card.desc.weaknessPhysicalDamageSingleTarget"] = "уязвимость к физ. урону (1 ход)"
    t[$ "card.desc.ignoreWeaknessSingleTarget"] = "игнорирует слабости (2 хода)"
    t[$ "card.desc.instantHealSingleTarget"] = "восстанавливает немного здоровья (одна цель)"
    t[$ "card.desc.instantHealMultiTarget"] = "восстанавливает немного здоровья (группа)"
    t[$ "card.desc.overtimeHealSingleTarget"] = "восстанавливает здоровье в течение 2 ходов"
    t[$ "card.desc.instantManaGainSingleTarget"] = "восстанавливает немного маны (одна цель)"
    t[$ "card.desc.instantManaGainMultiTarget"] = "восстанавливает немного маны (группа)"
    t[$ "card.desc.overtimeManaGainSingleTarget"] = "восстанавливает ману в течение 2 ходов"
    t[$ "card.desc.copyNextPlayedCard"] = "копирует следующую сыгранную карту"
    t[$ "card.desc.addEnergy"] = "даёт дополнительную энергию"
    t[$ "card.desc.shuffleDeck"] = "перемешивает колоду"
    t[$ "card.desc.stealCard"] = "крадёт карту из руки врага"
    t[$ "card.desc.removeShock"] = "снимает статус шока"
    t[$ "card.desc.removeBurn"] = "снимает статус поджога"
    t[$ "card.desc.removeFreeze"] = "снимает статус заморозки"
    t[$ "card.desc.removeBleeding"] = "снимает статус кровотечения"
    t[$ "card.desc.removeStun"] = "снимает статус оглушения"
    t[$ "card.desc.resurrection"] = "воскрешает павшего союзника"
    t[$ "card.desc.summonAttackPuppet"] = "создаёт марионетку-бойца"
    t[$ "card.desc.summonMagicPuppet"] = "создаёт марионетку-мага"
    t[$ "card.desc.summonHealPuppet"] = "создаёт марионетку-лекаря"
    t[$ "card.desc.summonBuffPuppet"] = "создаёт усиливающую марионетку"
    t[$ "card.desc.bossClone"] = "клонирует себя во все пустые слоты"

    global.locStrings[$ "ru"] = t
}
