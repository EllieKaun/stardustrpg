/*
 * Баффы физ урона
 * Weakness, Buff (Ph, Any), CreatedWeakness 
 * 
 * 
 * Баффы магического урона
 * Weakness, Buff (Mag, Any), CreatedWeakness
 * 
 * 
 * Баффы физической защиты
 * Buff (Ph, Any)
 * 
 * Баффы магической защиты
 * Buff (Mag, Any)
 * 
 * Дебаффы физ урона
 * Debuff (Ph)
 * 
 * Дебаффы магического урона
 * Debuff (Mag)
 * 
 * Дебаффы физической защиты
 * Debuff (Ph)
 * 
 * Дебаффы магической защиты
 * Debuff (Mag)
 * 
 * 
 * Формула физического урона :
 * 
 * силаКарты*силаПерсонажа 
 * + (баффФизУронаИлиЛюбогоУрона 
 *      + 0.1*естьЛиСлабость 
 *      + 0.1*естьЛиСозданнаяСлабость 
 *      - дебаффФизУрона 
 *      - слабость)%
 * - (физическаяЗащита 
 *      + баффФизическойЗащиты
 *      - дебаффФизическойЗащиты)
 * 
 * Формула магического урона :
 * 
 * силаКарты*интеллектПерсонажа
 * + (баффМагУронаИлиЛюбогоУрона
 *      + 0.1*естьЛиСлабость
 *      + 0.1*естьЛиСозданнаяСлабость
 *      - дебаффМагУрона
 *      - слабость)%
 * - (МагическаяЗащита
 *      + баффМагическойЗащиты
 *      - дебаффФизическойЗащиты)%
 *
 */


/* ============================================================================
   ENEMY AI — UTILITY-BASED DECISION MAKING (design notes / reading)
   ============================================================================

   Why change the current AI
   -------------------------
   Today the enemy turn (objects/Battle/Alarm_0.gml) and the puppet turn
   (sprPuppetManagement/runPuppetTurn) do the SAME thing and both are weak:
     - take the FIRST card of each category (heal / buff / attack),
     - follow a fixed priority: heal-wounded -> buff-self-50% -> attack -> random.
   Consequences:
     - never picks the *best* attack (ignores damage, AoE-vs-single),
     - never spots LETHAL (a hero it could KO this turn) or FOCUS-FIRE,
     - heals "most wounded" without caring about overheal / resurrect,
     - logic is duplicated and identical for a trash mob and a boss.

   The idea: "score every legal move, then pick one"
   -------------------------------------------------
   Instead of a longer priority list, enumerate every legal move, give each a
   numeric SCORE (utility), and choose based on a policy. The knowledge of
   "how good is this effect right now" lives ON THE EFFECT REGISTRY, next to
   onInstant/onEndOfTurn — so a new effect brings its own AI value, exactly like
   it already brings its own behaviour. This is called a UTILITY AI.

   Per-turn pipeline
   -----------------
     chooseMove(actor, allies, foes):
         // 0) optional hard rules first (bosses / phases) — see below
         var forced = firstMatchingRule(actor.brain.rules, ctx)
         if (forced != undefined) return forced

         var moves = enumerateMoves(actor, allies, foes)   // (1)
         if (array_length(moves) == 0) return undefined      // -> skipTurn()

         var scored = []
         for (var i = 0; i < array_length(moves); i++)
             array_push(scored, { move: moves[i],
                                  score: scoreMove(moves[i], ctx) })  // (2)(3)

         return selectMove(scored, actor.brain)               // (4)

   (1) enumerateMoves — every legal {card, target}
   -----------------------------------------------
     - single-target card  -> one move per ALIVE valid target
     - AoE / all-allies     -> one move (the whole group)
     - self                 -> one move (self)
     Move space is tiny (cards in hand * targets, ~<= 20), so brute force is fine.
     Reuse checkIfCanPlayCard() to keep only playable cards.

         function enumerateMoves(actor, allies, foes) {
             var moves = []
             var hand = actor.getCardsInHand()
             for (var i = 0; i < array_length(hand); i++) {
                 var card = hand[i]
                 if (!checkIfCanPlayCard(actor, card)) continue
                 switch (card.target) {
                     case TargetTypes.SingleEnemyTarget:
                         for (var t = 0; t < array_length(foes); t++)
                             array_push(moves, { card: card, target: foes[t] })
                         break
                     case TargetTypes.SingleAllyTarget:
                         for (var t = 0; t < array_length(allies); t++)
                             array_push(moves, { card: card, target: allies[t] })
                         break
                     case TargetTypes.AllEnemies: array_push(moves, { card: card, target: foes });  break
                     case TargetTypes.AllAllies:  array_push(moves, { card: card, target: allies }); break
                     case TargetTypes.Self:       array_push(moves, { card: card, target: actor }); break
                 }
             }
             return moves
         }

   (2) per-effect aiValue — add ONE optional hook to the effect registry
   ---------------------------------------------------------------------
     ctx = { actor, target, allies, foes, weights }   // weights = personality (below)
     Each effect returns "how many points is applying me to THIS target worth".

         // Damage: value = damage that isn't wasted; big bonus if it KOs.
         effectsRepository[$ "Damage"].aiValue = function(effect, ctx) {
             var dmg = estimateDamage(effect, ctx.actor, ctx.target)   // reuse mitigateDamage()
             var applied = min(dmg, ctx.target.hp)          // overkill earns nothing
             var lethal  = (dmg >= ctx.target.hp) ? ctx.weights.lethalBonus : 0
             var lowHpFocus = (1 - ctx.target.hp / ctx.target.maxHp) * ctx.weights.focusFire
             return applied * ctx.weights.aggression + lethal + lowHpFocus
         }

         // Heal: only the part that actually restores HP counts (no overheal).
         effectsRepository[$ "Heal"].aiValue = function(effect, ctx) {
             var need = ctx.target.maxHp - ctx.target.hp     // 0 if full -> won't waste a heal
             return min(effect.value, need) * ctx.weights.support
         }

         // Buff: worthless if the target already has this modifier.
         effectsRepository[$ "Buff"].aiValue = function(effect, ctx) {
             if (checkIfHasBuff(ctx.target, EffectTypes.Buff, effect.buffType) != undefined) return 0
             return effect.value * ctx.weights.support
         }

         // ManaGain: valued only when the target is actually short on mana. etc.

     Effects with NO aiValue hook default to a small constant (say 1), so a card
     is never scored at exactly zero just because one effect is unmodelled.

   (3) scoreMove — sum the effects, subtract cost
   ----------------------------------------------
         function scoreMove(move, ctx) {
             ctx.target = move.target
             var total = 0
             var effects = move.card.effects
             for (var i = 0; i < array_length(effects); i++) {
                 var handler = effectHandler(effects[i])
                 total += effectHasHook(handler, "aiValue")
                        ? handler.aiValue(effects[i], ctx)
                        : AI_DEFAULT_EFFECT_VALUE
             }
             // discourage paying a lot for a little (mana/hp cost)
             total -= move.card.costValue() * ctx.weights.thrift
             return total
         }

     For an AoE move, sum aiValue over each member of the group (loop targets),
     which naturally makes AoE better when several heroes are up.

   (4) selectMove — the difficulty / variety dial
   ----------------------------------------------
     - argmax           : always the top score. Strongest, but predictable/robotic.
     - weighted-random  : random among the few best. Simple, varied, coarse control.
     - softmax(temp)    : probability of a move ~ exp(score / temperature).
                          temperature -> 0  == argmax (smart/hard),
                          temperature large == almost random (dumb/easy).
                          ONE number per enemy tunes both "feel" and difficulty.

         // softmax / Boltzmann selection
         function selectMove(scored, brain) {
             if (brain.policy == "argmax") return argmaxByScore(scored).move
             var temp = max(0.0001, brain.temperature)
             var sum = 0, weights = []
             for (var i = 0; i < array_length(scored); i++) {
                 var w = exp(scored[i].score / temp)
                 weights[i] = w; sum += w
             }
             var roll = random(sum)
             for (var i = 0; i < array_length(scored); i++) {
                 roll -= weights[i]
                 if (roll <= 0) return scored[i].move
             }
             return scored[array_length(scored)-1].move
         }

     Note: exp() can overflow with big scores — in practice subtract the max score
     from every score before exp() (a standard "softmax stability" trick).

   ----------------------------------------------------------------------------
   PERSONALITIES — behaviour as DATA (a set of weights)
   ----------------------------------------------------------------------------
   A "personality" is just the WEIGHTS struct fed into ctx. Same engine, different
   numbers -> different behaviour. Attach one to each enemy factory / encounter:

       enemy.brain = {
           weights: { aggression: 1.0, support: 0.4, lethalBonus: 40,
                      focusFire: 8, thrift: 0.5 },
           policy: "softmax",
           temperature: 0.6,
           rules: []          // optional hard overrides (bosses), see below
       }

   How to think about each weight (what raising it does):
     aggression  : how much raw (non-wasted) damage is worth. Higher = brawler.
     support     : value of healing/buffing allies. Higher = medic/enchanter.
     lethalBonus : flat bump for a move that KOs a hero. Higher = ruthless closer,
                   will drop a support card to secure a kill.
     focusFire   : reward for hitting already-wounded targets. Higher = finisher,
                   concentrates damage instead of spreading it.
     thrift      : penalty per unit of card cost. Higher = conservative, hoards
                   expensive cards; 0 = spends freely.
     temperature : NOT a weight — it is the randomness/difficulty knob (policy).

   Example presets (starting points, then tune by watching fights):
     ---------------------------------------------------------------
     name        aggression support lethalBonus focusFire thrift temp
     brute          1.4       0.1       50         10       0.2    0.4
     skirmisher     1.0       0.2       35         14       0.4    0.5
     healer         0.4       1.3       20          4       0.6    0.6
     controller     0.7       0.6       25          6       0.8    0.7   (values status/debuff cards)
     boss           1.1       0.7       60         12       0.3    0.35  (+ hard rules)

   How to CONSIDER / tune them (practical method):
     1. Keep weights on comparable scales. If typical damage is ~10-30, a
        lethalBonus of 40-60 means "a kill is worth ~2 good hits" — reason in
        those relative terms, not absolute.
     2. Change ONE weight at a time and watch a few fights; utility systems are
        sensitive and interactions are easy to misjudge.
     3. Start every enemy from a preset, then nudge. Presets are 80% of the work.
     4. Use temperature for difficulty tiers (easy=high temp, elite=low temp)
        WITHOUT touching the weights — same personality, sharper play.
     5. If a behaviour is impossible to express with weights (a scripted phase),
        it belongs in a hard rule, not in ever-more weights.

   Hard rules (scripted / boss phases) — evaluated BEFORE scoring
   --------------------------------------------------------------
   Each rule: { when: function(ctx){ return bool }, move: function(ctx){ return {card,target} } }.
   First rule whose `when` is true forces its move; otherwise fall through to the
   scored default. Example: "below 30% HP, always summon a puppet".

       rules: [
         { when: function(c){ return c.actor.hp < c.actor.maxHp * 0.3 },
           move: function(c){ return { card: findCard(c.actor, "summon"), target: c.actor } } }
       ]

   Migration note
   --------------
   chooseMove(actor) replaces BOTH the body of Battle/Alarm_0.gml and
   sprPuppetManagement/runPuppetTurn (delete the duplication). enemyResolveTarget
   is subsumed by enumerateMoves. Start with one shared default brain, verify it
   plays well, then add presets and boss rules.

   ----------------------------------------------------------------------------
   SOURCES TO READ  (utility AI + game decision making)
   ----------------------------------------------------------------------------
   Utility theory (the approach above):
     * Dave Mark — "Behavioral Mathematics for Game AI" (book). The canonical
       reference for scoring/utility-based decisions and response curves.
     * Dave Mark & Kevin Dill — GDC talks (free on GDC Vault / YouTube):
         - "Improving AI Decision Modeling Through Utility Theory" (GDC 2010)
         - "Embracing the Dark Art of Mathematical Modeling in AI" (GDC 2012)
       These introduce the IAUS (Infinite Axis Utility System) — a production
       pattern for exactly this "score every option" idea.
     * Game AI Pro (books, ALL chapters free at gameaipro.com):
         - "An Introduction to Utility Theory" (Dave Mark)
         - chapters on response/utility curves and reasoning.

   General decision-making (see where utility fits vs the alternatives):
     * Ian Millington — "AI for Games" (3rd ed.). Decision Making chapters:
       decision trees, state machines, behaviour trees, utility, GOAP.
     * Mat Buckland — "Programming Game AI by Example". Practical, code-first.

   Randomised selection / difficulty (the softmax/temperature knob):
     * Sutton & Barto — "Reinforcement Learning: An Introduction" (free PDF).
       See Boltzmann/softmax action selection & the temperature parameter.

   Advanced, for turn-based / card games (if you outgrow utility):
     * Minimax / Expectimax for adversarial turn-based decisions.
     * Monte Carlo Tree Search (MCTS) — used by strong bots for Hearthstone-like
       games. Start with the "MCTS survey" (Browne et al., 2012) and Game AI Pro
       MCTS chapters. Heavier than needed here, but good to know the ceiling.
*/