#macro MODAL_RESULT_TEXT_LINE_H 16
#macro DIALOG_NAVY #3F3F74
#macro DIALOG_PORTRAIT_SIZE 66
#macro DIALOG_PORTRAIT_INSET 15
#macro DIALOG_PORTRAIT_OVERHANG 33

// общее содержимое диалогового окно с зголвком, звездами по углам, кнопками и тд
function modalPopupBlocks(title, bodyBlocks, buttons, heightFrac) {
    var edgeH = 0.08 / heightFrac
    var blocks = []
    if (title != "") { array_push(blocks, ModalTitle(title, { h: edgeH, size: 1, outline: true })) }
    array_push(blocks, ModalBox(bodyBlocks))
    if (array_length(buttons) > 0) { array_push(blocks, ModalButtons(buttons, { h: edgeH })) }
    return blocks
}

// настройки диалогового окна
function modalPopupOptions(heightFrac) {
    return {
        layout: ModalLayout.Center,
        widthFrac: 0.46,
        heightFrac: heightFrac,
        panelAspect: undefined,
        background: undefined,
        contentArea: undefined,
        padding: 0,
        blockGap: 0.02
    }
}

// диалоговое окно
function modalPopup(title, bodyBlocks, buttons, overrides = {}) {
    var heightFrac = overrides[$ "heightFrac"] ?? 0.5
    return modalSpec(
        modalMerge(
            modalMerge(modalPopupOptions(heightFrac), {
                tag: "popup",
                pages: [{ blocks: modalPopupBlocks(title, bodyBlocks, buttons, heightFrac) }]
            }),
            overrides
        )
    )
}

// диалоговое окно с кнопками подтвердения и отмены
function modalConfirm(title, text, buttons, overrides = {}) {
    var bodyBlocks = (text != "") ? [ModalText(text, { maxLineH: overrides[$ "textMaxLineH"] ?? 11 })] : []
    return modalPopup(title, bodyBlocks, buttons, modalMerge({ tag: "confirm" }, overrides))
}

// попап с диалогами персонажей или открытие сундука
function modalDialogPage(line) {
    var hasPortrait = (line.portrait != undefined && sprite_exists(line.portrait))
    var options = line[$ "options"]
    var textBlock = ModalText(line.text, { typewriter: true })
    var blocks = [textBlock]
    if (options != undefined) {
        textBlock.h = (line.text == "") ? 0 : 0.4
        var items = []
        for (var optionIndex = 0; optionIndex < array_length(options); optionIndex++) {
            array_push(items, { label: options[optionIndex].text, onSelect: options[optionIndex].onSelect })
        }
        array_push(blocks, ModalOptions(items, { minLines: 2, maxLineH: 10 }))
    }
    var page = { portrait: line.portrait, side: line.side, speaker: line.speaker, onEnter: line.onEnter }
    if (hasPortrait) {
        page.blocks = blocks
        return page
    }
    var heightFrac = 0.42
    modalMerge(page, modalPopupOptions(heightFrac))
    page.blocks = modalPopupBlocks(speakerDisplayName(line.speaker), blocks, [], heightFrac)
    return page
}

// расчет размера контента диалога
function modalDialogContentArea(modalWindow, panel) {
    var scaleToGui = guiScale()
    var portraitSpace = (DIALOG_PORTRAIT_INSET + DIALOG_PORTRAIT_SIZE + 5) * scaleToGui
    var padX = 10 * scaleToGui
    var padY = 5 * scaleToGui
    var line = modalWindow.page()
    var onLeft = (line[$ "side"] != "right")
    return {
        x: panel.x + (onLeft ? portraitSpace : padX),
        y: panel.y + padY,
        w: panel.w - portraitSpace - padX,
        h: panel.h - padY * 2
    }
}

// бэк диалогового окна
function modalDialogBackground(modalWindow) {
    return (modalWindow.panel.w >= display_get_gui_width() * 0.99) ? sprBoxDialogBig : sprBoxBig
}

// рисование портрета для диалогов в попапе
function modalDrawDialogPortrait(modalWindow, panel) {
    var line = modalWindow.page()
    var portrait = line[$ "portrait"]
    if (portrait == undefined || !sprite_exists(portrait)) { return }
    var scaleToGui = guiScale()
    var boxSize = DIALOG_PORTRAIT_SIZE * scaleToGui
    var inset = DIALOG_PORTRAIT_INSET * scaleToGui
    var onLeft = (line[$ "side"] != "right")
    var boxX = floor(onLeft ? panel.x + inset : panel.x + panel.w - inset - boxSize)
    var boxY = floor(panel.y - DIALOG_PORTRAIT_OVERHANG * scaleToGui)
    draw_sprite_stretched(sprBoxPortraitBig, 0, boxX, boxY, boxSize, boxSize)
    var frameSize = ceil(boxSize / sprite_get_width(sprBoxPortraitBig))
    var innerSize = boxSize - frameSize * 2
    draw_sprite_stretched(portrait, 0, boxX + frameSize, boxY + frameSize, innerSize, innerSize)

    var area = modalDialogContentArea(modalWindow, panel)
    draw_set_color(c_white)
    draw_set_halign(onLeft ? fa_left : fa_right)
    draw_set_valign(fa_bottom)
    drawUiTextOutline(onLeft ? area.x : area.x + area.w, panel.y - scaleToGui * 2, speakerDisplayName(line[$ "speaker"]), 10 * scaleToGui, c_black, max(2, round(scaleToGui * 0.75)), area.w)
    draw_set_halign(fa_left)
    draw_set_valign(fa_top)
}

// иконка переключения на следующую страницу
function modalDrawNextPointer(modalWindow, panel) {
    if (!modalWindow.fullyRevealed() || array_length(modalWindow.items) > 0) { return }
    if (modalWindow.option("advanceWhen") != undefined) { return }
    var scaleToGui = guiScale()
    var pointerScale = max(1, floor(scaleToGui * 0.5))
    var contentArea = modalWindow.option("contentArea")
    var right = panel.x + panel.w - scaleToGui * 12
    if (contentArea != undefined) {
        var area = contentArea(modalWindow, panel)
        right = area.x + area.w
    }
    var pointerY = panel.y + panel.h - scaleToGui * 10 + floor(pointerScale * 2 * sin(current_time / 200))
    draw_sprite_ext(sPointer, 0, right, pointerY, pointerScale, pointerScale, 0, c_white, 1)
}

// полное рисование разговора в диалоге
function modalDrawDialogOverlay(modalWindow, panel) {
    modalDrawDialogPortrait(modalWindow, panel)
    modalDrawNextPointer(modalWindow, panel)
}

// полная настройка диалога
function modalDialogSpec(pages, overrides) {
    return modalSpec(modalMerge({
        tag: "dialog",
        layout: ModalLayout.Bottom,
        widthFrac: 1,
        heightFrac: 0.267,
        background: modalDialogBackground,
        contentArea: modalDialogContentArea,
        navAxis: "vertical",
        pages: pages,
        drawOverPanel: modalDrawDialogOverlay,
        onOpen: function() { guiSyncCrisp() }
    }, overrides))
}

// конструтор диалога
function modalDialog(lines, onComplete = undefined) {
    var pages = []
    for (var lineIndex = 0; lineIndex < array_length(lines); lineIndex++) {
        array_push(pages, modalDialogPage(lines[lineIndex]))
    }
    return modalDialogSpec(pages, { onClose: onComplete })
}

// обучение с подсвеченной областью
function modalTutorial(steps, onComplete = undefined) {
    var pages = []
    for (var stepIndex = 0; stepIndex < array_length(steps); stepIndex++) {
        var tutorialStep = steps[stepIndex]
        var page = modalDialogPage(
            dialogLine(tutorialStep.speaker, tutorialStep[$ "portrait"] ?? noone, tutorialStep.text, tutorialStep[$ "onEnter"])
        )
        if (variable_struct_exists(tutorialStep, "getRect")) {
             page.spotlight = tutorialStep.getRect
        }
        if (variable_struct_exists(tutorialStep, "advanceWhen")) {
            page.advanceWhen = tutorialStep.advanceWhen
        }
        array_push(pages, page)
    }
    return modalDialogSpec(pages, {
        tag: "tutorial",
        layout: ModalLayout.Avoiding,
        dim: 0.55,
        onClose: onComplete
    })
}

// новая карта
function modalNewCard(card, title = loc("ui.newCard")) {
    return modalPopup(title, [ModalCard(card)], [], {
        tag: "newCard",
        heightFrac: 0.78,
        panelAspect: 0.85,
        inputGuard: 2
    })
}

// инфо о враге
function modalEnemyInfoRows(target) {
    var rows = [
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
    var targetName = unitDisplayName(target.name)
    if (variable_instance_exists(target, "isIgnited") && target.isIgnited) { targetName = loc("unit.ignitePrefix") + targetName }
    return modalPopup(
        targetName,
        [ModalLines(modalEnemyInfoRows(target))],
        [{ label: loc("ui.close"), onSelect: onClose, cancel: true }],
        { tag: "enemyInfo", heightFrac: 0.72, canCancel: true, onCancel: onClose }
    )
}

// выбор карты при победе
function modalCardChoice(cards, onPick, onEmpty) {
    if (array_length(cards) == 0) {
        return modalPopup(loc("ui.victory"), [ModalText(loc("ui.noRewards"), { maxLineH: MODAL_RESULT_TEXT_LINE_H })], [], { tag: "cardChoice", onClose: onEmpty })
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
        layout: ModalLayout.Center,
        widthFrac: 1,
        heightFrac: 0.96,
        padding: 0,
        blockGap: 0.02,
        dim: 0.8,
        pages: [{ blocks: [
            ModalTitle(loc("ui.victory"), { h: 0.13, size: 1, outline: true }),
            ModalTitle(loc("ui.chooseReward"), { h: 0.05, color: c_white, outline: false }),
            ModalCardChoice(items, { h: 0.75 })
        ] }]
    })
}
