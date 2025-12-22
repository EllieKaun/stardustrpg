//action liibrary

global.actionLibrary = {
	attack: {
		name: "attack",
		description: "{0} attacks!",
		subMenu: -1,
		targetRequired: true,
		targetAll: MODE.NEVER,
		userAnimation: "attack",
		effectSprite: sSlice,
		effectOnTarget: MODE.ALWAYS,
		func: function(_user, _targets){
			var _damage = ceil(_user.str * random_range(1, 3));
			BattleChangeHP(_targets[0], -_damage, 0);
		}
	
	}
}

enum MODE {
    NEVER = 0,
	ALWAYS = 1,
	VARIES = 2
}


//Party data

global.party = [
	{
		name: "Lana",
		hp: 10,
		hpMax: 10,
		mp: 5,
		mpMax: 5,
		str: 1,
		int: 5,
		def: 2,
		sprites: {idle: sLana, battleIdle: sLanaBattleIdle, attack: sLanaAttack, KO: sLanaKO},
		actions: []
	},
	{
		name: "Viv",
		hp: 15,
		hpMax: 15,
		mp: 2,
		mpMax: 2,
		str: 2,
		int: 1,
		def: 2,
		sprites: {idle: sViv, walk: sVivWalk, battleIdle: sVivBattleIdle, attack: sVivAttack, KO: sVivKO },
		actions: []
	},
]


//Enemies data
global.enemies = {
	Bird: {
		name: "Bird",
		hp: 10,
		hpMax: 30,
		mp: 5,
		mpMax: 5,
		str: 2,
		int: 2,
		def: 1,
		sprites: {idle: sBird, battleIdle: sBird, attack: sBirdAttack, KO: sBirdKO },
		xpValue: 10,
		actions: [global.actionLibrary.attack],
		AIscript: function(){
			var _action = actions[0];
			var _possibleTargets = array_filter(oBattle.partyUnits, function(_unit){
				return (_unit.hp > 0);
			});
			if(array_length(_possibleTargets) > 0){
				var _target = _possibleTargets[irandom(array_length(_possibleTargets)-1)];
				return [_action, _target];
			}
		}
	},
	Mashroom: {
		name: "Mashroom",
		hp: 50,
		hpMax: 50,
		mp: 1,
		mpMax: 1,
		str: 1,
		int: 1,
		def: 4,
		sprites: {idle: sMashroom, battleIdle: sMashroom},
		xpValue: 10,
		actions: [global.actionLibrary.attack]
	},
	Flower: {
		name: "Flower",
		hp: 20,
		hpMax: 20,
		mp: 5,
		mpMax: 5,
		str: 1,
		int: 4,
		def: 1,
		sprites: {idle: sFlower, battleIdle: sMashroom},
		xpValue: 10,
		actions: [global.actionLibrary.attack]
	},

}