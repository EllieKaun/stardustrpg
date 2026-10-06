image_index = (nightValue() >= 0.6) ? 1 : 0

if (myLight != noone && instance_exists(oLighting)) { myLight.intensity = nightValue() }

if (questFoxItemDone(QuestFoxItem.Petunia)) { instance_destroy(); exit }

event_inherited()
