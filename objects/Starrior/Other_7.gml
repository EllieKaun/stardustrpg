switch (actionState) {
	case StarriorStates.Attack:
        if (!is_undefined(actionCallback)) {
            actionCallback()
            actionCallback = undefined
        }
        changeActionState(StarriorStates.Idle, undefined)
    break     
	case StarriorStates.Cast:
        if (!is_undefined(actionCallback)) {
            actionCallback()
            actionCallback = undefined
        }
        changeActionState(StarriorStates.Idle, undefined)
    break       
	case StarriorStates.KnockOut:
        image_speed = 0
        image_index = image_number - 1
    break       
}