//  Анимация розыгрыша карты 
//
//  Поведение задаётся функциями в конфиге:
//  путь (path), сглаживание (ease), исчезновение (fade),
//  частицы (particles)
//
//  Пример кастомизации:
//    var c = defaultCardAnimConfig()
//    c.path = pathLine // лететь по прямой
//    c.fade = fadeShrink 
//    c.dur = 60 
//    playCardAnimated(card, caster, targets, c)


function pathArc(from, to, progress, options) { // дуга вверх
    var controlX = (from.x + to.x) * 0.5
    var controlY = min(from.y, to.y) - options.arcHeight
    var lerpAX = lerp(from.x, controlX, progress), lerpAY = lerp(from.y, controlY, progress)
    var lerpBX = lerp(controlX, to.x, progress), lerpBY = lerp(controlY, to.y, progress)
    return { x: lerp(lerpAX, lerpBX, progress), y: lerp(lerpAY, lerpBY, progress) }
}

function pathLine(from, to, progress, options) { // по прямой
    return { x: lerp(from.x, to.x, progress), y: lerp(from.y, to.y, progress) }
}

// Стратегии сглаживания
function easeOutQuad(progress) { return 1 - power(1 - progress, 2) }
function easeLinear(progress) { return progress }
function easeInOutQuad(progress) { return (progress < 0.5) ? 2 * progress * progress : 1 - power(-2 * progress + 2, 2) * 0.5 }

// Стратегии исчезновения
function fadeTail(progress, anim) { return (progress < 0.6) ? 1 : 1 - (progress - 0.6) / 0.4 }  
function fadeNone(progress, anim) { return 1 }  
function fadeInOut(progress, anim) {
    if (progress < 0.15) { return progress / 0.15 }
    if (progress > 0.85) { return (1 - progress) / 0.15 }
    return 1
}
function fadeShrink(progress, anim) { 
    anim.scale = lerp(anim.cfg.scaleFrom, 0.15, progress)
    return 1
}

//  Конфиги по умолчанию 
function defaultCardAnimConfig() {
    return {
        dur: 40,
        toX: undefined, // undefined - центр GUI
        toY: undefined,
        toAngle: 0,
        scaleFrom: 1.12,
        scaleTo: 1.12,
        path: pathArc,
        arcHeight: 120,
        ease: easeOutQuad,
        fade: fadeTail,
        playOverlay: true,
        particles: defaultCardParticleConfig() // звёзды
    }
}

function drawCardAnimConfig() {
    var config = defaultCardAnimConfig()
    config.dur = 26
    config.arcHeight = 90
    config.scaleFrom = 1
    config.scaleTo = 1
    config.fade = fadeNone
    config.playOverlay = false
    return config
}

function defaultCardParticleConfig() {
    return {
        rate: 4, // сколько звёзд за кадр
        spawnUntil: 0.9, // прекратить спавн после этой доли пути
        posSpread: 0.4, // разброс появления (доля размера карты)
        backBias: 0.70, // скорость назад по движению (эффект следа)
        velJitter: 0.7, // случайная добавка к скорости
        lifeMin: 16, 
        lifeMax: 60,
        sizeMin: 2,  
        sizeMax: 5,
        rotSpeed: 8, // макс. скорость вращения
        gravity: 0.06,
        color: make_color_rgb(255, 236, 150), // золотой
        draw: drawStarSparkle // как рисовать одну частицу
    }
}

function damageCardParticleConfig() {
    return {
        rate: 2, // сколько звёзд за кадр
        spawnUntil: 0.9, // прекратить спавн после этой доли пути
        posSpread: 0.4, // разброс появления (доля размера карты)
        backBias: 0.30, // скорость назад по движению (эффект следа)
        velJitter: 0.7, // случайная добавка к скорости
        lifeMin: 16, 
        lifeMax: 60,
        sizeMin: 5,  
        sizeMax: 10,
        rotSpeed: 3, // макс. скорость вращения
        gravity: 0.2,
        color: make_color_rgb(247, 80, 36), // красный
        draw: drawRectSparkle // как рисовать одну частицу
    }
}

//  Анимация одной карты
function CardPlayAnim(card, fromX, fromY, fromAngle, cardW, cardH, onDone, cfg) constructor {
    self.card  = card
    self.cardW = cardW
    self.cardH = cardH
    self.cfg = cfg
    self.pcfg  = cfg.particles

    self.fromPt = { x: fromX, y: fromY }
    self.fromAngle = fromAngle
    self.toPt = {
        x: (cfg.toX == undefined) ? display_get_gui_width() * 0.5 : cfg.toX,
        y: (cfg.toY == undefined) ? display_get_gui_height() * 0.5 : cfg.toY
    }

    self.t = 0
    self.dur = cfg.dur
    self.done = false
    self.onDone = onDone; self.effectFired = false
    self.particles = []

    self.x = fromX
    self.y = fromY
    self.angle = fromAngle
    self.scale = cfg.scaleFrom
    self.alpha = 1

    self.playSpr = CardPlayAnimation
    self.playing = false
    self.playDone = false
    self.playFrame = 0
    self.cardHidden = false
    self.hideFrame = 11

    static update = function() {
        // множитель для ui: масштабирует абсолютные размеры/скорости частиц
        var uiScale = display_get_gui_width() / guiBaseWidth()
        if (!done) {
            var prevX = x, prevY = y // позиция до шага 
            t = min(t + 1, dur)
            var progress = t / dur
            var easedProgress = cfg.ease(progress) // сглаженное время

            var point = cfg.path(fromPt, toPt, easedProgress, cfg) // позиция по стратегии пути
            x = point.x
            y = point.y
            angle = lerp(fromAngle, cfg.toAngle, easedProgress)
            scale = lerp(cfg.scaleFrom, cfg.scaleTo, easedProgress)
            alpha = cfg.fade(progress, self) // исчезновение по стратегии

            // эмиттер частиц
            if (progress < pcfg.spawnUntil) {
                repeat (pcfg.rate) {
                    var particle = {
                        x: x + random_range(-cardW * pcfg.posSpread, cardW * pcfg.posSpread),
                        y: y + random_range(-cardH * pcfg.posSpread, cardH * pcfg.posSpread),
                        vx: (prevX - x) * pcfg.backBias + random_range(-pcfg.velJitter, pcfg.velJitter) * uiScale,
                        vy: (prevY - y) * pcfg.backBias + random_range(-pcfg.velJitter, pcfg.velJitter) * uiScale,
                        life: irandom_range(pcfg.lifeMin, pcfg.lifeMax),
                        maxlife: 1,
                        size: random_range(pcfg.sizeMin, pcfg.sizeMax) * uiScale,
                        rot: random(360),
                        rotSpeed: random_range(-pcfg.rotSpeed, pcfg.rotSpeed),
                        spr: choose(StarParticle1, StarParticle2, StarParticle3)
                    };
                    particle.maxlife = particle.life
                    array_push(particles, particle)
                }
            }

            if (t >= dur) {
                done = true
                if (onDone != undefined && !effectFired) {
                    effectFired = true
                    onDone(self)
                }
                if (cfg.playOverlay && sprite_exists(playSpr)) { playing = true }
                else { playDone = true }
            }
        }

        if (playing && !playDone) {
            var frameSpeed = sprite_get_speed(playSpr)
            if (sprite_get_speed_type(playSpr) == spritespeed_framespersecond) {
                frameSpeed /= game_get_speed(gamespeed_fps)
            }
            playFrame += frameSpeed
            if (playFrame >= hideFrame) { cardHidden = true }
            var lastFrame = sprite_get_number(playSpr) - 1
            if (playFrame >= lastFrame) { 
                playFrame = lastFrame
                playDone = true 
            }
        }

        // частицы живут и после приземления карты
        for (var i = array_length(particles) - 1; i >= 0; i--) {
            var particle = particles[i]
            particle.x += particle.vx; particle.y += particle.vy; particle.vy += pcfg.gravity * uiScale
            particle.rot += particle.rotSpeed
            particle.life -= 1
            if (particle.life <= 0) { array_delete(particles, i, 1) }
        }
    }

    static finished = function() {
        return done && playDone && array_length(particles) == 0
    }

    static draw = function() {
        // частицы под картой
        gpu_set_fog(true, pcfg.color, 0, 0)
        for (var i = 0; i < array_length(particles); i++) {
            var particle = particles[i];
            var lifeRatio = particle.life / particle.maxlife;
            var pscale = (particle.size * lifeRatio * 2) / sprite_get_width(particle.spr)
            draw_sprite_ext(particle.spr, 0, particle.x, particle.y, pscale, pscale, particle.rot, c_white, lifeRatio)
        }
        gpu_set_fog(false, pcfg.color, 0, 0)
        if (!cardHidden) {
            drawCardFace(card, x, y, cardW, cardH, angle, scale)
        }

        if (playing) {
            var aScale = (cardH * scale) / (sprite_get_bbox_bottom(playSpr) - sprite_get_bbox_top(playSpr))
            draw_sprite_ext(playSpr, floor(playFrame), x, y, aScale, aScale, angle, c_white, 1)
        }
    }
}

// Рисует 4-конечную звёздочку, outer — размер лучей
function drawStarSparkle(centerX, centerY, outerRadius, rotation, alphaValue, color) {
    if (outerRadius <= 0) { return }
    var inner = outerRadius * 0.4
    draw_set_color(color)
    draw_set_alpha(alphaValue)
    draw_primitive_begin(pr_trianglefan)
    draw_vertex(centerX, centerY)
    for (var angle = 0; angle <= 360; angle += 45) {
        var radius = ((angle mod 90) == 0) ? outerRadius : inner  // 0/90/180/270 — лучи, между — впадины
        draw_vertex(centerX + lengthdir_x(radius, angle + rotation), centerY + lengthdir_y(radius, angle + rotation))
    }
    draw_primitive_end()
    draw_set_alpha(1)
    draw_set_color(c_white)
}

// Квадрат. outer — радиус до угла 
function drawRectSparkle(centerX, centerY, outerRadius, rotation, alphaValue, color) {
    if (outerRadius <= 0) {
        return
    }
    draw_set_color(color)
    draw_set_alpha(alphaValue)
    draw_primitive_begin(pr_trianglefan)
    draw_vertex(centerX, centerY) // центр веера
    for (var angle = 45; angle <= 405; angle += 90) { // 4 угла (+замыкание)
        draw_vertex(centerX + lengthdir_x(outerRadius, angle + rotation), centerY + lengthdir_y(outerRadius, angle + rotation))
    }
    draw_primitive_end()
    draw_set_alpha(1)
    draw_set_color(c_white)
}

// Равносторонний треугольник. outer — радиус от центра до вершины
function drawTriangleSparkle(centerX, centerY, outerRadius, rotation, alphaValue, color) {
    if (outerRadius <= 0) { return }
    draw_set_color(color)
    draw_set_alpha(alphaValue)
    draw_primitive_begin(pr_trianglelist)
    for (var angle = -90; angle < 270; angle += 120) { // 3 вершины через 120°
        draw_vertex(centerX + lengthdir_x(outerRadius, angle + rotation), centerY + lengthdir_y(outerRadius, angle + rotation))
    }
    draw_primitive_end()
    draw_set_alpha(1)
    draw_set_color(c_white)
}

// Круг. outer — радиус
function drawCircleSparkle(centerX, centerY, outerRadius, rotation, alphaValue, color) {
    if (outerRadius <= 0) {
        return
    }
    draw_set_color(color)
    draw_set_alpha(alphaValue)
    draw_primitive_begin(pr_trianglefan)
    draw_vertex(centerX, centerY) // центр
    for (var angle = 0; angle <= 360; angle += 30) { // 12 сегментов
        draw_vertex(centerX + lengthdir_x(outerRadius, angle), centerY + lengthdir_y(outerRadius, angle))
    }
    draw_primitive_end()
}


//  Геометрия стола
function cardDeskGeometry() {
    // координаты GUI
    var screenWidth = display_get_gui_width()
    var screenHeight = display_get_gui_height()
    var guiScaleFactor = guiScale()

    var deskH = screenHeight / 3
    var cardSpacing = 6 * guiScaleFactor
    var cardH = deskH - (5 + 3) * guiScaleFactor
    var cardW = cardH * 2 / 3
    var deskW = cardW * maxCardsOnDeskNumber + cardSpacing * (maxCardsOnDeskNumber + 1)
    var startX = (screenWidth - deskW) / 2
    var startY = screenHeight - deskH

    var vPad = 8 * guiScaleFactor
    var drawCardH = deskH - vPad * 2
    var drawCardW = drawCardH * 2 / 3

    return {
        deskW: deskW, deskH: deskH,
        drawCardW: drawCardW, drawCardH: drawCardH,
        handCenterX: startX + deskW / 2,
        handCenterY: startY + deskH / 2 + deskH * 0.08
    }
}

function selectedCardTransform() {
    var geometry = cardDeskGeometry()
    var guiScaleFactor = display_get_gui_width() / guiBaseWidth()
    var hand = selectedCharacter.getCardsInHand()
    var handCount = min(array_length(hand), maxCardsOnDeskNumber)
    var spread = min(geometry.drawCardW * 0.8, (geometry.deskW - geometry.drawCardW) / max(1, handCount))
    var middleIndex  = (handCount - 1) / 2
    var offsetFromMiddle  = selectedCard - middleIndex
    var arcLift = 2 * guiScaleFactor
    return {
        x: geometry.handCenterX + offsetFromMiddle * spread,
        y: geometry.handCenterY - abs(offsetFromMiddle) * arcLift - 6 * guiScaleFactor,
        angle: 0,
        w: geometry.drawCardW,
        h: geometry.drawCardH
    }
}

// Общий запуск анимации карты: from — стартовый transform {x, y, angle, w, h}
function spawnCardAnim(card, from, cfg, onDone) {
    cfg.particles.color = categoryColor(cardCategoryOf(card))
    cfg.particles.draw  = drawStarSparkle

    changeBattleState(BattleStates.CardAnimating)
    animatingCard = card

    var anim = new CardPlayAnim(
        card,
        from.x,
        from.y,
        from.angle,
        from.w,
        from.h,
        onDone,
        cfg
    )
    array_push(activeCardAnims, anim)
    return anim
}

// Запускает анимацию выбранной карты перед тем как начать разыгрывание
function playCardAnimated(card, caster, targets, cfg) {
    playCardPlaySound() // звук начала розыгрыша карты
    if (cfg == undefined) { cfg = defaultCardAnimConfig() }

    var anim = spawnCardAnim(card, selectedCardTransform(), cfg, function(anim) {
        playCard(anim.card, anim.caster, anim.targets)
    })
    anim.caster = caster
    anim.targets = targets
}

function handSlotTransform(i, handCount) {
    var geometry = cardDeskGeometry()
    var guiScaleFactor = display_get_gui_width() / guiBaseWidth()
    var spread = min(geometry.drawCardW * 0.8, (geometry.deskW - geometry.drawCardW) / max(1, handCount))
    var middleIndex = (handCount - 1) / 2
    var offsetFromMiddle = i - middleIndex
    var arcLift = 2 * guiScaleFactor
    var arcTilt = 5
    return {
        x: geometry.handCenterX + offsetFromMiddle * spread,
        y: geometry.handCenterY - abs(offsetFromMiddle) * arcLift,
        angle: -offsetFromMiddle * arcTilt,
        w: geometry.drawCardW,
        h: geometry.drawCardH
    }
}

function deckPileTopCenter(deckCount) {
    var screenWidth = display_get_gui_width()
    var screenHeight = display_get_gui_height()
    var guiScaleFactor = guiScale()
    var cardDeskHeight = screenHeight / 3
    var deckH = cardDeskHeight * 0.7
    var deckScale = deckH / sprite_get_height(CardBack)
    var deckW = sprite_get_width(CardBack) * deckScale
    var deckMargin = 8 * guiScaleFactor
    var deckStep = 2 * guiScaleFactor
    var deckX = screenWidth - deckMargin - deckW
    var deckBottomY = screenHeight - deckMargin
    var i = max(0, deckCount - 1)
    var topCardX = deckX - i * deckStep
    var topCardY = deckBottomY - deckH - i * deckStep
    return { x: topCardX + deckW * 0.5, y: topCardY + deckH * 0.5 }
}

// Можно ли добрать карту в начале хода (герой, не в стане, есть колода, рука не полна)
function canDrawCardForTurn(character) {
    if (character.isEnemy || character.isPuppet) { return false }
    if (checkIfHasEffectType(character, EffectTypes.Stun)) { return false }
    if (array_length(character.getShuffeledDeck()) == 0) { return false }
    if (array_length(character.getCardsInHand()) >= maxCardsOnDeskNumber) { return false }
    return true
}

// Добор карты из колоды: летит из стопки в руку
function beginDrawCardAnim(character) {
    var pile = character.getShuffeledDeck()
    var hand = character.getCardsInHand()
    var pileCountBefore = array_length(pile)
    var card = array_shift(pile)

    var newHandSize = array_length(hand) + 1
    var slot = handSlotTransform(newHandSize - 1, newHandSize)
    var pileCenter = deckPileTopCenter(pileCountBefore)

    var cfg = drawCardAnimConfig()
    cfg.toX = slot.x
    cfg.toY = slot.y
    cfg.toAngle = slot.angle

    var from = { x: pileCenter.x, y: pileCenter.y, angle: 0, w: slot.w, h: slot.h }
    spawnCardAnim(card, from, cfg, function(anim) {
        array_push(selectedCharacter.getCardsInHand(), anim.card)
        beginTurnFor(selectedCharacter)
    })
}

// Обновление всех активных анимаций (вызывать каждый шаг)
function updateCardAnims() {
    for (var i = array_length(activeCardAnims) - 1; i >= 0; i--) {
        activeCardAnims[i].update()
        if (activeCardAnims[i].finished()) { // долетела и звёзды погасли
            array_delete(activeCardAnims, i, 1)
            animatingCard = noone
        }
    }
}
