if (variable_global_exists("gaReady") && global.gaReady) {
    analyticsLog("onStop: сброс событий перед выходом")
    ga_onStop()
}

