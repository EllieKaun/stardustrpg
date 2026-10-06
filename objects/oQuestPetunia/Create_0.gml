event_inherited()

itemKind = QuestFoxItem.Petunia
pickupSound = asset_get_index("sndPickupPetunia")
canBePicked = function() { return nightValue() >= 0.6 }

myLight = noone

if (questFoxItemDone(QuestFoxItem.Petunia)) { instance_destroy(); exit }

if (instance_exists(oLighting)) {
    myLight = oLighting.addLight({
        x: x,
        y: y,
        radius: 40,
        color: make_color_rgb(200, 140, 255),
        intensity: 0,
        flicker: 0.05
    })
}
