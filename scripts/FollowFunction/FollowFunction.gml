function SpawnPartyFollowers(player_inst) {
	var prev = player_inst;

	for (var i = 1; i < array_length(global.party); i++) {

		var member = global.party[i];

		var f = instance_create_layer(
		    player_inst.x,
		    player_inst.y,
		    "Instances",
		    oPartyFollower
		);

		// draw behind player
		f.depth = player_inst.depth + 1;

		// follow chain
		f.leader = prev;
		f.follow_index = 10;

		// store sprites
		f.sprite_idle = member.sprites.idle;
		f.sprite_walk = member.sprites.walk;

		// start idle
		f.sprite_index = f.sprite_idle;
		f.image_speed = 0;

		prev = f;
	}
}
