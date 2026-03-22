for (var i = array_length(effectNotifications) - 1; i >= 0; i--) {
    
    var notif = effectNotifications[i];
    
    notif.currentFrame += 1;

    if (notif.currentFrame >= notif.totalFrames) {
        array_delete(effectNotifications, i, 1);
    }
}