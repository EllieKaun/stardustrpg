// Модалка подтверждения действия
function modalConfirm(title, text, buttons, overrides = {}) {
    var blocks = [ModalTitle(title, { h: 0.28 })]
    if (text != "") {
        array_push(blocks, ModalTitle(
            text, { h: 0.2, color: overrides[$ "textColor"] ?? c_white }
        ))
    }
    array_push(blocks, ModalButtons( buttons, { h: 0.3 }))
    return modalSpec(
        modalMerge({
            tag: "confirm",
            widthFrac: 0.5,
            heightFrac: 0.34,
            dim: 0.5,
            pages: [{ blocks: blocks }]
        }, overrides)
    )
}

// Диалоги персонажей и открытие сундуков 
function modalDialogPage(line) {
    var hasPortrait = (line.portrait != undefined && sprite_exists(line.portrait))
    var options = line[$ "options"]
    var textBlock = ModalText(line.text, {
        typewriter: true,
        align: hasPortrait ? fa_left : fa_center,
        valign: (options == undefined) ? fa_middle : fa_top
    })
    var blocks = [textBlock]
    if (options != undefined) {
        textBlock.h = (line.text == "") ? 0 : 0.45
        var items = []
        for (var optionIndex = 0; optionIndex < array_length(options); optionIndex++) {
            array_push(items, { label: options[optionIndex].text, onSelect: options[optionIndex].onSelect })
        }
        array_push(blocks, ModalOptions(items))
    }
    var extraBlocks = line[$ "extraBlocks"]
    if (extraBlocks != undefined) {
        for (var extraIndex = 0; extraIndex < array_length(extraBlocks); extraIndex++) { 
            array_push(blocks, extraBlocks[extraIndex]) 
        }
    }
    var page = { blocks: blocks, portrait: line.portrait, side: line.side, onEnter: line.onEnter }
    return modalMerge(page, line[$ "pageOverrides"] ?? {})
}

function modalDrawDialogPortrait(modalWindow, panel) {
    var line = modalWindow.page()
    var portrait = line[$ "portrait"]
    if (portrait == undefined || !sprite_exists(portrait)) { return }
    var portraitScale = floor(display_get_gui_height() * 0.36) / sprite_get_height(portrait)
    if (portraitScale >= 1) { portraitScale = floor(portraitScale) }
    var portraitW = sprite_get_width(portrait) * portraitScale
    var portraitH = sprite_get_height(portrait) * portraitScale
    var inset = panel.h * modalWindow.option("padding") * 1.5
    var onLeft = (line[$ "side"] != "right")
    var portraitLeft = onLeft ? (panel.x + inset) : (panel.x + panel.w - inset - portraitW)
    var portraitTop = panel.y + panel.h * 0.03 - portraitH
    draw_sprite_ext(portrait, 0,
        portraitLeft + sprite_get_xoffset(portrait) * portraitScale,
        portraitTop + sprite_get_yoffset(portrait) * portraitScale,
        portraitScale, portraitScale, 0, c_white, 1)
}

function modalDrawNextPointer(modalWindow, panel) {
    if (!modalWindow.fullyRevealed() || array_length(modalWindow.items) > 0) { return }
    var pointerScale = max(1, floor(guiScale() * 0.5))
    var padY = panel.h * modalWindow.option("padding")
    var pointerY = panel.y + panel.h - padY - pointerScale * 2 + floor(pointerScale * 2 * sin(current_time / 200))
    draw_sprite_ext(sPointer, 0, panel.x + panel.w - padY * 1.5, pointerY, pointerScale, pointerScale, 0, c_white, 1)
}

function modalDialog(lines, onComplete = undefined) {
    var pages = []
    for (var lineIndex = 0; lineIndex < array_length(lines); lineIndex++) {
        array_push(pages, modalDialogPage(lines[lineIndex]))
    }
    return modalSpec({
        tag: "dialog",
        layout: ModalLayout.Bottom,
        widthFrac: 0.96,
        heightFrac: 0.30,
        paddingXScale: 1.5,
        navAxis: "vertical",
        pages: pages,
        drawUnderPanel: modalDrawDialogPortrait,
        drawOverPanel: modalDrawNextPointer,
        onOpen: function() { guiSyncCrisp() },
        onClose: onComplete
    })
}

// Обучение
function modalTutorial(steps, onComplete = undefined) {
    var pages = []
    for (var stepIndex = 0; stepIndex < array_length(steps); stepIndex++) {
        var tutorialStep = steps[stepIndex]
        var page = {
            blocks: [
                ModalRow([
                    ModalSprite(tutorialStep[$ "portrait"] ?? noone, { w: "square", stretch: true }),
                    ModalColumn([
                        ModalTitle(speakerDisplayName(tutorialStep.speaker), { h: 0.26, align: fa_left, color: merge_color(c_white, c_yellow, 0.5) }),
                        ModalText(tutorialStep.text),
                        ModalTitle(loc("ui.spaceNext"), { h: 0.2, align: fa_right, color: merge_color(c_white, c_black, 0.35) })
                    ])
                ])
            ]
        }
        if (variable_struct_exists(tutorialStep, "getRect")) {
             page.spotlight = tutorialStep.getRect 
             }
        if (variable_struct_exists(tutorialStep, "advanceWhen")) { 
            page.advanceWhen = tutorialStep.advanceWhen 
        }
        if (variable_struct_exists(tutorialStep, "onEnter")) { 
            page.onEnter = tutorialStep.onEnter 
        }
        array_push(pages, page)
    }
    return modalSpec({
        tag: "tutorial",
        layout: ModalLayout.Top,
        widthFrac: 0.9,
        heightFrac: 0.17,
        padding: 0.14,
        dim: 0.55,
        pages: pages,
        onClose: onComplete
    })
}

// Новая карта
function modalNewCard(card, title = loc("ui.newCard")) {
    return modalSpec({
        tag: "newCard",
        widthFrac: 0.42,
        heightFrac: 0.7,
        padding: 0.05,
        inputGuard: 2,
        pages: [{ blocks: [
            ModalTitle(title, { h: 0.1, size: 0.9, color: merge_color(c_white, c_yellow, 0.4) }),
            ModalCard(card),
            ModalTitle(loc("ui.clickContinue"), { h: 0.06, color: merge_color(c_white, c_black, 0.3) })
        ] }]
    })
}

// Инфо о враге
function modalEnemyInfoRows(target) {
    var targetName = unitDisplayName(target.name)
    if (variable_instance_exists(target, "isIgnited") && target.isIgnited) { targetName = loc("unit.ignitePrefix") + targetName }
    var rows = [
        { text: loc("battle.name") + targetName },
        { text: loc("battle.hp") + string(target.hp) + "/" + string(target.maxHp) },
        { text: loc("battle.mp") + string(target.mana) + "/" + string(target.maxMana) }
    ]
    if (variable_instance_exists(target, "bonusHp") && target.bonusHp > 0) {
        array_push(rows, { text: loc("battle.bonusHp") + string(target.bonusHp) })
    }
    array_push(rows, { gap: true }, { text: loc("battle.statuses") })
    var targetEffects = target.effects
    if (array_length(targetEffects) == 0) { array_push(rows, { text: loc("ui.none") }) }
    for (var effectIndex = 0; effectIndex < array_length(targetEffects); effectIndex++) {
        var targetEffect = targetEffects[effectIndex]
        var nameText = effectDisplayName(targetEffect)
        if (variable_struct_exists(targetEffect, "duration")) {
            nameText += " (" + loc("status.turnsPre") + string(targetEffect.duration) + loc("status.turnsPost") + ")"
        }
        array_push(rows, { text: nameText, icon: effectIcon(targetEffect) })
        var descText = effectDescription(targetEffect)
        if (descText != "") { 
            array_push(rows, { text: descText, wrap: true }) 
        }
    }
    return rows
}

function modalEnemyInfo(target, onClose) {
    return modalSpec({
        tag: "enemyInfo",
        widthFrac: 0.6,
        heightFrac: 0.72,
        padding: 0.05,
        dim: 0,
        canCancel: true,
        onCancel: onClose,
        pages: [{ blocks: [
            ModalRow([
                ModalSprite(target.sprite_index, { w: 0.2, frame: true }),
                ModalLines(modalEnemyInfoRows(target))
            ]),
            ModalButtons([{ label: loc("ui.close"), onSelect: onClose }], { h: 0.1, buttonW: 48, buttonH: 16 })
        ] }]
    })
}

// Выбор карты при победе
function modalCardChoice(cards, onPick, onEmpty) {
    if (array_length(cards) == 0) {
        return modalSpec({
            tag: "cardChoice",
            layout: ModalLayout.FullScreen,
            background: undefined,
            dim: 0.5,
            onClose: onEmpty,
            pages: [{ blocks: [
                ModalTitle(loc("ui.victory"), { h: 0.12 }),
                ModalTitle(loc("ui.noRewards"), { h: 0.08 })
            ] }]
        })
    }
    var items = []
    for (var cardIndex = 0; cardIndex < array_length(cards); cardIndex++) {
        var card = cards[cardIndex]
        var owned = variable_struct_exists(card, "cardRef") 
            && getOwnedCount(card.cardRef.id, card.cardRef.rarity) > 0
        array_push(items, {
            card: card,
            note: owned ? loc("reward.alreadyOwned") : undefined,
            onSelect: method({ card: card, onPick: onPick }, function() { onPick(card) })
        })
    }
    return modalSpec({
        tag: "cardChoice",
        layout: ModalLayout.FullScreen,
        background: undefined,
        dim: 0.5,
        padding: 0.04,
        blockGap: 0.04,
        pages: [{ blocks: [
            ModalTitle(loc("ui.victory"), { h: 0.07 }),
            ModalTitle(loc("ui.chooseReward"), { h: 0.04, color: merge_color(c_white, c_yellow, 0.4) }),
            ModalCardChoice(items, { h: 0.45 }),
            ModalCardDetails()
        ] }]
    })
}