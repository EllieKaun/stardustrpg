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
	case StarriorStates.Spell:
        if (!is_undefined(actionCallback)) {
            actionCallback()
            actionCallback = undefined
        }
        changeActionState(StarriorStates.Idle, undefined)
    break
	case StarriorStates.KnockOut:
    break
	case StarriorStates.Spawn:
        changeActionState(StarriorStates.Idle, undefined)
    break
	case StarriorStates.Dance:
    break
}