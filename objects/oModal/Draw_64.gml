for (var windowIndex = 0; windowIndex < array_length(windows); windowIndex++) {
    if (!windows[windowIndex].closed) { windows[windowIndex].draw() }
}