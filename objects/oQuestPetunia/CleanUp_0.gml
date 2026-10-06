if (myLight != noone && instance_exists(oLighting)) {
    oLighting.removeLight(myLight)
    myLight = noone
}
