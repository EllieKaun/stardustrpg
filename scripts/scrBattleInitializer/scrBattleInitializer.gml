function initBattleStates() {
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
    stateDef[StateHook.OnEnter] = method(self, function() {
        var closeInfo = method(self, function() {
            changeBattleState(BattleStates.CharacterPlay)
            unselectTargets()
            restoreSelection()
        })
        modalOpen(modalEnemyInfo(selectedTarget, closeInfo))
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
    stateDef[StateHook.OnEnter] = method(self, function() {
        var pick = method(self, function(card) {
            unlockCard(card.cardRef.id, card.cardRef.rarity, 1)
            analyticsReward(card.cardRef.id, card.cardRef.rarity, "battle")
            playerDataSave()
            returnToOverworld()
        })
        var leave = method(self, function() { returnToOverworld() })
        modalOpen(modalCardChoice(rewardChoices, pick, leave))
    })
    battleStates[BattleStates.Victory] = stateDef

    stateDef = array_create(StateHook.Count, undefined)
    stateDef[StateHook.OnEnter] = method(self, function() {
        loseAllGold()
        analyticsDefeat() // аналитика: поражение в бою
        var retry = method(self, function() { retryBattle() })
        var exitToWorld = method(self, function() { returnToOverworld() })
        modalOpen(modalConfirm(loc("ui.gameover"), "", [
            { label: loc("ui.retry"), onSelect: retry },
            { label: loc("ui.exit"), onSelect: exitToWorld }
        ], { tag: "gameOver", background: undefined, dim: 0.6, widthFrac: 1, heightFrac: 0.4 }))
    })
    battleStates[BattleStates.GameOver] = stateDef

    stateDef = array_create(StateHook.Count, undefined)
    stateDef[StateHook.OnEnter] = method(self, function() {
        var backToPlay = method(self, function() { changeBattleState(BattleStates.CharacterPlay) })
        var flee = method(self, function() { confirmBattleFlee() })
        modalOpen(modalConfirm(
            loc("battle.fleeTitle"),
            loc("battle.fleeLose") + string(battleFleePenalty()),
            [{ label: loc("battle.fleeStay"), onSelect: backToPlay }, { label: loc("battle.run"), onSelect: flee }],
            { canCancel: true, onCancel: backToPlay, textColor: merge_color(c_white, c_red, 0.5) }
        ))
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

    battleStates[BattleStates.CharacterPlay][StateHook.DrawUnder] = drawCharacterMenu
    battleStates[BattleStates.EnemyTargetSelection][StateHook.DrawUnder] = drawCancelBadge
    battleStates[BattleStates.AllyTargetSelection][StateHook.DrawUnder] = drawCancelBadge

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