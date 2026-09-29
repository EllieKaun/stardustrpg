wasClick = false 
consumedEscape = false 
var guiX = device_mouse_x_to_gui(0)
var guiY = device_mouse_y_to_gui(0)
var threshold = display_get_gui_width() * 8

switch (state) {
	case DragState.Idle: 
        if (mouse_check_button_pressed(mb_left)) {
            for(var index = 0; index < array_length(sources); index++) {
                var sourceContext = sources[i].hitTest(guiX, guiY)
                if(sourceContext == undefined) { continue }
                    
                payload = sourceContext
            }
            pressX = guiX
            pressY = guiY
            state = DragState.Pressed
        }
        break
    case DragState.Pressed: 
        if (!mouse_check_button(mb_left)) {
            wasClick = true
            payload = undefined
            state = DragState.Idle
        } else if (payload != undefined && point_distance(pressX, pressY, guiX, guiY) > threshold) {
            payload.source.onDragStart(payload)
            draggedItemX = payload.data.rect.x 
            draggedItemY = payload.data.rect.y
            draggedItemHeight = payload.data.rect.height
            draggedItemWidth = payload.data.rect.width
            sourceX = draggedItemX
            sourceY = draggedItemY
            state = DragState.Dragging
        }
        break
    case DragState.Dragging: 
        draggedItemX = lerp(draggedItemX, guiX, 0.5)
        for(var index = 0; index < array_length(targets); index++) {
            var targetContext = targets[index].hitTest(guiX, guiY)
            if (targetContext == undefined) { continue }
                
            hoverTarget = targetContext
            hoverContext = targetContext.ctx
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
        draggedItemX = lerp(draggedItemX, sourceX, 0.3)
        draggedItemY = lerp(draggedItemY, sourceY, 0.3)
        if (point_distance(draggedItemX, draggedItemY, sourceX, sourceY) < 1) {
            payload = undefined
            state = DragState.Idle
        }
    break
}