
if (triggered) exit
triggered = true
global.battleRewardPool = rewardFactory()
global.returnRoom = room
global.returnX = other.x
global.returnY = other.y


other.can_move = false

with (oTransition) {
    target_room = BattleRoom
    state = "fade_out"
}