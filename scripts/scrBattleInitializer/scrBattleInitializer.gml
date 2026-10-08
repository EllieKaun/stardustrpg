function initBattleStates() {
    runConfirmCursor = 0 // 0 - остаться, 1 - сбежать
    runConfirmHitRects = []
    wantsCancel = method(self, function(input) {
        var cancelClicked = (input.clicked && cancelHitRect != undefined
            && pointInRect(input.guiX, input.guiY, cancelHitRect.x, cancelHitRect.y, cancelHitRect.w, cancelHitRect.h))
        return mouse_check_button_pressed(mb_right) || keyboard_check_pressed(ord("C")) || cancelClicked
    })
    cancelToCharacterPlay = method(self, function() {
        changeBattleState(BattleStates.CharacterPlay)
        unselectTargets()
        restoreSelection()
    })

    targetSelectStep = method(self, function(input) {
        var mouseConfirm = false
        if (input.moved || input.clicked) {
            var overTarget = selectTargetAtMouse()
            if (input.clicked && overTarget) { mouseConfirm = true }
        }
        var enterPressed = keyboard_check_pressed(vk_enter) || mouseConfirm
        var leftPressed = keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))
        var rightPressed = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))
        var changeIndex = leftPressed - rightPressed
        if (changeIndex != 0) {
            if (changeIndex < 0) { selectNextTarget() }
            else { selectPreviousTarget() }
        }
        if (enterPressed) {
            changeBattleState(BattleStates.PlayProcess)
            unselectTargets()
            var currentCard = selectedCharacter.getCardsInHand()[selectedCard]
            playCardAnimated(currentCard, selectedCharacter, selectedTarget)
        }
    })

    battleStates = array_create(19, undefined)

    var stateDef

    stateDef = array_create(StateHook.Count, undefined)
    stateDef[StateHook.Step] = method(self, function(input) {
        var hoveredCard = -1
        for (var i = array_length(cardHitRects) - 1; i >= 0; i--) {
            var hitRect = cardHitRects[i]
            if (pointInRotatedRect(input.guiX, input.guiY, hitRect.x, hitRect.y, hitRect.w, hitRect.h, hitRect.angle)) {
                hoveredCard = hitRect.index
                break
            }
        }
        var mouseConfirm = false
        if (hoveredCard >= 0) {
            if (input.moved) {
                focusArea = FocusArea.Deck
                if (selectedCard != hoveredCard) { playCardSelectSound() }
                selectedCard = hoveredCard
            }
            if (input.clicked) { focusArea = FocusArea.Deck; selectedCard = hoveredCard; mouseConfirm = true }
        } else {
            for (var i = 0; i < array_length(menuHitRects); i++) {
                var hitRect = menuHitRects[i]
                if (pointInRect(input.guiX, input.guiY, hitRect.x, hitRect.y, hitRect.w, hitRect.h)) {
                    if (input.clicked) { doMenuAction(hitRect.action) }
                    break
                }
            }
        }

        var enterPressed = keyboard_check_pressed(vk_enter) || mouseConfirm
        var leftPressed = keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))
        var rightPressed = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))

        if (keyboard_check_pressed(ord("R"))) { 
            doMenuAction(BattleMenuAction.Run)
            return 
        }
        if (keyboard_check_pressed(ord("S"))) { 
            doMenuAction(BattleMenuAction.Shuffle)
            return 
        }
        if (keyboard_check_pressed(ord("I"))) { 
            doMenuAction(BattleMenuAction.Info) 
            return 
        }
        if (keyboard_check_pressed(ord("P"))) { 
            doMenuAction(BattleMenuAction.Skip)
            return 
        }

        var handLen = array_length(selectedCharacter.getCardsInHand())
        if (leftPressed && handLen > 0) { 
            selectedCard = (selectedCard - 1 + handLen) mod handLen
            playCardSelectSound() 
        }
        if (rightPressed && handLen > 0) { 
            selectedCard = (selectedCard + 1) mod handLen       
            playCardSelectSound() 
        }

        if (enterPressed) {
            if (handLen > 0) {
                var currentCard = selectedCharacter.getCardsInHand()[selectedCard]
                if (!checkIfCanPlayCard(selectedCharacter, currentCard)) { return }
                if (currentCard.target == TargetTypes.SingleEnemyTarget) {
                    changeBattleState(BattleStates.EnemyTargetSelection)
                } else if (currentCard.target == TargetTypes.SingleAllyTarget) {
                    changeBattleState(BattleStates.AllyTargetSelection)
                    if (cardIsResurrection(currentCard)) { initTargetSelectionKO(heroes) }
                    else { initTargetSelection(heroes) }
                } else if (currentCard.target == TargetTypes.AllEnemies) {
                    playCardAnimated(currentCard, selectedCharacter, enemies)
                } else if (currentCard.target == TargetTypes.AllAllies) {
                    playCardAnimated(currentCard, selectedCharacter, heroes)
                } else if (currentCard.target == TargetTypes.Self) {
                    playCardAnimated(currentCard, selectedCharacter, selectedCharacter)
                }
            } else {
                skipTurn()
            }
        }
    })
    battleStates[BattleStates.CharacterPlay] = stateDef

    stateDef = array_create(StateHook.Count, undefined)
    stateDef[StateHook.OnEnter] = method(self, function() { initTargetSelection(enemies) })
    stateDef[StateHook.OnCancel] = cancelToCharacterPlay
    stateDef[StateHook.Step] = targetSelectStep
    battleStates[BattleStates.EnemyTargetSelection] = stateDef

    stateDef = array_create(StateHook.Count, undefined)
    stateDef[StateHook.OnCancel] = cancelToCharacterPlay
    stateDef[StateHook.Step] = targetSelectStep
    battleStates[BattleStates.AllyTargetSelection] = stateDef

    stateDef = array_create(StateHook.Count, undefined)
    stateDef[StateHook.OnEnter] = method(self, function() { initTargetSelection(array_concat(enemies, heroes)) })
    stateDef[StateHook.OnCancel] = cancelToCharacterPlay
    stateDef[StateHook.Step] = method(self, function(input) {
        var mouseConfirm = false
        if (input.moved || input.clicked) {
            var overTarget = selectTargetAtMouse()
            if (input.clicked && overTarget) { 
                mouseConfirm = true 
            }
        }
        var enterPressed = keyboard_check_pressed(vk_enter) || mouseConfirm
        if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) { 
            selectPreviousTarget() 
        }
        if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) { 
            selectNextTarget() 
        }
        if (enterPressed) { 
            changeBattleState(BattleStates.EnemyInfoDisplay) 
        }
    })
    battleStates[BattleStates.EnemyInfoSelection] = stateDef

    stateDef = array_create(StateHook.Count, undefined)
    stateDef[StateHook.OnCancel] = cancelToCharacterPlay
    stateDef[StateHook.Step] = method(self, function(input) {
        var mouseConfirm = false
        if (input.clicked && infoCloseRect != undefined
            && pointInRect(input.guiX, input.guiY, infoCloseRect.x, infoCloseRect.y, infoCloseRect.w, infoCloseRect.h)) {
            mouseConfirm = true
        }
        var enterPressed = keyboard_check_pressed(vk_enter) || mouseConfirm
        if (enterPressed) {
            changeBattleState(BattleStates.CharacterPlay)
            unselectTargets()
            restoreSelection()
        }
    })
    battleStates[BattleStates.EnemyInfoDisplay] = stateDef

    stateDef = array_create(StateHook.Count, undefined)
    stateDef[StateHook.Reentrant] = true
    stateDef[StateHook.OnEnter] = method(self, function() { alarm_set(ENEMYS_TURN, game_get_speed(gamespeed_fps) * 2) })
    battleStates[BattleStates.EnemysTurn] = stateDef

    stateDef = array_create(StateHook.Count, undefined)
    stateDef[StateHook.Reentrant] = true
    stateDef[StateHook.OnEnter] = method(self, function() { alarm_set(PUPPET_TURN, game_get_speed(gamespeed_fps) * 2) })
    battleStates[BattleStates.PuppetTurn] = stateDef

    stateDef = array_create(StateHook.Count, undefined)
    stateDef[StateHook.Reentrant] = true
    stateDef[StateHook.OnEnter] = method(self, function() {
        alarm_set(STUN_TURN, game_get_speed(gamespeed_fps) * STUN_TURN_SECONDS)
        with (selectedCharacter) drawDamageNumber((bbox_left + bbox_right) * 0.5, bbox_top - 20, loc("battle.stunned"), c_yellow, bbox_right - bbox_left)
    })
    battleStates[BattleStates.StunnedTurn] = stateDef

    stateDef = array_create(StateHook.Count, undefined)
    stateDef[StateHook.Step] = method(self, function(input) { stepVictoryScreen() })
    battleStates[BattleStates.Victory] = stateDef

    stateDef = array_create(StateHook.Count, undefined)
    stateDef[StateHook.OnEnter] = method(self, function() {
        loseAllGold()
        gameOverCursor = 0
        analyticsDefeat() // аналитика: поражение в бою
    })
    stateDef[StateHook.Step] = method(self, function(input) { stepGameOverScreen() })
    battleStates[BattleStates.GameOver] = stateDef

    stateDef = array_create(StateHook.Count, undefined)
    stateDef[StateHook.OnEnter] = method(self, function() { runConfirmCursor = 0 })
    stateDef[StateHook.OnCancel] = cancelToCharacterPlay
    stateDef[StateHook.Step] = method(self, function(input) {
        var confirm = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)
        if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) { runConfirmCursor = 0 }
        if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) { runConfirmCursor = 1 }
        for (var buttonIndex = 0; buttonIndex < array_length(runConfirmHitRects); buttonIndex++) {
            var hitRect = runConfirmHitRects[buttonIndex]
            if (pointInRect(input.guiX, input.guiY, hitRect.x, hitRect.y, hitRect.w, hitRect.h)) {
                if (input.moved || input.clicked) { runConfirmCursor = hitRect.index }
                if (input.clicked) { confirm = true }
                break
            }
        }
        if (!confirm) { return }
        if (runConfirmCursor == 1) { confirmBattleFlee() }
        else { changeBattleState(BattleStates.CharacterPlay) }
    })
    battleStates[BattleStates.RunConfirm] = stateDef

    drawCharacterMenu = method(self, function() {
        if (selectedCharacter == noone) { return }
        var scaleToGui = guiScale()
        var badgeScale = scaleToGui
        var badgeGap = 4 * scaleToGui
        var colMain = selectedCharacter.themeColor
        var colPanel = c_white

        var leftEdge = selectedCharacter.bbox_left * scaleToGui - 11 * scaleToGui
        var rightEdge = selectedCharacter.bbox_right * scaleToGui + 11 * scaleToGui
        var centerY = (selectedCharacter.bbox_top + selectedCharacter.bbox_bottom) * 0.5 * scaleToGui

        var shuffleSize = menuBadgeSize(loc("battle.shuffle"), badgeScale)
        var infoSize = menuBadgeSize(loc("battle.info"), badgeScale)
        var runSize = menuBadgeSize(loc("battle.run"), badgeScale)

        var rightStackH = shuffleSize.h + badgeGap + infoSize.h

        var shuffleX = rightEdge
        var shuffleY = centerY - rightStackH * 0.5
        drawMenuBadge(shuffleX, shuffleY, badgeScale, loc("battle.shuffle"), "S", true, colMain, colPanel)
        array_push(menuHitRects, { x: shuffleX, y: shuffleY, w: shuffleSize.w, h: shuffleSize.h, action: BattleMenuAction.Shuffle })

        var infoX = rightEdge
        var infoY = shuffleY + shuffleSize.h + badgeGap
        drawMenuBadge(infoX, infoY, badgeScale, loc("battle.info"), "I", true, colMain, colPanel)
        array_push(menuHitRects, { x: infoX, y: infoY, w: infoSize.w, h: infoSize.h, action: BattleMenuAction.Info })

        var skipSize = menuBadgeSize(loc("battle.skip"), badgeScale)
        var canFlee = !(variable_global_exists("battleNoFlee") && global.battleNoFlee)
        var leftStackH = canFlee ? (runSize.h + badgeGap + skipSize.h) : skipSize.h
        var leftY = centerY - leftStackH * 0.5

        if (canFlee) {
            var runX = leftEdge - runSize.w
            drawMenuBadge(runX, leftY, badgeScale, loc("battle.run"), "R", false, colMain, colPanel)
            array_push(menuHitRects, { x: runX, y: leftY, w: runSize.w, h: runSize.h, action: BattleMenuAction.Run })
            leftY += runSize.h + badgeGap
        }

        var skipX = leftEdge - skipSize.w
        drawMenuBadge(skipX, leftY, badgeScale, loc("battle.skip"), "P", false, colMain, colPanel)
        array_push(menuHitRects, { x: skipX, y: leftY, w: skipSize.w, h: skipSize.h, action: BattleMenuAction.Skip })
    })

    // Окно подтверждения побега
    drawRunConfirm = method(self, function() {
        var screenWidth = display_get_gui_width()
        var screenHeight = display_get_gui_height()
        var scaleToGui = guiScale()

        drawScreenDim(0.5)

        var popupWidth = screenWidth * 0.5
        var popupHeight = screenHeight * 0.34
        var popupX = floor((screenWidth - popupWidth) / 2)
        var popupY = floor((screenHeight - popupHeight) / 2)
        draw_sprite_stretched(box, 0, popupX, popupY, popupWidth, popupHeight)

        draw_set_halign(fa_center)
        draw_set_valign(fa_middle)
        draw_set_color(c_white)
        drawUiText(screenWidth / 2, popupY + popupHeight * 0.22, loc("battle.fleeTitle"), popupHeight * 0.16, popupWidth * 0.9)
        draw_set_color(merge_color(c_white, c_red, 0.5))
        drawUiText(screenWidth / 2, popupY + popupHeight * 0.45, loc("battle.fleeLose") + string(battleFleePenalty()),
            popupHeight * 0.13, popupWidth * 0.9)

        var labels = [loc("battle.fleeStay"), loc("battle.run")]
        var btnW = 72 * scaleToGui
        var btnH = 18 * scaleToGui
        var buttonGap = 16 * scaleToGui
        var startX = (screenWidth - (btnW * 2 + buttonGap)) / 2
        var btnY = floor(popupY + popupHeight * 0.66)
        runConfirmHitRects = []
        for (var buttonIndex = 0; buttonIndex < 2; buttonIndex++) {
            var buttonX = floor(startX + buttonIndex * (btnW + buttonGap))
            var isSelected = (runConfirmCursor == buttonIndex)
            array_push(runConfirmHitRects, { x: buttonX, y: btnY, w: btnW, h: btnH, index: buttonIndex })
            drawButtonFrame(buttonX, btnY, btnW, btnH)
            draw_set_color(isSelected ? c_yellow : c_white)
            drawUiText(buttonX + btnW / 2, btnY + btnH / 2, labels[buttonIndex], btnH * 0.55, btnW * 0.9)
            if (isSelected) {
                draw_sprite_ext(sPointer, 0, floor(buttonX - 10 * scaleToGui), floor(btnY + btnH / 2), scaleToGui, scaleToGui, 0, c_white, 1)
            }
        }

        draw_set_halign(fa_left)
        draw_set_valign(fa_top)
        draw_set_color(c_white)
    })

    drawCancelBadge = method(self, function() {
        if (selectedCharacter == noone) { return }
        var scaleToGui = guiScale()
        var cancelBadgeScale = scaleToGui
        var cancelColMain = selectedCharacter.themeColor
        var cancelSize = menuBadgeSize(loc("battle.cancel"), cancelBadgeScale)
        var cancelLeftEdge = selectedCharacter.bbox_left * scaleToGui - 11 * scaleToGui
        var cancelCenterY = (selectedCharacter.bbox_top + selectedCharacter.bbox_bottom) * 0.5 * scaleToGui
        var cancelX = max(0, cancelLeftEdge - cancelSize.w)
        var cancelY = cancelCenterY - cancelSize.h * 0.5
        drawMenuBadge(cancelX, cancelY, cancelBadgeScale, loc("battle.cancel"), "C", false, cancelColMain, c_white)
        cancelHitRect = { x: cancelX, y: cancelY, w: cancelSize.w, h: cancelSize.h }
    })

    drawEnemyInfo = method(self, function() {
        if (selectedTarget == noone) { return }
        var screenWidth = display_get_gui_width()
        var screenHeight = display_get_gui_height()
        var scaleToGui = guiScale()

        var popupWidth = screenWidth * 0.6
        var popupHeight = screenHeight * 0.72
        var popupX = (screenWidth - popupWidth) / 2
        var popupY = (screenHeight - popupHeight) / 2

        draw_sprite_stretched(box, 0, popupX, popupY, popupWidth, popupHeight)

        var margin = 16 * scaleToGui
        var spriteBoxSize = 64 * scaleToGui
        var spriteBoxX = popupX + margin
        var spriteBoxY = popupY + margin

        draw_set_color(c_white)
        draw_rectangle(spriteBoxX, spriteBoxY, spriteBoxX + spriteBoxSize, spriteBoxY + spriteBoxSize, false)

        if (sprite_exists(selectedTarget.sprite_index)) {
            var spriteWidth = sprite_get_width(selectedTarget.sprite_index)
            var spriteHeight = sprite_get_height(selectedTarget.sprite_index)
            var spriteScale = min(spriteBoxSize / spriteWidth, spriteBoxSize / spriteHeight)
            draw_sprite_ext(selectedTarget.sprite_index, 0,
                spriteBoxX + spriteBoxSize / 2,
                spriteBoxY + spriteBoxSize / 2,
                spriteScale, spriteScale, 0, c_white, 1)
        }

        var statsX = spriteBoxX + spriteBoxSize + margin
        var statsY = spriteBoxY
        var lineH = 14 * scaleToGui
        var popupTextH = lineH * 0.72
        var contentRight = popupX + popupWidth - margin
        draw_set_color(c_white)
        draw_set_halign(fa_left)
        var targetName = unitDisplayName(selectedTarget.name)
        if (variable_instance_exists(selectedTarget, "isIgnited") && selectedTarget.isIgnited) { targetName = loc("unit.ignitePrefix") + targetName }
        var rowY = statsY
        drawUiText(statsX, rowY, loc("battle.name") + targetName, popupTextH)
        rowY += lineH
        drawUiText(statsX, rowY, loc("battle.hp") + string(selectedTarget.hp) + "/" + string(selectedTarget.maxHp), popupTextH)
        rowY += lineH
        drawUiText(statsX, rowY, loc("battle.mp") + string(selectedTarget.mana) + "/" + string(selectedTarget.maxMana), popupTextH)
        rowY += lineH
        drawUiText(statsX, rowY, loc("battle.aura") + string(selectedTarget.aura), popupTextH)
        rowY += lineH
        drawUiText(statsX, rowY, loc("battle.guts") + string(selectedTarget.guts), popupTextH)
        rowY += lineH
        if (!selectedTarget.isEnemy) {
            drawUiText(statsX, rowY, loc("battle.strength") + string(selectedTarget.strength), popupTextH)
            rowY += lineH
            drawUiText(statsX, rowY, loc("battle.intelligence") + string(selectedTarget.intelligence), popupTextH)
            rowY += lineH
            drawUiText(statsX, rowY, loc("battle.energy") + string(selectedTarget.energy) + "/" + string(selectedTarget.maxEnergy), popupTextH)
            rowY += lineH
        }

        var weaknessY = rowY
        draw_set_halign(fa_left)
        var weaknessLabelText = loc("battle.weakness")
        var lblScale = drawUiText(statsX, weaknessY, weaknessLabelText, popupTextH)
        var weaknessX = statsX + string_width(weaknessLabelText) * lblScale + 6 * scaleToGui
        var weaknessList = variable_instance_exists(selectedTarget, "weaknesses") ? selectedTarget.weaknesses : []
        if (array_length(weaknessList) == 0) {
            drawUiText(weaknessX, weaknessY, loc("ui.none"), popupTextH)
        } else {
            var wIconSize = popupTextH
            for (var weaknessIndex = 0; weaknessIndex < array_length(weaknessList); weaknessIndex++) {
                var statusName = weaknessList[weaknessIndex]
                var statusIcon = weaknessIcon(statusName)
                if (statusIcon != noone) {
                    draw_sprite_stretched(statusIcon, 0, weaknessX, weaknessY, wIconSize, wIconSize)
                    weaknessX += wIconSize + 3 * scaleToGui
                }
                var statusLabel = weaknessLabel(statusName)
                var labelScale = drawUiText(weaknessX, weaknessY, statusLabel, popupTextH)
                weaknessX += string_width(statusLabel) * labelScale + 8 * scaleToGui
            }
        }
        draw_set_color(c_white)

        var effectY = weaknessY + lineH * 1.5
        draw_set_halign(fa_left)
        drawUiText(statsX, effectY, loc("battle.statuses"), popupTextH)
        effectY += lineH
        var targetEffects = selectedTarget.effects
        if (array_length(targetEffects) == 0) {
            drawUiText(statsX, effectY, loc("ui.none"), popupTextH)
        } else {
            for (var effectIndex = 0; effectIndex < array_length(targetEffects); effectIndex++) {
                var targetEffect = targetEffects[effectIndex]
                var icon = effectIcon(targetEffect)
                var textX = statsX
                if (icon != noone) {
                    draw_sprite_stretched(icon, 0, statsX, effectY, popupTextH, popupTextH)
                    textX = statsX + popupTextH + 4 * scaleToGui
                }
                var nameText = effectDisplayName(targetEffect)
                if (variable_instance_exists(targetEffect, "duration")) {
                    nameText += " (" + loc("status.turnsPre") + string(targetEffect.duration) + loc("status.turnsPost") + ")"
                }
                drawUiText(textX, effectY, nameText, popupTextH, contentRight - textX)
                effectY += lineH
                var descText = effectDescription(targetEffect)
                if (descText != "") {
                    var descResult = fitWrappedText(descText, contentRight - statsX, lineH * 2)
                    draw_set_font(descResult.font)
                    draw_text_transformed(floor(statsX), floor(effectY), descResult.text, descResult.scale, descResult.scale, 0)
                    effectY += string_height(descResult.text) * descResult.scale + 2 * scaleToGui
                }
            }
        }
        draw_set_color(c_white)

        // Close Button
        var btnWidth = 48 * scaleToGui
        var btnHeight = 16 * scaleToGui
        var btnX = floor(popupX + popupWidth / 2 - btnWidth / 2)
        var btnY = floor(popupY + popupHeight + 4 * scaleToGui)

        drawButtonFrame(btnX, btnY, btnWidth, btnHeight)
        draw_set_halign(fa_center)
        draw_set_valign(fa_middle)
        drawUiText(btnX + btnWidth / 2, btnY + btnHeight / 2, loc("ui.close"), btnHeight * 0.6)
        draw_set_valign(fa_top)
        draw_set_halign(fa_left)
        infoCloseRect = { x: btnX, y: btnY, w: btnWidth, h: btnHeight }

        // Pointer on Close Button
        draw_sprite_ext(sPointer, 0, btnX - 12 * scaleToGui, btnY + btnHeight / 2, scaleToGui, scaleToGui, 0, c_white, 1)
    })

    battleStates[BattleStates.CharacterPlay][StateHook.DrawUnder] = drawCharacterMenu
    battleStates[BattleStates.EnemyTargetSelection][StateHook.DrawUnder] = drawCancelBadge
    battleStates[BattleStates.AllyTargetSelection][StateHook.DrawUnder] = drawCancelBadge
    battleStates[BattleStates.EnemyInfoDisplay][StateHook.DrawOver] = drawEnemyInfo
    battleStates[BattleStates.Victory][StateHook.DrawOver] = method(self, function() { drawVictoryScreen() })
    battleStates[BattleStates.GameOver][StateHook.DrawOver] = method(self, function() { drawGameOverScreen() })
    battleStates[BattleStates.RunConfirm][StateHook.DrawOver] = drawRunConfirm

    stateAt = method(self, function(state) {
        return (state >= 0 && state < array_length(battleStates)) ? battleStates[state] : undefined
    })

    changeBattleState = method(self, function(newState) {
        var target = stateAt(newState)
        var reentrant = (target != undefined && target[StateHook.Reentrant] == true)
        if (battleState == newState && !reentrant) { return }

        var current = stateAt(battleState)
        if (current != undefined) {
            var onExit = current[StateHook.OnExit]
            if (onExit != undefined) { onExit() }
        }

        battleState = newState
        show_debug_message("battle state " + string(newState))

        if (target != undefined) {
            var onEnter = target[StateHook.OnEnter]
            if (onEnter != undefined) { onEnter() }
        }
    })
}