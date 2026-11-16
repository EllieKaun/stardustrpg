#macro INTERACT_DEFAULT_DIST 24
#macro INTERACT_DEFAULT_ICON_OFFSET 4
#macro INTERACT_DEFAULT_CLICK_HEIGHT 24

function interactKeyCode() {
    if (!variable_global_exists("interactKeyCode")) { global.interactKeyCode = ord("E") }
    return global.interactKeyCode
}

function interactKeyLabel() {
    if (!variable_global_exists("interactKeyLabel")) { global.interactKeyLabel = "E" }
    return global.interactKeyLabel
}

function setInteractKey(code, label = undefined) {
    global.interactKeyCode = code
    global.interactKeyLabel = label ?? chr(code)
}

function interactKeyPressed() {
    return keyboard_check_pressed(interactKeyCode())
}

function Interactable(_owner, _config = {}) constructor {
    owner = _owner
    onInteract = _config[$ "onInteract"] ?? function() {}
    iconSprite = _config[$ "icon"] ?? ActionButtonBadge
    labelSource = _config[$ "label"] ?? function() { return interactKeyLabel() }
    labelFont = _config[$ "labelFont"] ?? fnUI_7
    interactDist = _config[$ "interactDist"] ?? INTERACT_DEFAULT_DIST
    iconOffset = _config[$ "iconOffset"] ?? INTERACT_DEFAULT_ICON_OFFSET
    clickHeight = _config[$ "clickHeight"] ?? INTERACT_DEFAULT_CLICK_HEIGHT
    isEnabled = _config[$ "enabled"] ?? function() { return true }
    canInteract = false
    wasModal = false

    static resolveIcon = function() {
        var spr = is_method(iconSprite) ? iconSprite() : iconSprite
        return (spr != noone && sprite_exists(spr)) ? spr : noone
    }

    static resolveLabel = function() {
        return is_method(labelSource) ? labelSource() : string(labelSource)
    }

    static blocked = function() {
        if (global.gamePaused || global.uiModal) { return true }
        if (variable_global_exists("cutsceneActive") && global.cutsceneActive) { return true }
        if (variable_global_exists("introWalk") && global.introWalk) { return true }
        return false
    }

    static inRange = function() {
        var leader = oGameController.selected_character
        if (!instance_exists(leader)) { return false }
        return point_distance(owner.x, owner.y, leader.x, leader.y) <= interactDist
    }

    static clickedOnOwner = function() {
        return mouse_check_button_pressed(mb_left)
            && point_in_rectangle(mouse_x, mouse_y, owner.bbox_left, owner.bbox_top - clickHeight, owner.bbox_right, owner.bbox_bottom)
    }

    static step = function() {
        var modalLastFrame = wasModal
        wasModal = global.uiModal
        canInteract = false
        if (blocked() || modalLastFrame) { return false }
        if (!isEnabled()) { return false }
        if (!inRange()) { return false }
        canInteract = true
        if (interactKeyPressed() || uiConfirmPressed() || clickedOnOwner()) {
            onInteract()
            return true
        }
        return false
    }

    static draw = function() {
        if (!canInteract) { return }
        var spr = resolveIcon()
        if (spr == noone) { return }
        var bob = sin(current_time / 300) * 1.5
        var bx = owner.x
        var by = owner.bbox_top - iconOffset + bob
        draw_sprite(spr, 0, bx, by)

        var txt = resolveLabel()
        if (txt == "") { return }
        var prevFont = draw_get_font()
        var prevHalign = draw_get_halign()
        var prevValign = draw_get_valign()
        var prevColor = draw_get_color()
        draw_set_font(labelFont)
        draw_set_halign(fa_center)
        draw_set_valign(fa_middle)
        draw_set_color(c_white)
        draw_text(bx, by, txt)
        draw_set_halign(prevHalign)
        draw_set_valign(prevValign)
        draw_set_color(prevColor)
        draw_set_font(prevFont)
    }
}
