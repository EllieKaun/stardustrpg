function say(lines, onComplete = undefined) {
    with (oDialogManager) startDialog(lines, onComplete)
}

function dialogLine(speaker, portrait, side, text, onEnter = undefined) {
    return { speaker: speaker, portrait: portrait, side: side, text: text, onEnter: onEnter }
}