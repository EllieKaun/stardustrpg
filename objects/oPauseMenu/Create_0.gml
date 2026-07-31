// Меню паузы в мире. Оверлей поверх оверворлда: 1 background + 1 foreground слой
// + пункты (пункты ВЫШЕ foreground). ПОЛНОСТЬЮ замораживает игру:
// instance_deactivate_all(true) останавливает Step/Alarm/пути у всех объектов,
// кроме самой паузы — спавн врагов, движение, камера, всё стоит.
// Открывается по Esc в оверворлде (см. oGameController). Закрытие — Esc / Resume.

// Запоминаем размер GUI оверворлда и поднимаем до размера окна (чёткий текст).
prevGuiW = display_get_gui_width()
prevGuiH = display_get_gui_height()
menuEnsureCrispGui()

// Полная заморозка: деактивируем всё, кроме этого оверлея.
instance_deactivate_all(true)
global.uiModal = true

// Пропустить ввод на первом кадре, чтобы Esc, которым открыли паузу, не закрыл её
// сразу (гонка с обработчиком в oGameController).
openedThisFrame = true

// Закрытие паузы: разморозить мир, восстановить GUI, снять модалку, удалить оверлей.
close = function() {
    instance_activate_all()
    display_set_gui_size(prevGuiW, prevGuiH)
    global.uiModal = false
    instance_destroy()
}

// --- Слои ---
// Мир на паузе не отрисовывается (объекты деактивированы), поэтому background —
// непрозрачный тёмный фон; foreground — декоративный слой поверх (плейсхолдер).
backLayers = [
    new MenuLayer(noone, { name: "pause-bg", alpha: 1,    placeholderColor: make_color_rgb(8, 10, 16) })
]
foreLayers = [
    new MenuLayer(noone, { name: "pause-fg", scrollX: 8, alpha: 0.35, placeholderColor: make_color_rgb(40, 46, 64) })
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
