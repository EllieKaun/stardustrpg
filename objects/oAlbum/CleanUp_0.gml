if (variable_instance_exists(id, "panel") && is_struct(panel)) {
    if (surface_exists(panel.clipSurface)) surface_free(panel.clipSurface)
}
global.uiModal = false
