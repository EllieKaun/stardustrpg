// Рисование описания наградной карты
function drawRewardDescription(card, panelX, panelY, panelW, panelH) {
    draw_sprite_stretched(box, 0, panelX, panelY, panelW, panelH) // Бэк
    if (card == undefined) { return }

    var guiScaleFactor = display_get_gui_width() / guiBaseWidth()
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
    draw_set_color(c_white)

    var textX = floor(panelX + 12 * guiScaleFactor)
    var textTopY = floor(panelY + 8 * guiScaleFactor)
    // высота строки — от высоты панели, чтобы текст заполнял её, а не терялся
    var lineHeight = min(16 * guiScaleFactor, panelH / 5.5)
    var textH = lineHeight * 0.85

    drawUiText(textX, textTopY, cardDisplayName(card), textH)
    drawUiText(textX, textTopY + lineHeight, loc("reward.type") + (card.actionType == StarriorStates.Attack ? loc("reward.attack") : loc("reward.cast")), textH)

    var lineY = textTopY + lineHeight * 2

    for (var effectIndex = 0; effectIndex < array_length(card.effects); effectIndex++) {
        var effect = card.effects[effectIndex]
        if (effect.type == EffectTypes.Damage || effect.type == EffectTypes.Heal) {
            var isAll = (card.target == TargetTypes.AllEnemies || card.target == TargetTypes.AllAllies)
            var maxNum = 0;
            switch (card.rarity) {
                case CardsRarity.Default: {
                    maxNum = isAll ? 2 : 4
                    break
                }
                case CardsRarity.Unusual: {
                    maxNum = isAll ? 4 : 6
                    break
                }
                case CardsRarity.Rare: {
                    maxNum = isAll ? 6 : 8
                    break
                }
                case CardsRarity.Epic: {
                    maxNum = isAll ? 8 : 12
                    break
                }
            }
            var label = (effect.type == EffectTypes.Damage) ? loc("reward.damage") : loc("reward.heal")
            drawUiText(textX, lineY, label + "1-" + string(maxNum), textH)
            lineY += lineHeight
            break
        }
    }

    var effectStr = "";
    for (var effectIndex = 0; effectIndex < array_length(card.effects); effectIndex++) {
        var effect = card.effects[effectIndex]
        if (effect.type != EffectTypes.Damage && effect.type != EffectTypes.Heal) {
            effectStr += effectTypeToString(effect.type) + " "
        }
    }
    if (effectStr != "") {
        drawUiText(textX, lineY, loc("reward.effects") + effectStr, textH)
        lineY += lineHeight
    }

    var costLabel = (card.costType() == CostType.Mana) ? loc("reward.mp") : loc("reward.hp")
    drawUiText(textX, lineY, loc("reward.cost") + string(card.costValue()) + " " + costLabel, textH)
}
