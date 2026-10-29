var modalWindow = topWindow()
if (modalWindow == undefined) { exit }
modalWindow.step(readInput())
removeClosed()