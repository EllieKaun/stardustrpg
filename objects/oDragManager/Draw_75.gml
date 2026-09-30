if (payload == undefined) exit 
    
if (state != DragState.Dragging && state != DragState.Returning) { exit }
    
drawCardFace(payload.card, 
draggedItemX,
draggedItemY, 
draggedItemWidth, 
draggedItemHeight, 
0, 
1.08, 
1, 
false)

