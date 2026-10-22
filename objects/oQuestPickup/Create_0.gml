questId = QuestId.Fox
itemKind = QuestFoxItem.PineCone
pickId = ""
pickupSound = noone
canBePicked = function() { return true }
isShown = function() { return questState(questId) == QuestState.Active }
