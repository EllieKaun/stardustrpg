enum Zone { Inner, Middle, Outer }
enum Section { NE, NW, SW, SE }

function zoneAt(px, py) {
    var c = global.zoneConfig
    var cheb = max(abs(px - c.cx), abs(py - c.cy))
    if (cheb <= c.innerHalf)  return Zone.Inner
    if (cheb <= c.middleHalf) return Zone.Middle
    return Zone.Outer
}

function sectionAt(px, py) {
    var c  = global.zoneConfig
    var dx = px - c.cx
    var dy = py - c.cy
    if (dy < 0) return (dx >= 0) ? Section.NE : Section.NW
    else return (dx >= 0) ? Section.SE : Section.SW
}


function enemyTypesForRegion(zone, section) {
    switch (zone) {
        case Zone.Outer:
            switch (section) {
                case Section.NE: return [oCrakerNutSmall]
                case Section.NW: return [oCrakerNutSmall]
                case Section.SW: return [oCrakerNutSmall, oMushroomSmall]
                case Section.SE: return [oMushroomSmall]
            }
        break;
        case Zone.Middle:
            switch (section) {
                case Section.NE: return [oMushroomSmall]
                case Section.NW: return [oCrakerNutSmall, oMushroomSmall]
                case Section.SW: return [oMushroomSmall]
                case Section.SE: return [oCrakerNutSmall]
            }
        break;
        case Zone.Inner: 
            return [oMushroomSmall]
    }
    return [oCrakerNutSmall]
}