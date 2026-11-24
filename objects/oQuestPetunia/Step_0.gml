var questActive = (questState(QuestId.Fox) == QuestState.Active)
sprite_index = (nightValue() >= 0.6) ? sprNightPetunia : sprDayPetunia

if (myLight != noone && instance_exists(oLighting)) { myLight.intensity = questActive ? nightValue() : 0 }

if (questFoxItemDone(QuestFoxItem.Petunia)) { instance_destroy(); exit }

event_inherited()
