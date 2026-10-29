event_inherited()

itemKind = QuestFoxItem.PineCone
pickupSound = asset_get_index("sndPickupCone")
canBePicked = function() { return !questFoxItemDone(QuestFoxItem.PineCone) }
isShown = function() { return questState(questId) == QuestState.Active || questFoxItemDone(QuestFoxItem.PineCone) }
