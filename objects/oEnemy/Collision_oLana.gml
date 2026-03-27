
if (triggered) exit;
triggered = true;



global.returnRoom = room;
global.returnX = other.x;
global.returnY = other.y;


other.can_move = false;

//room_goto(BattleRoom);

with (oTransition) {
    target_room = BattleRoom;
    state = "fade_out";
}


if (!position_meeting(x, y, oLana)) {
    if (point_distance(x, y, oLana.x, oLana.y) > oSpawnerManager.spawnDistance) {
        instance_destroy();
    }
}