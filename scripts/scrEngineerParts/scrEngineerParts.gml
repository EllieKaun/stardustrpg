function partsAdd(character, count) {
    character.parts = min(PARTS_MAX, character.parts + count)
}

function partsCanPay(character, count) {
    return character.parts >= count
}

function partsSpend(character, count) {
    character.parts = max(0, character.parts - count)
}
