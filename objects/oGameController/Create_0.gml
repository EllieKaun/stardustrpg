if (!instance_exists(oTransition)) {
    instance_create_layer(0, 0, "Instances", oTransition);
}



layers = ["Tiles_Forest_1", "Tiles_Forest_2", "Tiles_Forest_3", "Tiles_Forest_4"]

//scr_tile_deepen(layers, 16, 16, room_height);




layer_depth(layer_get_id("Tiles_Bg"), 14000)
layer_depth(layer_get_id("Tiles_Dirt"), 13000)
layer_depth(layer_get_id("Tiles_Water"), 12000)
layer_depth(layer_get_id("Tiles_Grass"), 11000)

//scr_tile_deepen("Tiles_Forest_4", 8, 8, room_height);
//scr_tile_deepen("Tiles_Forest_3", 8, 8, room_height);
//scr_tile_deepen("Tiles_Forest_2", 8, 8, room_height);
scr_tile_deepen("Tiles_Forest_1", 8, 8, room_height);

lid1 = layer_get_id("Tiles_Forest_1");
//lid2 = layer_get_id("Tiles_Forest_2");
//lid3 = layer_get_id("Tiles_Forest_3");
//lid4 = layer_get_id("Tiles_Forest_4");

layer_destroy(lid1);
//layer_destroy(lid2);
//layer_destroy(lid3);
//layer_destroy(lid4);