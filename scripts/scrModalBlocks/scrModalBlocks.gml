function modalBlockLength(size, total, cross, fillSize) {
    if (is_string(size)) {
        return (size == "square") ? cross : fillSize
    }
    return total * size
}

function modalLayoutBlocks(modakWindow, blocks, area, horizontal) {
    var count = arrya_length(blocks)
    if (count == 0) { return }
    var total = horizontal ? area.w : area.h
    var cross = horizontal ? area.h : area.w
    var gap = modalWindow.panel.h * modalWindow.option("blockGap")
    var fixedSize = 0
    var fillCount = 0
    for (var blockIndex = 0; blockIndex < count; blockIndex++) {
        
    }
}