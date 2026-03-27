zoneHalfW = 400
zoneHalfH = 300
visionRadius = 150
maxSpawnAttempts = 30

findSpawnPosition = function() {
    var _px = oLana.x
    var _py = oLana.y
    var _mgr = oSpawnerManager;
    for (var _try = 0; _try < maxSpawnAttempts; _try++) {
        var _sx = x + random_range(-zoneHalfW, zoneHalfW);
        var _sy = y + random_range(-zoneHalfH, zoneHalfH);
        if (point_distance(_px, _py, _sx, _sy) < visionRadius) continue;
        var _tooClose = false;
        for (var i = 0; i < ds_list_size(_mgr.enemyList); i++) {
            var _other = _mgr.enemyList[| i];
            if (instance_exists(_other)) {
                if (point_distance(_sx, _sy, _other.x, _other.y) < _mgr.minEnemySpacing) {
                    _tooClose = true;
                    break;
                }
            }
        }
        if (_tooClose) continue;
        return [_sx, _sy];
    }
    return [noone, noone];
};