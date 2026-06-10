function createCrackerNutEncounter() {
    return [
        createStarrior(
            "Cracker",
            sprCrackerNutIdle, sprCrackerNutIdle, sprCrackerNutIdle, sprCrackerNutIdle,
            10, 10, -1, -1, 1, 1, 1000, 0, 0, 0,
            [createPhysicalDamageWeakeningChanseSingleTargetCard()]
        ),
        createStarrior(
            "Cracker",
            sprCrackerNutIdle, sprCrackerNutIdle, sprCrackerNutIdle, sprCrackerNutIdle,
            10, 10, -1, -1, 1, 1, 1000, 0, 0, 0,
            [createPhysicalDamageWeakeningChanseSingleTargetCard()]
        )
    ]
}

function createMushroomEncounter() {
    return [
        createStarrior(
            "Mushroom",
            sprMushroom, sprMushroom, sprMushroom, sprMushroom,
            12, 12, -1, -1, 1, 1, 800, 0, 0, 0,
            [ createPhysicalDamageBleedingChanseMultipleTargetCard() ]
        ),
        createStarrior(
            "Mushroom",
            sprMushroom, sprMushroom, sprMushroom, sprMushroom,
            12, 12, -1, -1, 1, 1, 800, 0, 0, 0,
            [ createPhysicalDamageBleedingChanseMultipleTargetCard() ]
        )
    ]
}