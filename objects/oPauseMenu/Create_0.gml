// Меню паузы в мире. Оверлей поверх оверворлда: 1 background + 1 foreground слой
// + пункты (пункты ВЫШЕ foreground). Замораживает игру через global.gamePaused:
// Step-логика мировых объектов (спавн врагов, враги, камера, деревья) стоит, но
// их Draw продолжает рисовать — поэтому замороженный мир виден под меню.
// Esc (открытие и закрытие) обрабатывает oGameController; отсюда закрытие — close().

// Запоминаем размер GUI оверворлда и поднимаем до размера окна (чёткий текст).
prevGuiW = display_get_gui_width()
prevGuiH = display_get_gui_height()
menuEnsureCrispGui()

// Заморозка мира: gamePaused гейтит Step-логику мировых объектов (мир виден, но
// не обрабатывается). uiModal дополнительно блокирует героя и Tab/Ctrl.
global.gamePaused = true
global.uiModal = true

// Закрытие паузы: разморозить, восстановить GUI, снять модалку, удалить оверлей.
close = function() {
    global.gamePaused = false
    global.uiModal = false
    display_set_gui_size(prevGuiW, prevGuiH)
    instance_destroy()
}

// --- Слои ---
// background полупрозрачно затемняет замороженный мир; foreground — декоративный
// слой поверх (плейсхолдер, низкий alpha, чтобы мир просвечивал).
backLayers = [
    new MenuLayer(noone, { name: "pause-bg", alpha: 0.55, placeholderColor: make_color_rgb(6, 8, 14) })
]
foreLayers = [
    new MenuLayer(noone, { name: "pause-fg", scrollX: 8, alpha: 0.18, placeholderColor: make_color_rgb(40, 46, 64) })
]
itemsAboveForeground = true

// --- Пункты ---
// Resume привязан к этому инстансу через method(id, ...), чтобы close() вызвался
// в контексте объекта паузы. Quit завершает игру.
menu = new Menu([
    new MenuItem("Resume",   noone, noone, method(id, function(it) { close() })),
    new MenuItem("Settings", noone, noone, function(it) { show_debug_message("Pause: Settings") }),
    new MenuItem("Quit",     noone, noone, function(it) { game_end() })
], {
    anchorX: 0.5, startY: 0.42, spacing: 0.12, textH: 0.06, halign: fa_center
})

mouseLastX = -1
mouseLastY = -1
