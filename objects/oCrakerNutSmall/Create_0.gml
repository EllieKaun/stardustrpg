event_inherited();

rewardFactory = function() {
    return {
        ids: [
            "physicalDamageSingleTarget",
            "magicalDamageSingleTarget",
            "instantHealSingleTarget",
            "buffPhysicalDamageSingleTarget"
        ],
        rarities: [CardsRarity.Default, CardsRarity.Unusual, CardsRarity.Rare]
    }
}