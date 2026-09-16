function tutorialOverworldLines() {
    var lana = asset_get_index("placeholderLana")
    var viv = asset_get_index("placeholderViv")
    return [
        dialogLine("Lana", lana, "left", "Wait - a wild Starrior! A good chance to learn how to fight."),
        dialogLine("Viv", viv, "right", "Don't worry, it's easy once you get the hang of the cards."),
        dialogLine("Lana", lana, "left", "Let's go. I'll walk you through it once the battle starts.")
    ]
}

// Проигрывание шагов тутоирала. 
//Шаг: { text, speaker, portrait,
//   getRect() -> прямоугольник подсветки (или undefined полное затемнение),
//   advanceWhen() -> когда продвигаться (по умолчанию uiConfirmPressed),
//   onEnter() -> опционально при входе в шаг }.
function TutorialRunner(_steps) constructor {
    self.steps = _steps
    self.index = 0

    self.isActive = function() { return self.index < array_length(self.steps) }

    self.runOnEnter = function() {
        if (self.index >= array_length(self.steps)) return
        var s = self.steps[self.index]
        if (variable_struct_exists(s, "onEnter") && s.onEnter != undefined) s.onEnter()
    }

    self.reset = function() {
        self.index = 0
        self.runOnEnter()
    }

    // Обработка ввода
    self.step = function() {
        if (self.index >= array_length(self.steps)) return false
        var s = self.steps[self.index]
        var adv = variable_struct_exists(s, "advanceWhen") ? s.advanceWhen() : uiConfirmPressed()
        if (adv) {
            self.index++
            if (self.index >= array_length(self.steps)) return true
            self.runOnEnter()
        }
        return false
    }

    self.draw = function() {
        if (self.index >= array_length(self.steps)) return
        var s = self.steps[self.index]
        var rect = variable_struct_exists(s, "getRect") ? s.getRect() : undefined
        if (rect != undefined) drawTutorialSpotlight(rect)
        else drawScreenDim(0.55)
        var portrait = variable_struct_exists(s, "portrait") ? s.portrait : noone
        drawTutorialPanel(s.speaker, s.text, portrait)
        draw_set_halign(fa_left)
        draw_set_valign(fa_top)
        draw_set_color(c_white)
        draw_set_alpha(1)
    }
}

function deckTutorialIntroLines() {
    var lana = asset_get_index("placeholderLana")
    return [
        dialogLine("Lana", lana, "left", "Nice work! Now let's set up your deck for next time."),
        dialogLine("Lana", lana, "left", "Press Tab to open the deck builder.")
    ]
}

function drawTutorialSpotlight(rect) {
    var sw = display_get_gui_width()
    var sh = display_get_gui_height()
    var pad = max(4, sh * 0.012)
    var rx0 = rect.x - pad
    var ry0 = rect.y - pad
    var rx1 = rect.x + rect.w + pad
    var ry1 = rect.y + rect.h + pad

    draw_set_color(c_black)
    draw_set_alpha(0.62)
    draw_rectangle(0, 0, sw, ry0, false)
    draw_rectangle(0, ry1, sw, sh, false)
    draw_rectangle(0, ry0 + 1, rx0, ry1 - 1, false)
    draw_rectangle(rx1, ry0 + 1, sw, ry1 - 1, false)
    draw_set_alpha(1)

    var pulse = 0.4 + 0.6 * (0.5 + 0.5 * sin(current_time / 220))
    var bw = max(1, sh * 0.004)
    draw_set_color(merge_color(c_white, c_yellow, 0.45))
    draw_set_alpha(pulse)
    draw_rectangle(rx0, ry0, rx1, ry0 + bw, false)
    draw_rectangle(rx0, ry1 - bw, rx1, ry1, false)
    draw_rectangle(rx0, ry0, rx0 + bw, ry1, false)
    draw_rectangle(rx1 - bw, ry0, rx1, ry1, false)
    draw_set_alpha(1)
    draw_set_color(c_white)
}

function drawTutorialPanel(speaker, text, portrait) {
    var sw = display_get_gui_width()
    var sh = display_get_gui_height()

    var margin = sw * 0.05
    var panelH = sh * 0.17
    var panelY = sh * 0.03
    var panelX = margin
    var panelW = sw - margin * 2

    draw_sprite_stretched(box, 0, panelX, panelY, panelW, panelH)

    var pad = panelH * 0.14
    var pSize = panelH - pad * 2
    var portraitX = panelX + pad
    var portraitY = panelY + pad
    if (portrait != undefined && sprite_exists(portrait)) {
        draw_sprite_stretched(portrait, 0, portraitX, portraitY, pSize, pSize)
    }

    var textX = portraitX + pSize + pad
    var textTop = panelY + pad
    var textW = panelX + panelW - pad - textX
    var textH = panelH - pad * 2

    var nameH = textH * 0.26
    draw_set_color(merge_color(c_white, c_yellow, 0.5))
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    drawUiText(textX, textTop, speaker, nameH)

    draw_set_color(c_white)
    var bodyTop = textTop + nameH * 1.25
    var bodyH = textH - nameH * 1.25
    var prevFont = draw_get_font()
    var fit = fitWrappedText(text, textW, bodyH)
    if (fit != undefined) {
        draw_set_font(fit.font)
        draw_text_transformed(textX, bodyTop, fit.text, fit.scale, fit.scale, 0)
    }
    draw_set_font(prevFont)

    var hintH = nameH * 0.85
    draw_set_halign(fa_right)
    draw_set_color(merge_color(c_white, c_black, 0.35))
    drawUiText(panelX + panelW - pad, panelY + panelH - pad - hintH, "SPACE >", hintH)
    draw_set_halign(fa_left)
    draw_set_color(c_white)
}
