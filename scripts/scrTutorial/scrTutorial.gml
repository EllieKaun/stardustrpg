function tutorialOverworldLines() {
    var lana = asset_get_index("portraitLana")
    var vivPortrait = asset_get_index("portraitViv")
    return [
        dialogLine("Lana", lana, loc("dlg.tut.ow1")),
        dialogLine("Viv", vivPortrait, loc("dlg.tut.ow2")),
        dialogLine("Lana", lana, loc("dlg.tut.ow3"))
    ]
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
    var padding = max(4, screenHeight * 0.012)
    var spotlightLeft = rect.x - padding
    var spotlightTop = rect.y - padding
    var spotlightRight = rect.x + rect.w + padding
    var spotlightBottom = rect.y + rect.h + padding

    draw_set_color(c_black)
    draw_set_alpha(0.62)
    draw_rectangle(0, 0, screenWidth, spotlightTop, false)
    draw_rectangle(0, spotlightBottom, screenWidth, screenHeight, false)
    draw_rectangle(0, spotlightTop + 1, spotlightLeft, spotlightBottom - 1, false)
    draw_rectangle(spotlightRight, spotlightTop + 1, screenWidth, spotlightBottom - 1, false)
    draw_set_alpha(1)
    draw_set_color(c_white)
}
