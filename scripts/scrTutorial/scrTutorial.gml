function tutorialOverworldLines() {
    var lana = asset_get_index("portraitLana")
    var viv = asset_get_index("portraitViv")
    return [
        dialogLine("Lana", lana, loc("dlg.tut.ow1")),
        dialogLine("Viv", viv, loc("dlg.tut.ow2")),
        dialogLine("Lana", lana, loc("dlg.tut.ow3"))
    ]
}

// Проигрывание шагов тутоирала. 
//Шаг: { text, speaker, portrait,
//   getRect() прямоугольник подсветки (или undefined полное затемнение),
//   advanceWhen() когда продвигаться (по умолчанию uiConfirmPressed),
//   onEnter() опционально при входе в шаг }.
function TutorialRunner(_steps) constructor {
    self.steps = _steps
    self.index = 0

    self.isActive = function() { return self.index < array_length(self.steps) }

    self.runOnEnter = function() {
        if (self.index >= array_length(self.steps)) { return }
        var tutorialStep = self.steps[self.index]
        if (variable_struct_exists(tutorialStep, "onEnter") && tutorialStep.onEnter != undefined) { tutorialStep.onEnter() }
    }

    self.reset = function() {
        self.index = 0
        self.runOnEnter()
    }

    // Обработка ввода
    self.step = function() {
        if (self.index >= array_length(self.steps)) { return false }
        var tutorialStep = self.steps[self.index]
        var shouldAdvance = variable_struct_exists(tutorialStep, "advanceWhen") ? tutorialStep.advanceWhen() : uiConfirmPressed()
        if (shouldAdvance) {
            self.index++
            if (self.index >= array_length(self.steps)) { return true }
            self.runOnEnter()
        }
        return false
    }

    self.draw = function() {
        if (self.index >= array_length(self.steps)) { return }
        var tutorialStep = self.steps[self.index]
        var rect = variable_struct_exists(tutorialStep, "getRect") ? tutorialStep.getRect() : undefined
        if (rect != undefined) { drawTutorialSpotlight(rect) }
        else { drawScreenDim(0.55) }
        var portrait = variable_struct_exists(tutorialStep, "portrait") ? tutorialStep.portrait : noone
        drawTutorialPanel(tutorialStep.speaker, tutorialStep.text, portrait, rect)
        draw_set_halign(fa_left)
        draw_set_valign(fa_top)
        draw_set_color(c_white)
        draw_set_alpha(1)
    }
}

function deckTutorialIntroLines() {
    var lana = asset_get_index("portraitLana")
    return [
        dialogLine("Lana", lana, loc("dlg.tut.deck1")),
        dialogLine("Lana", lana, loc("dlg.tut.deck2"))
    ]
}

function drawTutorialSpotlight(rect) {
    var screenWidth = display_get_gui_width()
    var screenHeight = display_get_gui_height()
    var pad = max(4, screenHeight * 0.012)
    var spotlightLeft = rect.x - pad
    var spotlightTop = rect.y - pad
    var spotlightRight = rect.x + rect.w + pad
    var spotlightBottom = rect.y + rect.h + pad

    draw_set_color(c_black)
    draw_set_alpha(0.62)
    draw_rectangle(0, 0, screenWidth, spotlightTop, false)
    draw_rectangle(0, spotlightBottom, screenWidth, screenHeight, false)
    draw_rectangle(0, spotlightTop + 1, spotlightLeft, spotlightBottom - 1, false)
    draw_rectangle(spotlightRight, spotlightTop + 1, screenWidth, spotlightBottom - 1, false)
    draw_set_alpha(1)
    draw_set_color(c_white)
}

function drawTutorialPanel(speaker, text, portrait, avoidRect) {
    var screenWidth = display_get_gui_width()
    var screenHeight = display_get_gui_height()

    var margin = screenWidth * 0.05
    var panelH = screenHeight * 0.17
    var panelY = screenHeight * 0.03
    var panelX = margin
    var panelW = screenWidth - margin * 2

    // Подсказки за пределеами выделенной области 
    if (avoidRect != undefined) {
        var topHit = (panelY < avoidRect.y + avoidRect.h) && (panelY + panelH > avoidRect.y)
        if (topHit) {
            var botY = screenHeight - screenHeight * 0.03 - panelH
            var botHit = (botY < avoidRect.y + avoidRect.h) && (botY + panelH > avoidRect.y)
            if (!botHit) {
                panelY = botY
            } else {
                var gapL = avoidRect.x
                var gapR = screenWidth - (avoidRect.x + avoidRect.w)
                var onRight = (gapR >= gapL)
                var gap = onRight ? gapR : gapL
                panelH = screenHeight * 0.32
                panelY = (screenHeight - panelH) * 0.5
                panelW = clamp(gap - margin * 1.2, screenWidth * 0.22, screenWidth * 0.46)
                if (onRight) {
                    panelX = (avoidRect.x + avoidRect.w) + (gap - panelW) * 0.5
                } else {
                    panelX = (gap - panelW) * 0.5
                }
            }
        }
    }

    draw_sprite_stretched(box, 0, panelX, panelY, panelW, panelH)

    var pad = panelH * 0.14
    var portraitSize = panelH - pad * 2
    var portraitX = panelX + pad
    var portraitY = panelY + pad
    if (portrait != undefined && sprite_exists(portrait)) {
        draw_sprite_stretched(portrait, 0, portraitX, portraitY, portraitSize, portraitSize)
    }

    var textX = portraitX + portraitSize + pad
    var textTop = panelY + pad
    var textW = panelX + panelW - pad - textX
    var textH = panelH - pad * 2

    var nameH = textH * 0.26
    draw_set_color(merge_color(c_white, c_yellow, 0.5))
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    drawUiText(textX, textTop, speakerDisplayName(speaker), nameH)

    var hintH = nameH * 0.8

    draw_set_color(c_white)
    var bodyTop = textTop + nameH * 1.25
    var bodyH = textH - nameH * 1.25 - hintH * 1.4
    var prevFont = draw_get_font()
    var fittedText = fitWrappedText(text, textW, bodyH)
    if (fittedText != undefined) {
        draw_set_font(fittedText.font)
        draw_text_transformed(textX, bodyTop, fittedText.text, fittedText.scale, fittedText.scale, 0)
    }
    draw_set_font(prevFont)

    draw_set_halign(fa_right)
    draw_set_color(merge_color(c_white, c_black, 0.35))
    drawUiText(panelX + panelW - pad, panelY + panelH - pad - hintH, loc("ui.spaceNext"), hintH)
    draw_set_halign(fa_left)
    draw_set_color(c_white)
}
