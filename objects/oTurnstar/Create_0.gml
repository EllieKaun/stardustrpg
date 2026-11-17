interaction = new Interactable(id, {
    onInteract: function() {
        if (instance_exists(oShop) && !oShop.open) { oShop.openShop() }
    }
})
