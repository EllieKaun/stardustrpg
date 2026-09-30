state = DragState.Idle
sources = []
targets = []
payload = undefined
pressX = 0
pressY = 0
image_speed = 1
draggedItemX = 0
draggedItemY = 0
draggedItemWidth = 0
draggedItemHeight = 0
grabOffsetX = 0
grabOffsetY = 0

sourceX = 0
sourceY = 0 
hoverTarget = undefined
hoverContext = undefined
isHoverTarget = false
didClick = false 
isDraggingInterrupted = false 

register = function(item, list) {
    array_push(list, item)
}

unregisterAll = function () {
    array_delete(sources, 0, array_length(sources))
    array_delete(targets, 0, array_length(targets))
}

cancel = function () {
    if (state == DragState.Dragging) {
        state = DragState.Returning
        payload.source.onDragEnd(payload, false)
    }
}

isBusy = function () {
    return state != DragState.Idle
}