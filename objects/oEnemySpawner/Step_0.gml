var p = instance_find(oLana, 0);
if (p == noone) exit;

with (oEnemy)
{
    if (point_distance(x, y, p.x, p.y) > other.despawn_distance)
    {
        instance_destroy();
    }
}

spawn_timer--;

if (spawn_timer <= 0)
{
    spawn_timer = spawn_delay;

    if (instance_number(oEnemy) >= max_enemies)
        exit;

    var enemy_obj = choose(
        oCrakerNutSmall,
        oFlowerSmall,
        oMushroomSmall,
        oLeafSmall
    );
    
    var move_dx = p.x - p.xprevious;
    var move_dy = p.y - p.yprevious;
    
    var move_dir;
    if (abs(move_dx) + abs(move_dy) > 0.1)
    {
        move_dir = point_direction(0, 0, move_dx, move_dy);
    }
    else
    {
        move_dir = irandom(359);
    }
    
    var spread = 60;
    var angle  = move_dir + random_range(-spread * 0.5, spread * 0.5);
    var dist   = irandom_range(spawn_radius_min, spawn_radius_max);
    dist += abs(random_range(-20, 20));

    var spawn_x = p.x + lengthdir_x(dist, angle);
    var spawn_y = p.y + lengthdir_y(dist, angle);
    
    
    var cam = view_camera[0];
    var vx = camera_get_view_x(cam);
    var vy = camera_get_view_y(cam);
    var vw = camera_get_view_width(cam);
    var vh = camera_get_view_height(cam);

    if (spawn_x > vx && spawn_x < vx + vw &&
        spawn_y > vy && spawn_y < vy + vh)
    {
        exit;
    }

    instance_create_layer(spawn_x, spawn_y, "Instances", enemy_obj);
}
