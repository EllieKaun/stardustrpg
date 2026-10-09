var questActive = (questState(QuestId.Fox) == QuestState.Active)
image_index = (nightValue() >= 0.6) ? 1 : 0

if (myLight != noone && instance_exists(oLighting)) { myLight.intensity = questActive ? nightValue() : 0 }

if (questFoxItemDone(QuestFoxItem.Petunia)) { instance_destroy(); exit }

event_inherited()
