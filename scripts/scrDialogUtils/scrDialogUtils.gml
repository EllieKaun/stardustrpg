// Основной метод для вызова диалогов
function say(lines, onComplete = undefined) {
    with (oDialogManager) startDialog(lines, onComplete)
}

// Сторона портрета
function dialogSideFor(speaker) {
    return (speaker == "Lana" || speaker == "Viv") ? "left" : "right"
}

// Создать диалоговую линию
// Спикер - имя, портрет - спрайт (noone - без портрета, текст по центру)
// он ентер - коллбэк для каждой линии на всякий случай
function dialogLine(speaker, portrait, text, onEnter = undefined) {
    return { speaker: speaker, portrait: portrait, side: dialogSideFor(speaker), text: text, onEnter: onEnter }
}

// Диалоговая строка с выбором ответа
// options — массив { text, onSelect }
function dialogChoice(speaker, portrait, text, options) {
    return { speaker: speaker, portrait: portrait, side: dialogSideFor(speaker), text: text, onEnter: undefined, options: options }
}

function activeSpeaker() {
    var leader = oGameController.selected_character
    switch (leader) {
    	case oViv: return { id: "Viv", portrait: portraitViv }
        default: return { id: "Lana", portrait: portraitLana }
    }
}

function activeLine(text) {
    var speaker = activeSpeaker()
    return dialogLine(speaker.id, speaker.portrait, text)
}

function foxLine(text) {
    var portrait = asset_get_index("portraitFira")
    return dialogLine("Fox", sprite_exists(portrait) ? portrait : noone, text)
}