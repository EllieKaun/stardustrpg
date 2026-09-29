state = DragState.Idle
sources = []
targets = []
payload = undefined
pressX = 0
pressY = 0

draggedItemX = 0
draggedItemY = 0
draggedItemWidth = 0
draggedItemHeight = 0

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

unregisterAll = function (list) {
    array_delete(list, 0, array_length(list))
}

cancel = function () {
    if (state == DragState.Dragging) {
        state = DragState.Returning
        source.onDragEnd(payload, false)
    }
}

isBusy = function () {
    return state != DragState.Idle
}