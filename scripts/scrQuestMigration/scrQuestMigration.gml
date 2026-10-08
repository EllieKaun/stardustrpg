//// Миграция квестовых данных из старых сейвов в playerData.quests

function questMigrateSaveData() {
    if (!variable_global_exists("playerData")) { return }
    var data = global.playerData
    if (!variable_struct_exists(data, "quests")) { data.quests = {} }

    questMigrateLegacyFox(data)
    questMigrateLegacySafar(data)
}

function questLegacyStateFromString(raw) {
    if (raw == "active") { return QuestState.Active }
    if (raw == "spearObtained" || raw == "itemsCollected" || raw == "ready") { return QuestState.Ready }
    if (raw == "completed") { return QuestState.Completed }
    return QuestState.Inactive
}

function questLegacyState(value, joined) {
    if (value == undefined) { return joined ? QuestState.Completed : QuestState.Inactive }
    if (is_string(value)) { return questLegacyStateFromString(value) }
    return value
}

function questMigrateLegacyFox(data) {
    if (variable_struct_exists(data.quests, string(QuestId.Fox))) { return }
    var record = { state: QuestState.Inactive, counters: {}, picked: [] }

    var legacyValue = variable_struct_exists(data, "questFox") ? data.questFox : undefined
    var joined = variable_global_exists("foxJoined") && global.foxJoined
    record.state = questLegacyState(legacyValue, joined)

    if (variable_struct_exists(data, "questFoxPineCones")) { record.counters[$ string(QuestFoxItem.PineCone)] = data.questFoxPineCones }
    if (variable_struct_exists(data, "questFoxPetunias"))  { record.counters[$ string(QuestFoxItem.Petunia)]  = data.questFoxPetunias }
    if (variable_struct_exists(data, "questFoxCauldrons")) { record.counters[$ string(QuestFoxItem.Cauldron)] = data.questFoxCauldrons }
    if (variable_struct_exists(data, "questFoxPickedIds")) { record.picked = data.questFoxPickedIds }

    data.quests[$ string(QuestId.Fox)] = record
}

function questMigrateLegacySafar(data) {
    if (variable_struct_exists(data.quests, string(QuestId.Safar))) { return }
    var record = { state: QuestState.Inactive, counters: {}, picked: [] }

    var legacyValue = variable_struct_exists(data, "questSafarSpear") ? data.questSafarSpear : undefined
    var joined = variable_global_exists("safarJoined") && global.safarJoined
    record.state = questLegacyState(legacyValue, joined)

    if (record.state == QuestState.Ready || record.state == QuestState.Completed) {
        record.counters[$ string(QuestSafarItem.Spear)] = 1
    }

    data.quests[$ string(QuestId.Safar)] = record
}
