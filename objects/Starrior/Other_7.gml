var spec = starriorAnimSpec(actionState)
if (spec == undefined) exit

if (spec.firesCallback && !is_undefined(actionCallback)) {
    actionCallback()
    actionCallback = undefined
}

if (spec.next != undefined) {
    changeActionState(spec.next, undefined)
}
