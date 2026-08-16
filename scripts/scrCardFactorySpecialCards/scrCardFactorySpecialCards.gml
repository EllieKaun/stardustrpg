// Копирует следующую использованную карту и добавляет в руку героя - уникальная
function createCopyNextPlayedCardCard() {
    var rarity = CardsRarity.Default
    var targetType = TargetTypes.SingleAllyTarget
    return new Card(
        "CopyNextPlayedCard",
        rarity,
        targetType,
        StarriorStates.Cast,
        0,
        [ CopyCardEffect() ],
        mgcCard,
        cardCopy,
        commonBorder,
        hpCostToken
    )
}

// Дает дополнительный ход герою - уникальная
function createAddEnergyCard() {
    var rarity = CardsRarity.Default
    var targetType = TargetTypes.SingleAllyTarget
    return new Card(
        "AddEnergyCard",
        rarity,
        targetType,
        StarriorStates.Cast,
        0,
        [ AddEnergyEffect(1) ],
        mgcCard,
        extraTurn,
        commonBorder,
        hpCostToken
    )
}

// Перемешивает колоду без траты хода  - уникальная
function createShuffleDeckCard() {
    var rarity = CardsRarity.Default
    var targetType = TargetTypes.SingleAllyTarget
    return new Card(
        "ShuffleDeckCard",
        rarity,
        targetType,
        StarriorStates.Cast,
        0,
        [ ShuffleDeckEffect() ],
        mgcCard,
        shuffle,
        commonBorder,
        hpCostToken
    )
}

// Убирает слабость одного героя на х ходов - (Слабые места*)
function createCardIgnoreWeaknessSingleTarget() {
    return new Card(
        "Ignore Weakness",
        CardsRarity.Default,
        TargetTypes.SingleAllyTarget,
        StarriorStates.Cast,
        1,
        [ IgnoreWeaknessEffect(2) ],
        buffCard,
        weaknessNull,
        commonBorder,
        hpCostToken
    )
}

// Создать марионетку базовый метод
function createSummonPuppetCard(category, name, sprite) {
    return new Card(
        name, CardsRarity.Default,
        TargetTypes.Self, 
        StarriorStates.Cast,
        1,
        [ CreatePuppetEffect(category) ],
        mgcCard,
        sprite,
        commonBorder,
        hpCostToken
    )
}

// Марионетка физ атак
function createSummonAttackPuppetCard() { 
    return createSummonPuppetCard(CardCategory.Attack, "Attack Puppet", puppetAtc) 
}

// Марионетка маг атак
function createSummonMagicPuppetCard() { 
    return createSummonPuppetCard(CardCategory.Magic, "Magic Puppet", puppetMagic) 
}

// Марионетка хила
function createSummonHealPuppetCard() { 
    return createSummonPuppetCard(CardCategory.Heal, "Heal Puppet", puppetHeal) 
}

// Марионетка баффа
function createSummonBuffPuppetCard() {
    return createSummonPuppetCard(CardCategory.Buff, "Buff Puppet", puppetBuff)
}

// Эксклюзивная карта босса: клонирует себя во все свободные слоты команды.
// Вся логика — в обработчике "BossClone" реестра (scrEffectSystem).
function createBossCloneCard() {
    return new Card(
        "Mirror Legion", CardsRarity.Epic,
        TargetTypes.Self,
        StarriorStates.Cast,
        1,
        [ BossClone(5) ],
        mgcCard,
        lightningSingleTarget,
        commonBorder,
        hpCostToken
    )
}