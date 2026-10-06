show_debug_message("----- Dstroyed EnemyObject at position " + string(x) + " " + string(y))

if (carriesSpear && variable_global_exists("spearCarrierExists") && global.spearCarrierExists) {
    global.spearCarrierExists = false
}

if (carriesCauldron && variable_global_exists("cauldronCarrierExists") && global.cauldronCarrierExists) {
    global.cauldronCarrierExists = false
}