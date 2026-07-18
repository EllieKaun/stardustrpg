// ============================================================
//  Анимация розыгрыша карты — конфигурируемая
//
//  Поведение задаётся стратегиями (функциями) в конфиге:
//  путь (path), сглаживание (ease), исчезновение (fade),
//  частицы (particles)
//
//  Пример кастомизации:
//    var c = defaultCardAnimConfig()
//    c.path = pathLine // лететь по прямой
//    c.fade = fadeShrink // не гаснуть, а ужиматься
//    c.dur  = 60 // помедленнее
//    playCardAnimated(card, caster, targets, c)
//
// ============================================================

// ------------------------------------------------------------
//  Стратегии ПУТИ: (from, to, p, opts) -> {x, y}.  p в [0..1]
// ------------------------------------------------------------

function pathArc(from, to, p, opts) { // дуга вверх
    var cx = (from.x + to.x) * 0.5
    var cy = min(from.y, to.y) - opts.arcHeight
    var ax = lerp(from.x, cx, p), ay = lerp(from.y, cy, p)
    var bx = lerp(cx, to.x, p), by = lerp(cy, to.y, p)
    return { x: lerp(ax, bx, p), y: lerp(ay, by, p) }
}

function pathLine(from, to, p, opts) { // по прямой
    return { x: lerp(from.x, to.x, p), y: lerp(from.y, to.y, p) }
}

// ------------------------------------------------------------
//  Стратегии СГЛАЖИВАНИЯ: (p) -> p'
// ------------------------------------------------------------
function easeOutQuad(p) { return 1 - power(1 - p, 2) }
function easeLinear(p) { return p }
function easeInOutQuad(p) { return (p < 0.5) ? 2 * p * p : 1 - power(-2 * p + 2, 2) * 0.5 }

// ------------------------------------------------------------
//  Стратегии ИСЧЕЗНОВЕНИЯ: (p, anim) -> alpha. Могут менять и сам anim
// ------------------------------------------------------------
function fadeTail(p, anim) { return (p < 0.6) ? 1 : 1 - (p - 0.6) / 0.4; }  // текущее
function fadeNone(p, anim) { return 1; }  // не гаснет
function fadeInOut(p, anim) {
    if (p < 0.15) return p / 0.15;
    if (p > 0.85) return (1 - p) / 0.15;
    return 1;
}
function fadeShrink(p, anim) {                  // вместо гаснуть — ужиматься в точку
    anim.scale = lerp(anim.cfg.scaleFrom, 0.15, p);
    return 1;
}

// ------------------------------------------------------------
//  Конфиги по умолчанию 
// ------------------------------------------------------------
function defaultCardAnimConfig() {
    return {
        dur: 40,
        toX: undefined, // undefined - центр GUI
        toY: undefined,
        toAngle: 0,
        scaleFrom: 1.12,
        scaleTo:1.12, 
        path: pathArc,
        arcHeight: 120,
        ease: easeOutQuad,
        fade: fadeTail,
        particles: damageCardParticleConfig()
    }
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
        color: make_color_rgb(255, 236, 150), // тёплый золотой
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






// ------------------------------------------------------------
//  Анимация одной карты
// ------------------------------------------------------------
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

    static update = function() {
        if (!done) {
            var px = x, py = y // позиция до шага (для следа)
            t = min(t + 1, dur)
            var p = t / dur
            var e = cfg.ease(p) // сглаженное время

            var pt = cfg.path(fromPt, toPt, e, cfg) // позиция по стратегии пути
            x = pt.x
            y = pt.y
            angle = lerp(fromAngle, cfg.toAngle, e)
            scale = lerp(cfg.scaleFrom, cfg.scaleTo, e)
            alpha = cfg.fade(p, self) // исчезновение по стратегии

            // эмиттер частиц
            if (p < pcfg.spawnUntil) {
                repeat (pcfg.rate) {
                    var s = {
                        x: x + random_range(-cardW * pcfg.posSpread, cardW * pcfg.posSpread),
                        y: y + random_range(-cardH * pcfg.posSpread, cardH * pcfg.posSpread),
                        vx: (px - x) * pcfg.backBias + random_range(-pcfg.velJitter, pcfg.velJitter),
                        vy: (py - y) * pcfg.backBias + random_range(-pcfg.velJitter, pcfg.velJitter),
                        life: irandom_range(pcfg.lifeMin, pcfg.lifeMax),
                        maxlife: 1,
                        size: random_range(pcfg.sizeMin, pcfg.sizeMax),
                        rot: random(360),
                        rotSpeed: random_range(-pcfg.rotSpeed, pcfg.rotSpeed)
                    };
                    s.maxlife = s.life
                    array_push(particles, s)
                }
            }

            if (t >= dur) {
                done = true
                if (onDone != undefined && !effectFired) { 
                    effectFired = true
                    onDone() 
                }
            }
        }

        // частицы живут и после приземления карты
        for (var i = array_length(particles) - 1; i >= 0; i--) {
            var s = particles[i]
            s.x += s.vx; s.y += s.vy; s.vy += pcfg.gravity
            s.rot += s.rotSpeed
            s.life -= 1
            if (s.life <= 0) array_delete(particles, i, 1)
        }
    }

    static finished = function() {
        return done && array_length(particles) == 0
    }

    static draw = function() {
        // частицы — под картой
        for (var i = 0; i < array_length(particles); i++) {
            var s = particles[i];
            var k = s.life / s.maxlife;
            pcfg.draw(s.x, s.y, s.size * k, s.rot, k, pcfg.color)
        }
        // сама карта
        var sx = (cardW / sprite_get_width(card.cardBaseSpr))  * scale
        var sy = (cardH / sprite_get_height(card.cardBaseSpr)) * scale
        draw_sprite_ext(card.cardBaseSpr, 0, x, y, sx, sy, angle, c_white, alpha)
        draw_sprite_ext(card.cardIllustrationSpr, 0, x, y, sx, sy, angle, c_white, alpha)
        draw_sprite_ext(card.cardBorderSpr, 0, x, y, sx, sy, angle, c_white, alpha)
        draw_sprite_ext(card.cardTokenSpr, 0, x, y, sx, sy, angle, c_white, alpha)
    }
}

// Рисует 4-конечную звёздочку, outer — размер лучей.
function drawStarSparkle(cx, cy, outer, rot, alpha, col) {
    if (outer <= 0) return
    var inner = outer * 0.4
    draw_set_color(col)
    draw_set_alpha(alpha)
    draw_primitive_begin(pr_trianglefan)
    draw_vertex(cx, cy)
    for (var a = 0; a <= 360; a += 45) {
        var r = ((a mod 90) == 0) ? outer : inner  // 0/90/180/270 — лучи, между — впадины
        draw_vertex(cx + lengthdir_x(r, a + rot), cy + lengthdir_y(r, a + rot))
    }
    draw_primitive_end()
    draw_set_alpha(1)
    draw_set_color(c_white)
}

// Квадрат. outer — радиус до угла 
function drawRectSparkle(cx, cy, outer, rot, alpha, col) {
    if (outer <= 0) {
        return
    }
    draw_set_color(col)
    draw_set_alpha(alpha)
    draw_primitive_begin(pr_trianglefan)
    draw_vertex(cx, cy) // центр веера
    for (var a = 45; a <= 405; a += 90) { // 4 угла (+замыкание)
        draw_vertex(cx + lengthdir_x(outer, a + rot), cy + lengthdir_y(outer, a + rot))
    }
    draw_primitive_end()
    draw_set_alpha(1)
    draw_set_color(c_white)
}

// Равносторонний треугольник. outer — радиус от центра до вершины
function drawTriangleSparkle(cx, cy, outer, rot, alpha, col) {
    if (outer <= 0) return
    draw_set_color(col)
    draw_set_alpha(alpha)
    draw_primitive_begin(pr_trianglelist)
    for (var a = -90; a < 270; a += 120) { // 3 вершины через 120°
        draw_vertex(cx + lengthdir_x(outer, a + rot), cy + lengthdir_y(outer, a + rot))
    }
    draw_primitive_end()
    draw_set_alpha(1)
    draw_set_color(c_white)
}

// Круг. outer — радиус
function drawCircleSparkle(cx, cy, outer, rot, alpha, col) {
    if (outer <= 0) {
        return
    }
    draw_set_color(col)
    draw_set_alpha(alpha)
    draw_primitive_begin(pr_trianglefan)
    draw_vertex(cx, cy) // центр
    for (var a = 0; a <= 360; a += 30) { // 12 сегментов
        draw_vertex(cx + lengthdir_x(outer, a), cy + lengthdir_y(outer, a))
    }
    draw_primitive_end()
}


// ------------------------------------------------------------
//  Геометрия стола карт — та же математика, что в Draw_64, но доступная
//  из Step/скриптов
// ------------------------------------------------------------
function cardDeskGeometry() {
    var screenWidth = display_get_gui_width()
    var screenHeight = display_get_gui_height()

    var deskH = screenHeight / 3
    var cardSpacing = 6;
    var cardH = deskH - (5 + 3)
    var cardW = cardH * 2 / 3
    var deskW = cardW * maxCardsOnDeskNumber + cardSpacing * (maxCardsOnDeskNumber + 1)
    var startX = (screenWidth - deskW) / 2
    var startY = screenHeight - deskH

    var vPad = 8
    var drawCardH = deskH - vPad * 2
    var drawCardW = drawCardH * 2 / 3

    return {
        deskW: deskW, deskH: deskH,
        drawCardW: drawCardW, drawCardH: drawCardH,
        handCenterX: startX + deskW / 2,
        handCenterY: startY + deskH / 2
    }
}

function selectedCardTransform() {
    var g = cardDeskGeometry()
    var hand = selectedCharacter.getCardsInHand()
    var n = min(array_length(hand), maxCardsOnDeskNumber)
    var spread = min(g.drawCardW * 0.8, (g.deskW - g.drawCardW) / max(1, n))
    var mid  = (n - 1) / 2
    var off  = selectedCard - mid
    var arcLift = 2
    return {
        x: g.handCenterX + off * spread,
        y: g.handCenterY - abs(off) * arcLift - 6,
        angle: 0,
        w: g.drawCardW,
        h: g.drawCardH
    }
}

// Запускает анимацию выбранной карты перед тем как начать фактическое разыгрывание
function playCardAnimated(card, caster, targets, cfg) {
    if (cfg == undefined) cfg = defaultCardAnimConfig()
    var transform = selectedCardTransform()

    animPendingCard = card
    animPendingCaster = caster
    animPendingTargets = targets
    animatingCard = card
    battleState = BattleStates.CardAnimating

    var anim = new CardPlayAnim(
        card, 
        transform.x, 
        transform.y, 
        transform.angle, 
        transform.w, 
        transform.h, 
        function() {
            playCard(animPendingCard, animPendingCaster, animPendingTargets)
        }, 
        cfg
    )
    array_push(activeCardAnims, anim)
}

// Обновление/чистка всех активных анимаций (вызывать каждый шаг)
function updateCardAnims() {
    for (var i = array_length(activeCardAnims) - 1; i >= 0; i--) {
        activeCardAnims[i].update()
        if (activeCardAnims[i].finished()) { // долетела и звёзды погасли
            array_delete(activeCardAnims, i, 1)
            animatingCard = noone
        }
    }
}
