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
    if (saved == "en" || saved == "ru") { return saved }
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
    if (variable_global_exists("cardFaceLayouts")) { global.cardFaceLayouts = {} }
}

// Достать перевод по ключу
function loc(key) {
    return locDef(key, key)
}

// Инициализация переводов
function locDef(key, fallbackValue) {
    locEnsure()
    var table = global.locStrings[$ global.language]
    if (table != undefined && variable_struct_exists(table, key)) { return table[$ key] }
    var fallback = global.locStrings[$ global.locFallback]
    if (fallback != undefined && variable_struct_exists(fallback, key)) { return fallback[$ key] }
    return fallbackValue
}

// Инициализация имен карт
function locBuildCardNameMap() {
    global.locCardNameToId = {}
    if (!variable_global_exists("cardRegistry")) { return }
    var cardKeys = variable_struct_get_names(global.cardRegistry)
    for (var i = 0; i < array_length(cardKeys); i++) {
        var cardDefinition = global.cardRegistry[$ cardKeys[i]]
        var built = cardDefinition.build(CardsRarity.Default)
        if (is_struct(built) && variable_struct_exists(built, "name")) {
            global.locCardNameToId[$ built.name] = cardKeys[i]
        }
    }
}

// Взять ID из имени
function locCardIdFromName(rawName) {
    if (!variable_global_exists("cardRegistry")) { return "" }
    if (!variable_global_exists("locCardNameToId")) { locBuildCardNameMap() }
    return variable_struct_exists(global.locCardNameToId, rawName) ? global.locCardNameToId[$ rawName] : ""
}

// Локализация ключа карты
function locKeyForCard(card) {
    if (is_struct(card) && variable_struct_exists(card, "cardId")) { return string(card.cardId) }
    if (is_struct(card) && variable_struct_exists(card, "name")) {
        var mapped = locCardIdFromName(card.name)
        if (mapped != "") { return mapped }
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
    var translations = {}

    translations[$ "ui.victory"] = "VICTORY"
    translations[$ "ui.gameover"] = "UNLUCKY"
    translations[$ "ui.noRewards"] = "No rewards — press Enter"
    translations[$ "ui.retry"] = "RETRY"
    translations[$ "ui.exit"] = "EXIT"
    translations[$ "ui.close"] = "CLOSE"
    translations[$ "ui.none"] = "None"
    translations[$ "ui.clickContinue"] = "Click to continue"
    translations[$ "ui.newCard"] = "New card!"
    translations[$ "ui.pressTabDeck"] = "Press TAB to open your deck"
    translations[$ "ui.noCardsYet"] = "No cards yet"
    translations[$ "ui.spaceNext"] = "SPACE >"

    translations[$ "screen.mainMenu"] = "MAIN MENU"
    translations[$ "screen.paused"] = "PAUSED"
    translations[$ "screen.settings"] = "SETTINGS"
    translations[$ "screen.album"] = "ALBUM"

    translations[$ "menu.continue"] = "Continue"
    translations[$ "menu.newGame"] = "New Game"
    translations[$ "menu.album"] = "Album"
    translations[$ "menu.settings"] = "Settings"
    translations[$ "menu.quit"] = "Quit"
    translations[$ "menu.resume"] = "Resume"
    translations[$ "menu.mainMenu"] = "Main Menu"
    translations[$ "menu.overwriteSave"] = "Overwrite your save?"
    translations[$ "menu.noKeepPlaying"] = "No, keep playing"
    translations[$ "menu.yesNewGame"] = "Yes, start new game"
    translations[$ "menu.resolution"] = "Resolution"
    translations[$ "menu.fullscreen"] = "Fullscreen"
    translations[$ "menu.masterVol"] = "Master Vol"
    translations[$ "menu.musicVol"] = "Music Vol"
    translations[$ "menu.soundsVol"] = "Sounds Vol"
    translations[$ "menu.apply"] = "Apply"
    translations[$ "menu.cancel"] = "Cancel"
    translations[$ "menu.back"] = "Back"
    translations[$ "menu.language"] = "Language"
    translations[$ "menu.on"] = "On"
    translations[$ "menu.off"] = "Off"

    translations[$ "battle.shuffle"] = "SHUFFLE"
    translations[$ "battle.info"] = "INFO"
    translations[$ "battle.run"] = "RUN"
    translations[$ "battle.cancel"] = "CANCEL"
    translations[$ "battle.waiting"] = "Waiting..."
    translations[$ "battle.stunnedSuffix"] = " is stunned..."
    translations[$ "battle.stunned"] = "STUNNED"
    translations[$ "battle.name"] = "Name: "
    translations[$ "battle.hp"] = "HP: "
    translations[$ "battle.mp"] = "MP: "
    translations[$ "battle.aura"] = "Aura: "
    translations[$ "battle.guts"] = "Guts: "
    translations[$ "battle.weakness"] = "Weakness:"

    translations[$ "shop.title"] = "STORE"
    translations[$ "shop.tabCards"] = "CARDS"
    translations[$ "shop.tabOther"] = "OTHER"
    translations[$ "shop.newSlot"] = "New deck slot"
    translations[$ "shop.slotDesc1"] = "Adds a deck card slot"
    translations[$ "shop.slotDesc2"] = "for both heroes"
    translations[$ "shop.type"] = "Type: "
    translations[$ "shop.typeAtc"] = "Atc"
    translations[$ "shop.typeCast"] = "Cast"
    translations[$ "shop.cost"] = "Cost: "
    translations[$ "shop.mp"] = "mp"
    translations[$ "shop.hp"] = "hp"
    translations[$ "shop.damageType"] = "Damage Type: "
    translations[$ "shop.magical"] = "magical"
    translations[$ "shop.physical"] = "physical"

    translations[$ "reward.type"] = "Type: "
    translations[$ "reward.attack"] = "Attack"
    translations[$ "reward.cast"] = "Cast"
    translations[$ "reward.damage"] = "Damage: "
    translations[$ "reward.heal"] = "Heal: "
    translations[$ "reward.effects"] = "Effects: "
    translations[$ "reward.cost"] = "Cost: "
    translations[$ "reward.mp"] = "MP"
    translations[$ "reward.hp"] = "HP"

    translations[$ "deck.magic"] = "MAGIC"
    translations[$ "deck.buff"] = "BUFF"
    translations[$ "deck.heal"] = "HEAL"
    translations[$ "deck.attack"] = "ATTACK"
    translations[$ "deck.special"] = "SPECIAL"
    translations[$ "deck.lana"] = "LANA"
    translations[$ "deck.viv"] = "VIV"

    translations[$ "effect.Damage"] = "Damage"
    translations[$ "effect.Heal"] = "Heal"
    translations[$ "effect.Stun"] = "Stun"
    translations[$ "effect.Buff"] = "Buff"
    translations[$ "effect.RemoveEffect"] = "Remove Effect"
    translations[$ "effect.ManaGain"] = "Mana Gain"
    translations[$ "effect.Weakening"] = "Weakening"
    translations[$ "effect.Debuff"] = "Debuff"
    translations[$ "effect.CopyCard"] = "Copy Card"
    translations[$ "effect.AddEnergy"] = "Add Energy"
    translations[$ "effect.ShuffleDeck"] = "Shuffle Deck"
    translations[$ "effect.Resurrection"] = "Resurrection"
    translations[$ "effect.CreatePuppet"] = "CreatePuppet"
    translations[$ "effect.Unknown"] = "Unknown"

    translations[$ "weakness.Stun"] = "Stun"
    translations[$ "weakness.Burn"] = "Burn"
    translations[$ "weakness.Freeze"] = "Freeze"
    translations[$ "weakness.Bleeding"] = "Bleed"
    translations[$ "weakness.Shock"] = "Shock"
    translations[$ "weakness.Bomb"] = "Bomb"
    translations[$ "weakness.Vampirism"] = "Vampirism"
    translations[$ "weakness.Weakening"] = "Weaken"
    translations[$ "weakness.Unknown"] = "?"

    translations[$ "unit.Lana"] = "Lana"
    translations[$ "unit.Viv"] = "Viv"
    translations[$ "unit.Safar"] = "Safar"
    translations[$ "unit.CrackerNut"] = "CrackerNut"
    translations[$ "unit.Leaf"] = "Leaf"
    translations[$ "unit.Mushroom"] = "Mushroom"
    translations[$ "unit.Flower"] = "Flower"
    translations[$ "unit.Puppet Master"] = "Puppet Master"
    translations[$ "unit.ignitePrefix"] = "Ignite "

    translations[$ "speaker.Lana"] = "Lana"
    translations[$ "speaker.Viv"] = "Viv"
    translations[$ "speaker.Safar"] = "Safar"
    translations[$ "speaker.Chest"] = "Chest"

    translations[$ "chest.goldPre"] = "You found "
    translations[$ "chest.goldPost"] = " gold!"
    translations[$ "chest.cardPre"] = "You found a card: "
    translations[$ "chest.cardPost"] = "!"
    translations[$ "chest.aCard"] = "a card"
    translations[$ "chest.trap"] = "It's a trap!"

    translations[$ "dlg.tut.ow1"] = "Wait - a wild Starrior! A good chance to learn how to fight."
    translations[$ "dlg.tut.ow2"] = "Don't worry, it's easy once you get the hang of the cards."
    translations[$ "dlg.tut.ow3"] = "Let's go. I'll walk you through it once the battle starts."
    translations[$ "dlg.tut.deck1"] = "Nice work! Now let's set up your deck for next time."
    translations[$ "dlg.tut.deck2"] = "Press Tab to open the deck builder."
    translations[$ "dlg.tut.battle1"] = "These are your cards. Each one is an action you can play on your turn."
    translations[$ "dlg.tut.battle2"] = "This is INFO - use it to inspect an enemy's stats before you act."
    translations[$ "dlg.tut.battle3"] = "This is SHUFFLE - it redraws your whole hand for this turn."
    translations[$ "dlg.tut.battle4"] = "That's everything. Now defeat this Starrior on your own. Good luck!"
    translations[$ "dlg.tut.db1"] = "This is your collection - every card you own. Cards already used in a deck are marked with an owner icon."
    translations[$ "dlg.tut.db2"] = "These are your decks. Select a card here to take it back out of the deck."
    translations[$ "dlg.tut.db3"] = "That's it - build your deck however you like. Press Tab to close it."

    translations[$ "dlg.safar.q1"] = "You need a companion on your journey?"
    translations[$ "dlg.safar.q2"] = "Help would be welcome."
    translations[$ "dlg.safar.q3"] = "Can't help you with that."
    translations[$ "dlg.safar.q4"] = "Then why even ask?!"
    translations[$ "dlg.safar.q5"] = "Fine - find my spear and I'll join you."
    translations[$ "dlg.safar.q6"] = "And where do we find it?"
    translations[$ "dlg.safar.q7"] = "A monster ran off with it while I slept. Without it I can't fight them."
    translations[$ "dlg.safar.optYes"] = "Alright, we'll find your spear"
    translations[$ "dlg.safar.optNo"] = "We're too busy right now"
    translations[$ "dlg.safar.waiting"] = "Found my spear yet? Use a Steal card on the monster carrying it."
    translations[$ "dlg.safar.done1"] = ":0 ... you actually all found it."
    translations[$ "dlg.safar.done2"] = "You can count on my skills now."

    translations[$ "card.name.physicalDamageSingleTarget"] = "Physical Strike"
    translations[$ "card.name.physicalDamageMultipleTarget"] = "Physical Strike (Group)"
    translations[$ "card.name.physicalDamageStunChanceSingleTarget"] = "Stunning Strike"
    translations[$ "card.name.physicalDamageStunChanceMultiTarget"] = "Stunning Strike (Group)"
    translations[$ "card.name.physicalDamageBleedChanceSingleTarget"] = "Bleeding Strike"
    translations[$ "card.name.physicalDamageBleedChanceMultiTarget"] = "Bleeding Strike (Group)"
    translations[$ "card.name.physicalDamageBombChanceSingleTarget"] = "Explosive Strike"
    translations[$ "card.name.physicalDamageBombChanceMultiTarget"] = "Explosive Strike (Group)"
    translations[$ "card.name.physicalDamageWeakenChanceSingleTarget"] = "Weakening Strike"
    translations[$ "card.name.physicalDamageWeakenChanceMultiTarget"] = "Weakening Strike (Group)"
    translations[$ "card.name.physicalDamageVampChanceSingleTarget"] = "Exhausting Strike"
    translations[$ "card.name.physicalDamageVampChanceMultiTarget"] = "Exhausting Strike (Group)"
    translations[$ "card.name.magicalDamageSingleTarget"] = "Star Strike"
    translations[$ "card.name.magicalDamageMultipleTarget"] = "Star Strike (Group)"
    translations[$ "card.name.magicalDamageStunChanceSingleTarget"] = "Lightning"
    translations[$ "card.name.magicalDamageStunChanceMultiTarget"] = "Lightning (Group)"
    translations[$ "card.name.magicalDamageBurnChanceSingleTarget"] = "Fire Strike"
    translations[$ "card.name.magicalDamageBurnChanceMultiTarget"] = "Fire Strike (Group)"
    translations[$ "card.name.magicalDamageFreezeChanceSingleTarget"] = "Frost Strike"
    translations[$ "card.name.magicalDamageFreezeChanceMultiTarget"] = "Frost Strike (Group)"
    translations[$ "card.name.buffPhysicalDamageSingleTarget"] = "Buff Physical damage"
    translations[$ "card.name.buffMagicalDamageSingleTarget"] = "Buff Magical Damage"
    translations[$ "card.name.buffAnyDamageMultiTarget"] = "Buff Any damage"
    translations[$ "card.name.buffPhysicalProtectionSingleTarget"] = "Buff physical protection"
    translations[$ "card.name.buffMagicalProtectionSingleTarget"] = "Buff magical protection"
    translations[$ "card.name.buffAnyProtectionMultiTarget"] = "Buff any protection"
    translations[$ "card.name.debuffPhysicalDamageSingleTarget"] = "Debuff physical damage"
    translations[$ "card.name.debuffMagicalDamageSingleTarget"] = "Debuff magical damage"
    translations[$ "card.name.debuffPhysicalProtectionSingleTarget"] = "Debuff physical protection"
    translations[$ "card.name.debuffMagicalProtectionSingleTarget"] = "Debuff magical protection"
    translations[$ "card.name.weaknessMagicalDamageSingleTarget"] = "Magic Vulnerability"
    translations[$ "card.name.weaknessPhysicalDamageSingleTarget"] = "Physical Vulnerability"
    translations[$ "card.name.ignoreWeaknessSingleTarget"] = "Show weakness"
    translations[$ "card.name.instantHealSingleTarget"] = "Heal"
    translations[$ "card.name.instantHealMultiTarget"] = "Heal (Group)"
    translations[$ "card.name.overtimeHealSingleTarget"] = "Heal overtime"
    translations[$ "card.name.instantManaGainSingleTarget"] = "Mana restore"
    translations[$ "card.name.instantManaGainMultiTarget"] = "Mana restore (Group)"
    translations[$ "card.name.overtimeManaGainSingleTarget"] = "Mana restore overtime"
    translations[$ "card.name.copyNextPlayedCard"] = "Copy next played card"
    translations[$ "card.name.addEnergy"] = "Extra Energy"
    translations[$ "card.name.shuffleDeck"] = "Shuffle"
    translations[$ "card.name.stealCard"] = "Steal"
    translations[$ "card.name.removeShock"] = "Cleanse: Shock"
    translations[$ "card.name.removeBurn"] = "Cleanse: Burn"
    translations[$ "card.name.removeFreeze"] = "Cleanse: Freeze"
    translations[$ "card.name.removeBleeding"] = "Cleanse: Bleed"
    translations[$ "card.name.removeStun"] = "Cleanse: Stun"
    translations[$ "card.name.resurrection"] = "Resurrection"
    translations[$ "card.name.summonAttackPuppet"] = "Attack Puppet"
    translations[$ "card.name.summonMagicPuppet"] = "Magic Puppet"
    translations[$ "card.name.summonHealPuppet"] = "Heal Puppet"
    translations[$ "card.name.summonBuffPuppet"] = "Buff Puppet"
    translations[$ "card.name.bossClone"] = "Clone"

    translations[$ "card.desc.physicalDamageSingleTarget"] = "deals minor physical damage (single)"
    translations[$ "card.desc.physicalDamageMultipleTarget"] = "deals minor physical damage (group)"
    translations[$ "card.desc.physicalDamageStunChanceSingleTarget"] = "deals minor physical damage, may stun (single)"
    translations[$ "card.desc.physicalDamageStunChanceMultiTarget"] = "deals minor physical damage, may stun (group)"
    translations[$ "card.desc.physicalDamageBleedChanceSingleTarget"] = "deals minor physical damage, may cause bleeding (single)"
    translations[$ "card.desc.physicalDamageBleedChanceMultiTarget"] = "deals minor physical damage, may cause bleeding (group)"
    translations[$ "card.desc.physicalDamageBombChanceSingleTarget"] = "deals minor physical damage with a bomb blast (single)"
    translations[$ "card.desc.physicalDamageBombChanceMultiTarget"] = "deals minor physical damage with a bomb blast (group)"
    translations[$ "card.desc.physicalDamageWeakenChanceSingleTarget"] = "deals minor physical damage, may weaken (single)"
    translations[$ "card.desc.physicalDamageWeakenChanceMultiTarget"] = "deals minor physical damage, may weaken (group)"
    translations[$ "card.desc.physicalDamageVampChanceSingleTarget"] = "deals minor physical damage, drains health (single)"
    translations[$ "card.desc.physicalDamageVampChanceMultiTarget"] = "deals minor physical damage, drains health (group)"
    translations[$ "card.desc.magicalDamageSingleTarget"] = "deals minor star energy damage (single)"
    translations[$ "card.desc.magicalDamageMultipleTarget"] = "deals minor star energy damage (group)"
    translations[$ "card.desc.magicalDamageStunChanceSingleTarget"] = "deals minor lightning damage (single)"
    translations[$ "card.desc.magicalDamageStunChanceMultiTarget"] = "deals minor lightning damage (group)"
    translations[$ "card.desc.magicalDamageBurnChanceSingleTarget"] = "deals minor fire damage (single)"
    translations[$ "card.desc.magicalDamageBurnChanceMultiTarget"] = "deals minor fire damage (group)"
    translations[$ "card.desc.magicalDamageFreezeChanceSingleTarget"] = "deals minor ice damage (single)"
    translations[$ "card.desc.magicalDamageFreezeChanceMultiTarget"] = "deals minor ice damage (group)"
    translations[$ "card.desc.buffPhysicalDamageSingleTarget"] = "slightly boosts physical damage (4 turns)"
    translations[$ "card.desc.buffMagicalDamageSingleTarget"] = "slightly boosts magic damage (1 turn)"
    translations[$ "card.desc.buffAnyDamageMultiTarget"] = "slightly boosts damage (1 turn)"
    translations[$ "card.desc.buffPhysicalProtectionSingleTarget"] = "slightly boosts physical defense (1 turn)"
    translations[$ "card.desc.buffMagicalProtectionSingleTarget"] = "slightly boosts magical defense (1 turn)"
    translations[$ "card.desc.buffAnyProtectionMultiTarget"] = "slightly boosts defense (1 turn)"
    translations[$ "card.desc.debuffPhysicalDamageSingleTarget"] = "slightly reduces physical damage (1 turn)"
    translations[$ "card.desc.debuffMagicalDamageSingleTarget"] = "slightly reduces magic damage (1 turn)"
    translations[$ "card.desc.debuffPhysicalProtectionSingleTarget"] = "slightly reduces physical defense (1 turn)"
    translations[$ "card.desc.debuffMagicalProtectionSingleTarget"] = "slightly reduces magical defense (1 turn)"
    translations[$ "card.desc.weaknessMagicalDamageSingleTarget"] = "vulnerability to magic damage (1 turn)"
    translations[$ "card.desc.weaknessPhysicalDamageSingleTarget"] = "vulnerability to physical damage (1 turn)"
    translations[$ "card.desc.ignoreWeaknessSingleTarget"] = "ignores weaknesses (2 turns)"
    translations[$ "card.desc.instantHealSingleTarget"] = "restores a small amount of health (single)"
    translations[$ "card.desc.instantHealMultiTarget"] = "restores a small amount of health (group)"
    translations[$ "card.desc.overtimeHealSingleTarget"] = "restores a small amount of health over 2 turns"
    translations[$ "card.desc.instantManaGainSingleTarget"] = "restores a small amount of mana (single)"
    translations[$ "card.desc.instantManaGainMultiTarget"] = "restores a small amount of mana (group)"
    translations[$ "card.desc.overtimeManaGainSingleTarget"] = "restores a small amount of mana over 2 turns"
    translations[$ "card.desc.copyNextPlayedCard"] = "copy next played card in hand"
    translations[$ "card.desc.addEnergy"] = "adds extra energy"
    translations[$ "card.desc.shuffleDeck"] = "shuffle"
    translations[$ "card.desc.stealCard"] = "copy a card from the enemy's hand"
    translations[$ "card.desc.removeShock"] = "remove the Shock status"
    translations[$ "card.desc.removeBurn"] = "remove the Burn status"
    translations[$ "card.desc.removeFreeze"] = "remove the Freeze status"
    translations[$ "card.desc.removeBleeding"] = "remove the Bleeding status"
    translations[$ "card.desc.removeStun"] = "remove the Stun status"
    translations[$ "card.desc.resurrection"] = "resurrection"
    translations[$ "card.desc.summonAttackPuppet"] = "create a weak puppet"
    translations[$ "card.desc.summonMagicPuppet"] = "create a weak puppet"
    translations[$ "card.desc.summonHealPuppet"] = "create a weak puppet"
    translations[$ "card.desc.summonBuffPuppet"] = "create a weak puppet"
    translations[$ "card.desc.bossClone"] = "clones itself into all empty slots"

    global.locStrings[$ "en"] = translations
}

// Определение русских локалей
function locDefineRu() {
    var translations = {}

    translations[$ "ui.victory"] = "ПОБЕДА"
    translations[$ "ui.gameover"] = "НЕПОВЕЗЛО"
    translations[$ "ui.noRewards"] = "Нет наград — нажмите Enter"
    translations[$ "ui.retry"] = "ЗАНОВО"
    translations[$ "ui.exit"] = "ВЫЙТИ"
    translations[$ "ui.close"] = "ЗАКРЫТЬ"
    translations[$ "ui.none"] = "Нет"
    translations[$ "ui.clickContinue"] = "Нажмите, чтобы продолжить"
    translations[$ "ui.newCard"] = "Новая карта!"
    translations[$ "ui.pressTabDeck"] = "Нажмите TAB, чтобы открыть колоду"
    translations[$ "ui.noCardsYet"] = "Пока нет карт"
    translations[$ "ui.spaceNext"] = "ПРОБЕЛ >"

    translations[$ "screen.mainMenu"] = "ГЛАВНОЕ МЕНЮ"
    translations[$ "screen.paused"] = "ПАУЗА"
    translations[$ "screen.settings"] = "НАСТРОЙКИ"
    translations[$ "screen.album"] = "АЛЬБОМ"

    translations[$ "menu.continue"] = "Продолжить"
    translations[$ "menu.newGame"] = "Новая игра"
    translations[$ "menu.album"] = "Альбом"
    translations[$ "menu.settings"] = "Настройки"
    translations[$ "menu.quit"] = "Выход"
    translations[$ "menu.resume"] = "Продолжить"
    translations[$ "menu.mainMenu"] = "Главное меню"
    translations[$ "menu.overwriteSave"] = "Перезаписать сохранение?"
    translations[$ "menu.noKeepPlaying"] = "Нет, продолжить игру"
    translations[$ "menu.yesNewGame"] = "Да, начать заново"
    translations[$ "menu.resolution"] = "Разрешение"
    translations[$ "menu.fullscreen"] = "Полный экран"
    translations[$ "menu.masterVol"] = "Общая громкость"
    translations[$ "menu.musicVol"] = "Музыка"
    translations[$ "menu.soundsVol"] = "Звуки"
    translations[$ "menu.apply"] = "Применить"
    translations[$ "menu.cancel"] = "Отмена"
    translations[$ "menu.back"] = "Назад"
    translations[$ "menu.language"] = "Язык"
    translations[$ "menu.on"] = "Вкл"
    translations[$ "menu.off"] = "Выкл"

    translations[$ "battle.shuffle"] = "ЗАМЕШАТЬ"
    translations[$ "battle.info"] = "ИНФО"
    translations[$ "battle.run"] = "ПОБЕГ"
    translations[$ "battle.cancel"] = "ОТМЕНА"
    translations[$ "battle.waiting"] = "Ожидание..."
    translations[$ "battle.stunnedSuffix"] = " оглушён..."
    translations[$ "battle.stunned"] = "ОГЛУШЕН"
    translations[$ "battle.name"] = "Имя: "
    translations[$ "battle.hp"] = "ЗДОРОВЬЕ: "
    translations[$ "battle.mp"] = "МАНА: "
    translations[$ "battle.aura"] = "Аура: "
    translations[$ "battle.guts"] = "Стойкость: "
    translations[$ "battle.weakness"] = "Слабости:"

    translations[$ "shop.title"] = "МАГАЗИН"
    translations[$ "shop.tabCards"] = "КАРТЫ"
    translations[$ "shop.tabOther"] = "ПРОЧЕЕ"
    translations[$ "shop.newSlot"] = "Новый слот колоды"
    translations[$ "shop.slotDesc1"] = "Добавляет слот карты"
    translations[$ "shop.slotDesc2"] = "для обоих героев"
    translations[$ "shop.type"] = "Тип: "
    translations[$ "shop.typeAtc"] = "Атака"
    translations[$ "shop.typeCast"] = "Магия"
    translations[$ "shop.cost"] = "Цена: "
    translations[$ "shop.mp"] = "мана"
    translations[$ "shop.hp"] = "здоровье"
    translations[$ "shop.damageType"] = "Тип урона: "
    translations[$ "shop.magical"] = "магический"
    translations[$ "shop.physical"] = "физический"

    translations[$ "reward.type"] = "Тип: "
    translations[$ "reward.attack"] = "Атака"
    translations[$ "reward.cast"] = "Магия"
    translations[$ "reward.damage"] = "Урон: "
    translations[$ "reward.heal"] = "Лечение: "
    translations[$ "reward.effects"] = "Эффекты: "
    translations[$ "reward.cost"] = "Цена: "
    translations[$ "reward.mp"] = "МАНА"
    translations[$ "reward.hp"] = "ЗДОРОВЬЕ"

    translations[$ "deck.magic"] = "МАГИЯ"
    translations[$ "deck.buff"] = "БАФФ"
    translations[$ "deck.heal"] = "ЛЕЧЕНИЕ"
    translations[$ "deck.attack"] = "АТАКА"
    translations[$ "deck.special"] = "ОСОБЫЕ"
    translations[$ "deck.lana"] = "ЛАНА"
    translations[$ "deck.viv"] = "ВИВ"

    translations[$ "effect.Damage"] = "Урон"
    translations[$ "effect.Heal"] = "Лечение"
    translations[$ "effect.Stun"] = "Оглушение"
    translations[$ "effect.Buff"] = "Усиление"
    translations[$ "effect.RemoveEffect"] = "Снятие эффекта"
    translations[$ "effect.ManaGain"] = "Восст. маны"
    translations[$ "effect.Weakening"] = "Ослабление"
    translations[$ "effect.Debuff"] = "Дебафф"
    translations[$ "effect.CopyCard"] = "Копия карты"
    translations[$ "effect.AddEnergy"] = "Доп. энергия"
    translations[$ "effect.ShuffleDeck"] = "Замешать"
    translations[$ "effect.Resurrection"] = "Воскрешение"
    translations[$ "effect.CreatePuppet"] = "Марионетка"
    translations[$ "effect.Unknown"] = "Неизвестно"

    translations[$ "weakness.Stun"] = "Оглушение"
    translations[$ "weakness.Burn"] = "Поджог"
    translations[$ "weakness.Freeze"] = "Заморозка"
    translations[$ "weakness.Bleeding"] = "Кровотечение"
    translations[$ "weakness.Shock"] = "Шок"
    translations[$ "weakness.Bomb"] = "Взрыв"
    translations[$ "weakness.Vampirism"] = "Вампиризм"
    translations[$ "weakness.Weakening"] = "Слабость"
    translations[$ "weakness.Unknown"] = "?"

    translations[$ "unit.Lana"] = "Лана"
    translations[$ "unit.Viv"] = "Вив"
    translations[$ "unit.Safar"] = "Сафар"
    translations[$ "unit.CrackerNut"] = "КрэкерНат"
    translations[$ "unit.Leaf"] = "Лиф"
    translations[$ "unit.Mushroom"] = "Машрум"
    translations[$ "unit.Flower"] = "Флоуер"
    translations[$ "unit.Puppet Master"] = "Паппет Мастер"
    translations[$ "unit.ignitePrefix"] = "Горящий "

    translations[$ "speaker.Lana"] = "Лана"
    translations[$ "speaker.Viv"] = "Вив"
    translations[$ "speaker.Safar"] = "Сафар"
    translations[$ "speaker.Chest"] = "Сундук"

    translations[$ "chest.goldPre"] = "Вы нашли "
    translations[$ "chest.goldPost"] = " золота!"
    translations[$ "chest.cardPre"] = "Вы нашли карту: "
    translations[$ "chest.cardPost"] = "!"
    translations[$ "chest.aCard"] = "карту"
    translations[$ "chest.trap"] = "Это ловушка!"

    translations[$ "dlg.tut.ow1"] = "Стой, Боец!  Давай научимся сражаться."
    translations[$ "dlg.tut.ow2"] = "Не переживай, с картами всё просто, нужно только освоиться."
    translations[$ "dlg.tut.ow3"] = "Идём. Я всё объясню, как только начнётся бой."
    translations[$ "dlg.tut.deck1"] = "Отличная работа! Теперь соберём твою колоду."
    translations[$ "dlg.tut.deck2"] = "Нажми Tab, чтобы открыть конструктор колоды."
    translations[$ "dlg.tut.battle1"] = "Это твои карты. Каждая - действие, которое можно сыграть в свой ход."
    translations[$ "dlg.tut.battle2"] = "Это ИНФОРМАЦИЯ - просмотри характеристики врага перед тем, как действовать."
    translations[$ "dlg.tut.battle3"] = "Это ЗАМЕШАТЬ - позволяет тебе собрать все карты вместе (включая сыгранные) и взять в руку"
    translations[$ "dlg.tut.battle4"] = "Вот и всё. Теперь одолей этого противника сам. Удачи!"
    translations[$ "dlg.tut.db1"] = "Это твоя коллекция - все карты, что у тебя есть. Карты, уже занятые в колоде, помечены значком владельца."
    translations[$ "dlg.tut.db2"] = "Это твои колоды. Выбери карту здесь, чтобы вернуть её из колоды."
    translations[$ "dlg.tut.db3"] = "Вот и всё - собирай колоду как хочешь. Нажми Tab или Esc, чтобы закрыть."

    translations[$ "dlg.safar.q1"] = "Нужен спутник в дорогу?"
    translations[$ "dlg.safar.q2"] = "Помощь бы не помешала."
    translations[$ "dlg.safar.q3"] = "С этим ничем не помогу."
    translations[$ "dlg.safar.q4"] = "Тогда зачем вообще спрашивать?!"
    translations[$ "dlg.safar.q5"] = "Ладно - найдите моё копьё, и я к вам присоединюсь."
    translations[$ "dlg.safar.q6"] = "И где нам его искать?"
    translations[$ "dlg.safar.q7"] = "Монстр утащил его, пока я спал. Без него мне с ними не справиться."
    translations[$ "dlg.safar.optYes"] = "Хорошо, мы найдём твоё копьё"
    translations[$ "dlg.safar.optNo"] = "Сейчас нам не до этого"
    translations[$ "dlg.safar.waiting"] = "Уже нашли моё копьё? Примени карту Кража на монстре, что его несёт."
    translations[$ "dlg.safar.done1"] = ":0 ... вы и правда его нашли."
    translations[$ "dlg.safar.done2"] = "Теперь можете рассчитывать на мои умения."

    translations[$ "card.name.physicalDamageSingleTarget"] = "Физический удар"
    translations[$ "card.name.physicalDamageMultipleTarget"] = "Физический удар (группа)"
    translations[$ "card.name.physicalDamageStunChanceSingleTarget"] = "Оглушающий удар"
    translations[$ "card.name.physicalDamageStunChanceMultiTarget"] = "Оглушающий удар (группа)"
    translations[$ "card.name.physicalDamageBleedChanceSingleTarget"] = "Удар с кровотечением"
    translations[$ "card.name.physicalDamageBleedChanceMultiTarget"] = "Удар с кровотечением (группа)"
    translations[$ "card.name.physicalDamageBombChanceSingleTarget"] = "Взрывной удар"
    translations[$ "card.name.physicalDamageBombChanceMultiTarget"] = "Взрывной удар (группа)"
    translations[$ "card.name.physicalDamageWeakenChanceSingleTarget"] = "Ослабляющий удар"
    translations[$ "card.name.physicalDamageWeakenChanceMultiTarget"] = "Ослабляющий удар (группа)"
    translations[$ "card.name.physicalDamageVampChanceSingleTarget"] = "Удар вампира"
    translations[$ "card.name.physicalDamageVampChanceMultiTarget"] = "Удар вампира (группа)"
    translations[$ "card.name.magicalDamageSingleTarget"] = "Звёздный удар"
    translations[$ "card.name.magicalDamageMultipleTarget"] = "Звёздный удар (группа)"
    translations[$ "card.name.magicalDamageStunChanceSingleTarget"] = "Молния"
    translations[$ "card.name.magicalDamageStunChanceMultiTarget"] = "Молния (группа)"
    translations[$ "card.name.magicalDamageBurnChanceSingleTarget"] = "Огненный удар"
    translations[$ "card.name.magicalDamageBurnChanceMultiTarget"] = "Огненный удар (группа)"
    translations[$ "card.name.magicalDamageFreezeChanceSingleTarget"] = "Ледяной удар"
    translations[$ "card.name.magicalDamageFreezeChanceMultiTarget"] = "Ледяной удар (группа)"
    translations[$ "card.name.buffPhysicalDamageSingleTarget"] = "Усиление физической силы"
    translations[$ "card.name.buffMagicalDamageSingleTarget"] = "Усиление магии"
    translations[$ "card.name.buffAnyDamageMultiTarget"] = "Усиление любого урона"
    translations[$ "card.name.buffPhysicalProtectionSingleTarget"] = "Бафф физической защиты"
    translations[$ "card.name.buffMagicalProtectionSingleTarget"] = "Бафф магической защиты"
    translations[$ "card.name.buffAnyProtectionMultiTarget"] = "Бафф всей защиты"
    translations[$ "card.name.debuffPhysicalDamageSingleTarget"] = "Ослабить физическую силу"
    translations[$ "card.name.debuffMagicalDamageSingleTarget"] = "Ослабить магию"
    translations[$ "card.name.debuffPhysicalProtectionSingleTarget"] = "Ослабить физическую защиту"
    translations[$ "card.name.debuffMagicalProtectionSingleTarget"] = "Ослабить магическую защиту"
    translations[$ "card.name.weaknessMagicalDamageSingleTarget"] = "Создать слабость к магии"
    translations[$ "card.name.weaknessPhysicalDamageSingleTarget"] = "Создать слабость к физ. атакам"
    translations[$ "card.name.ignoreWeaknessSingleTarget"] = "Игнорирование слабостей"
    translations[$ "card.name.instantHealSingleTarget"] = "Лечение"
    translations[$ "card.name.instantHealMultiTarget"] = "Лечение (группа)"
    translations[$ "card.name.overtimeHealSingleTarget"] = "Лечение со временем"
    translations[$ "card.name.instantManaGainSingleTarget"] = "Восстановить ману"
    translations[$ "card.name.instantManaGainMultiTarget"] = "Восстановить ману (группа)"
    translations[$ "card.name.overtimeManaGainSingleTarget"] = "Восстановить ману со временем"
    translations[$ "card.name.copyNextPlayedCard"] = "Копировать следующую разыгранную карту"
    translations[$ "card.name.addEnergy"] = "Доп. энергия"
    translations[$ "card.name.shuffleDeck"] = "Замешать"
    translations[$ "card.name.stealCard"] = "Украсть карту"
    translations[$ "card.name.removeShock"] = "Снять шок"
    translations[$ "card.name.removeBurn"] = "Снять поджог"
    translations[$ "card.name.removeFreeze"] = "Снять заморозку"
    translations[$ "card.name.removeBleeding"] = "Снять кровотечение"
    translations[$ "card.name.removeStun"] = "Снять оглушение"
    translations[$ "card.name.resurrection"] = "Воскрешение"
    translations[$ "card.name.summonAttackPuppet"] = "Создать Марионетку-бойца"
    translations[$ "card.name.summonMagicPuppet"] = "Создать Марионетку-мага"
    translations[$ "card.name.summonHealPuppet"] = "Создать Марионетку-лекаря"
    translations[$ "card.name.summonBuffPuppet"] = "Создать усиливающую Марионетку"
    translations[$ "card.name.bossClone"] = "Клонирование"

    translations[$ "card.desc.physicalDamageSingleTarget"] = "наносит небольшой физический урон (одна цель)"
    translations[$ "card.desc.physicalDamageMultipleTarget"] = "наносит небольшой физический урон (группа)"
    translations[$ "card.desc.physicalDamageStunChanceSingleTarget"] = "физический урон, шанс оглушения (одна цель)"
    translations[$ "card.desc.physicalDamageStunChanceMultiTarget"] = "физический урон, шанс оглушения (группа)"
    translations[$ "card.desc.physicalDamageBleedChanceSingleTarget"] = "физический урон, шанс кровотечения (одна цель)"
    translations[$ "card.desc.physicalDamageBleedChanceMultiTarget"] = "физический урон, шанс кровотечения (группа)"
    translations[$ "card.desc.physicalDamageBombChanceSingleTarget"] = "физический урон со взрывом (одна цель)"
    translations[$ "card.desc.physicalDamageBombChanceMultiTarget"] = "физический урон со взрывом (группа)"
    translations[$ "card.desc.physicalDamageWeakenChanceSingleTarget"] = "физический урон, шанс ослабить (одна цель)"
    translations[$ "card.desc.physicalDamageWeakenChanceMultiTarget"] = "физический урон, шанс ослабить (группа)"
    translations[$ "card.desc.physicalDamageVampChanceSingleTarget"] = "физический урон, крадёт здоровье (одна цель)"
    translations[$ "card.desc.physicalDamageVampChanceMultiTarget"] = "физический урон, крадёт здоровье (группа)"
    translations[$ "card.desc.magicalDamageSingleTarget"] = "урон звёздной энергией (одна цель)"
    translations[$ "card.desc.magicalDamageMultipleTarget"] = "урон звёздной энергией (группа)"
    translations[$ "card.desc.magicalDamageStunChanceSingleTarget"] = "урон молнией (одна цель)"
    translations[$ "card.desc.magicalDamageStunChanceMultiTarget"] = "урон молнией (группа)"
    translations[$ "card.desc.magicalDamageBurnChanceSingleTarget"] = "урон огнём (одна цель)"
    translations[$ "card.desc.magicalDamageBurnChanceMultiTarget"] = "урон огнём (группа)"
    translations[$ "card.desc.magicalDamageFreezeChanceSingleTarget"] = "урон льдом (одна цель)"
    translations[$ "card.desc.magicalDamageFreezeChanceMultiTarget"] = "урон льдом (группа)"
    translations[$ "card.desc.buffPhysicalDamageSingleTarget"] = "немного усиливает физ. урон (4 хода)"
    translations[$ "card.desc.buffMagicalDamageSingleTarget"] = "немного усиливает маг. урон (1 ход)"
    translations[$ "card.desc.buffAnyDamageMultiTarget"] = "немного усиливает урон (1 ход)"
    translations[$ "card.desc.buffPhysicalProtectionSingleTarget"] = "немного усиливает физ. защиту (1 ход)"
    translations[$ "card.desc.buffMagicalProtectionSingleTarget"] = "немного усиливает маг. защиту (1 ход)"
    translations[$ "card.desc.buffAnyProtectionMultiTarget"] = "немного усиливает защиту (1 ход)"
    translations[$ "card.desc.debuffPhysicalDamageSingleTarget"] = "немного снижает физ. урон врага (1 ход)"
    translations[$ "card.desc.debuffMagicalDamageSingleTarget"] = "немного снижает маг. урон врага (1 ход)"
    translations[$ "card.desc.debuffPhysicalProtectionSingleTarget"] = "немного снижает физ. защиту врага (1 ход)"
    translations[$ "card.desc.debuffMagicalProtectionSingleTarget"] = "немного снижает маг. защиту врага (1 ход)"
    translations[$ "card.desc.weaknessMagicalDamageSingleTarget"] = "уязвимость к маг. урону (1 ход)"
    translations[$ "card.desc.weaknessPhysicalDamageSingleTarget"] = "уязвимость к физ. урону (1 ход)"
    translations[$ "card.desc.ignoreWeaknessSingleTarget"] = "игнорирует слабости (2 хода)"
    translations[$ "card.desc.instantHealSingleTarget"] = "восстанавливает немного здоровья (одна цель)"
    translations[$ "card.desc.instantHealMultiTarget"] = "восстанавливает немного здоровья (группа)"
    translations[$ "card.desc.overtimeHealSingleTarget"] = "восстанавливает здоровье в течение 2 ходов"
    translations[$ "card.desc.instantManaGainSingleTarget"] = "восстанавливает немного маны (одна цель)"
    translations[$ "card.desc.instantManaGainMultiTarget"] = "восстанавливает немного маны (группа)"
    translations[$ "card.desc.overtimeManaGainSingleTarget"] = "восстанавливает ману в течение 2 ходов"
    translations[$ "card.desc.copyNextPlayedCard"] = "копирует следующую сыгранную карту"
    translations[$ "card.desc.addEnergy"] = "даёт дополнительную энергию"
    translations[$ "card.desc.shuffleDeck"] = "перемешивает колоду"
    translations[$ "card.desc.stealCard"] = "крадёт карту из руки врага"
    translations[$ "card.desc.removeShock"] = "снимает статус шока"
    translations[$ "card.desc.removeBurn"] = "снимает статус поджога"
    translations[$ "card.desc.removeFreeze"] = "снимает статус заморозки"
    translations[$ "card.desc.removeBleeding"] = "снимает статус кровотечения"
    translations[$ "card.desc.removeStun"] = "снимает статус оглушения"
    translations[$ "card.desc.resurrection"] = "воскрешает павшего союзника"
    translations[$ "card.desc.summonAttackPuppet"] = "создаёт марионетку-бойца"
    translations[$ "card.desc.summonMagicPuppet"] = "создаёт марионетку-мага"
    translations[$ "card.desc.summonHealPuppet"] = "создаёт марионетку-лекаря"
    translations[$ "card.desc.summonBuffPuppet"] = "создаёт усиливающую марионетку"
    translations[$ "card.desc.bossClone"] = "клонирует себя во все пустые слоты"

    global.locStrings[$ "ru"] = translations
}
