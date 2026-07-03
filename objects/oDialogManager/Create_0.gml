active = false
lines = []
lineIndex = 0
charProgress = 0
charsPerStep = 0.8
onComplete = undefined

boxFont = fnM3x6_14
nameFont = fnM3x6_14
portraitSize = 96

startDialog = function(_lines, _onComplete = undefined) {
    if (array_length(_lines) == 0) {
        return
    }
    lines = _lines
    lineIndex = 0
    charProgress = 0
    onComplete = _onComplete
    active = true
    global.uiModal = true
    runLineEnter()
}

runLineEnter = function() {
    var line = lines[lineIndex]
    if (variable_struct_exists(ln, "onEnter") && line.onEnter != undefined) 
        line.onEnter()
}

currentText = function() { 
    return lines[lineIndex].text 
}

fullyRevealed = function() {
    return floor(charProgress) >= string_length(currentText())
}

advance = function() {
    if (!fullyRevealed()) { 
        charProgress = string_length(currentText())
        return;
    }
    lineIndex++
    if (lineIndex >= array_length(lines)) {
        endDialog()
    } else {
        charProgress = 0
        runLineEnter()
    }
}

endDialog = function() {
    active = false
    global.uiModal = false
    var callback = onComplete
    onComplete = undefined
    if (callback != undefined) 
        callback()
}