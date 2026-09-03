depth = -bbox_bottom

if (global.safarJoined) exit
if (global.gamePaused || global.uiModal) exit

var leader = oGameController.selected_character
if (instance_exists(leader) && place_meeting(x, y, leader)) {
    say([
        dialogLine("Safar", sprSafar, "left", "Hey! dont like you"),
        dialogLine("Safar", sprSafar, "left", "ill take your money tho")
    ], function() {
        global.safarJoined = true
    })
}
