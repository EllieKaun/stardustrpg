didClick = false
consumedEscape = false
var guiX = device_mouse_x_to_gui(0)
var guiY = device_mouse_y_to_gui(0)
var threshold = display_get_gui_width() / 100

switch (state) {
	case DragState.Idle: 
        if (mouse_check_button_pressed(mb_left)) {
            for(var index = 0; index < array_length(sources); index++) {
                var sourceContext = sources[index].hitTest(guiX, guiY)
                if(sourceContext == undefined) { continue }
                    
                payload = sourceContext
            }
            pressX = guiX
            pressY = guiY
            state = DragState.Pressed
        }
        break
    case DragState.Pressed: 
        show_debug_message("------- DRAGMANAGER state PRESSED")
        if (!mouse_check_button(mb_left)) {
            didClick = true
            payload = undefined
            state = DragState.Idle
        } else if (payload != undefined && point_distance(pressX, pressY, guiX, guiY) > threshold) {
            payload.source.onDragStart(payload)
            draggedItemWidth = payload.data.rect.sw
            draggedItemHeight = payload.data.rect.sh
            // стартуем из ЦЕНТРА слота (drawCardFace рисует от центра, а не от угла)
            draggedItemX = payload.data.rect.sx + draggedItemWidth * 0.5
            draggedItemY = payload.data.rect.sy + draggedItemHeight * 0.5
            // смещение точки захвата относительно центра — чтобы карта не прыгала серединой под курсор
            grabOffsetX = pressX - draggedItemX
            grabOffsetY = pressY - draggedItemY
            sourceX = draggedItemX
            sourceY = draggedItemY
            state = DragState.Dragging
        }
        break
    case DragState.Dragging: 
        show_debug_message("------- DRAGMANAGER state DRAGGING")
        draggedItemX = lerp(draggedItemX, guiX - grabOffsetX, 0.5)
        draggedItemY = lerp(draggedItemY, guiY - grabOffsetY, 0.5)
        hoverTarget = undefined
        hoverContext = undefined
        isHoverTarget = false
        for(var index = 0; index < array_length(targets); index++) {
            var targetContext = targets[index].hitTest(guiX, guiY)
            if (targetContext == undefined) { continue }

            hoverTarget = targets[index]
            hoverContext = targetContext
            isHoverTarget = hoverTarget.accepts(payload, hoverContext)
        }
        if (mouse_check_button_pressed(mb_right) || keyboard_check_pressed(vk_escape)) {
            cancel()
            state = DragState.Returning 
        }
        
        if (mouse_check_button_released(mb_left)) {
            if (hoverTarget != undefined && isHoverTarget) {
                var hovered = hoverTarget.onDrop(payload, hoverContext)
                payload.source.onDragEnd(payload, hovered)
                if (hovered) {
                    payload = undefined
                    state = DragState.Idle
                } else {
                    state = DragState.Returning
                }
            } else {
                cancel()
                state = DragState.Returning 
            }
        }
        break
    case DragState.Returning:     
        show_debug_message("------- DRAGMANAGER state RETURNING")
        draggedItemX = lerp(draggedItemX, sourceX, 0.3)
        draggedItemY = lerp(draggedItemY, sourceY, 0.3)
        if (point_distance(draggedItemX, draggedItemY, sourceX, sourceY) < 1) {
            payload = undefined
            state = DragState.Idle
        }
    break
}