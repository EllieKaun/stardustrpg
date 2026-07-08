// Основной метод для вызова диалогов
// Просто передаешь массив диалоговых линий и все
function say(lines, onComplete = undefined) {
    with (oDialogManager) startDialog(lines, onComplete)
}

// Создать диалоговую линию 
// Спикер - имя, портрет - спрайт, сторона - "left", "right" - на какой стороне рисовать портрет
// он ентер - коллбэк для каждой линии на всякий случай
function dialogLine(speaker, portrait, side, text, onEnter = undefined) {
    return { speaker: speaker, portrait: portrait, side: side, text: text, onEnter: onEnter }
}