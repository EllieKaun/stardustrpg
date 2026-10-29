var modalLastFrame = wasModal
wasModal = global.uiModal
canInteract = false

if (global.gamePaused || global.uiModal || modalLastFrame) { exit }
if (variable_global_exists("cutsceneActive") && global.cutsceneActive) { exit }

var leader = oGameController.selected_character
if (!instance_exists(leader)) { exit }
if (point_distance(x, y, leader.x, leader.y) > CAMPFIRE_INTERACT_DIST) { exit }
canInteract = true

var clickedCampfire = mouse_check_button_pressed(mb_left)
    && point_in_rectangle(mouse_x, mouse_y, bbox_left, bbox_top - CAMPFIRE_ICON_CLICK_HEIGHT, bbox_right, bbox_bottom)
if (!uiConfirmPressed() && !clickedCampfire) { exit }

var speaker = activeSpeaker()
say([
    dialogChoice(speaker.id, speaker.portrait, loc("campfire.ask"), [
        { text: isNight() ? loc("campfire.waitMorning") : loc("campfire.waitNight"), onSelect: function() { skipTimeOfDay() } },
        { text: loc("campfire.leave"), onSelect: undefined }
    ])
])
