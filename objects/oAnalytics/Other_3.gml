/// @description Game End — досылаем накопленные события перед закрытием игры
// На десктопе (Windows) это важно, чтобы события не потерялись при выходе.
if (variable_global_exists("gaReady") && global.gaReady) {
    analyticsLog("onStop: сброс событий перед выходом")
    ga_onStop()
}

