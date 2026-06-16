
if (triggered) exit
triggered = true

global.battleSection = spawnSection
global.battleRewardPool = rewardFactory()
global.battleEncounter  = encounterFactory;
global.returnRoom = room
global.returnX = other.x
global.returnY = other.y


other.can_move = false

with (oTransition) {
    target_room = BattleRoom
    state = "fade_out"
}