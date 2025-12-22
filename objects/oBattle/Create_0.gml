instance_deactivate_all(true);

units = [];
turn = 0;
unitTurnOrder = [];
unitRenderOrder = [];



turnCount = 0;
roundCount = 0;
battleWaitiTimeFrames = 30;
battleWaitiTimeRemaining = 0;
currentUser = noone;
currentAction = -1;
currentTargets = noone;



var cam = view_camera[0];


// store original size
orig_view_w = camera_get_view_width(cam);
orig_view_h = camera_get_view_height(cam);

camera_set_view_size(
	cam,
	orig_view_w * 0.75,
	orig_view_h * 0.75
);

var cam_x = x - camera_get_view_width(cam) * 0.5;
var cam_y = y - camera_get_view_height(cam) * 0.5;


camera_set_view_pos(cam, cam_x, cam_y);




battle_left_x  = camera_get_view_x(cam) + camera_get_view_width(cam) * 0.25;
battle_right_x = camera_get_view_x(cam) + camera_get_view_width(cam) * 0.75;

battle_center_y = camera_get_view_y(cam) + camera_get_view_height(cam) * 0.25;


enemiesUnits = [];


for (var i = 0; i < array_length(enemies); i++) {
	
	var spacing = sprite_get_height(enemies[i].sprites.battleIdle);

	var yy = battle_center_y + i * spacing ;


	enemiesUnits[i] = instance_create_depth(
		battle_right_x,
		yy,
		depth - 10,
		oBattleUnitEnemy,
		enemies[i]
	);

	array_push(units, enemiesUnits[i]);
}



partyUnits = [];


for (var i = 0; i < array_length(global.party); i++) {
	
	var spacing = sprite_get_height(global.party[i].sprites.battleIdle);
	var yy = battle_center_y + i * spacing;

	partyUnits[i] = instance_create_depth(
		battle_left_x,
		yy,
		depth - 10,
		oBattleUnitParty,
		global.party[i]
	);

	array_push(units, partyUnits[i]);
}


unitTurnOrder = array_shuffle(units);

RefreshRenderOrder = function(){
	unitRenderOrder = [];
	array_copy(unitRenderOrder, 0, units, 0, array_length(units));
	array_sort(unitRenderOrder, function(_1, _2){
		return _1.y - _2.y
	});
}

RefreshRenderOrder()



function BattleStateSelectAction (){
	var _unit = unitTurnOrder[turn];
	
	if(!instance_exists(_unit) || (_unit.hp <= 0)){
		battleState = BattleStateVictoryCheck;
		exit;
	}

	//BeginAction(_unit.id, global.actionLibrary.attack, _unit.id);
	if(_unit.object_index == oBattleUnitParty){
	
			var _action = global.actionLibrary.attack;
			var _possibleTargets = array_filter(oBattle.enemiesUnits, function(_unit){
				return (_unit.hp > 0);
			});
			
			var _target = _possibleTargets[irandom(array_length(_possibleTargets)-1)];
			BeginAction(_unit.id, _action, _target);

	
	}else{
		var _enemyAction = _unit.AIscript();
		if(!is_undefined(_enemyAction)){
			if(_enemyAction != -1){
				BeginAction(_unit.id, _enemyAction[0], _enemyAction[1]);
			}
		}
	}
}

function BeginAction(_user, _action, _targets){
	
	currentUser = _user;
	currentAction = _action;
	currentTargets = _targets;
	
	if(!is_array(currentTargets)){
		currentTargets = [currentTargets];
	}
	battleWaitiTimeRemaining = battleWaitiTimeFrames;
	with(_user){
		acting = true;
		if(!is_undefined(_action[$ "userAnimation"]) && !is_undefined(_user.sprites[$ _action.userAnimation])){
			sprite_index = sprites[$  _action.userAnimation];
		}
	}	
	battleState = BattleStatePerformAction;
}

function BattleStatePerformAction(){
	if(currentUser.acting){
		if(currentUser.image_index >= currentUser.image_number - 1){
			with(currentUser){
				sprite_index = sprites.battleIdle;
				acting = false;
			}
			
			if(variable_struct_exists(currentAction, "effectSprite")){
				if(currentAction.effectOnTarget == MODE.ALWAYS || (currentAction.effectOnTarget == MODE.VARIES && array_length(currentTargets) <= 1)){
					for(var i = 0; i < array_length(currentTargets); i++){
						instance_create_depth(currentTargets[i].x, currentTargets[i].y, currentTargets[i].depth - 1, oBattleEffect, {sprite_index: currentAction.effectSprite});
					}
				} else{
					var _effectSprites = currentAction.effectSprite;
					if(variable_struct_exists(currentAction, "effectSpriteNoTarget")){
						_effectSprites = currentAction.effectSpriteNoTarget
					}
					instance_create_depth(x, y, depth - 100, oBattleEffect, {sprite_index: _effectSprites});
				}
			}
			
			currentAction.func(currentUser, currentTargets);
		}
	}else{
		if(!instance_exists(oBattleEffect)){
			battleWaitiTimeRemaining--
			if(battleWaitiTimeRemaining <= 0){
				battleState = BattleStateVictoryCheck;
			}
		}
	}
}

function BattleStateVictoryCheck(){
	battleState = BattleStateTurnProression;
}

function BattleStateTurnProression(){
	turnCount++
	turn++
	if(turn > (array_length(unitTurnOrder) - 1)){
		turn = 0;
		roundCount++
	}
	battleState = BattleStateSelectAction; 
}

battleState = BattleStateSelectAction;