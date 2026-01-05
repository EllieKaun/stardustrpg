switch (actionState) {
	case StarriorStates.Attack:
        if (!is_undefined(actionCallback)) {
            actionCallback();
            actionCallback = undefined;
        }
        changeActionState(StarriorStates.Idle, undefined)
    break      
}