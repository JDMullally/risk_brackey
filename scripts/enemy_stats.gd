extends Resource
class_name EnemyStats

enum BonusAbilityType {None, Block, Dodge, Crush, Enrage, Endure, Regenerate}

@export var max_health : int
@export var size_multiplier : float
@export var floating_margin : int
@export var max_damage : int
@export var min_damage : int
@export var enemy_sprite : SpriteFrames
@export var enemy_sprite_flipped : bool
@export_multiline var description : String
@export var bonus_ability : BonusAbilityType
@export var bonus_ability_mod : float
@export var difficulty : int = 1

var _temp_ability_mod : float = 0.0
var _health : int = max_health

func blight_gambit():
	print('hello')
	min_damage = 2 * min_damage
	max_damage = 2 *  max_damage

func rewrite_gambit():
	var ability_types = [BonusAbilityType.Block, BonusAbilityType.Dodge, BonusAbilityType.Crush, BonusAbilityType.Enrage, BonusAbilityType.Endure, BonusAbilityType.Regenerate]
	var new_ability = ability_types[randi_range(0, 5)]
	var new_ability_modifier : float = 0.0
	var max_range : int
	
	if new_ability == BonusAbilityType.Dodge or new_ability == BonusAbilityType.Enrage:
		max_range = 2 + int(float(difficulty/3) * 1)
		new_ability_modifier = float(randi_range(2, max_range))
	elif new_ability == BonusAbilityType.Block:
		max_range = difficulty if difficulty > 3 else 3
		new_ability_modifier = float(randi_range(2, max_range))
	elif new_ability == BonusAbilityType.Endure:
		max_range = 2 * difficulty if 2 * difficulty > 8 else 8
		new_ability_modifier = float(randi_range(6 , max_range))
	else:
		max_range = 2 + difficulty 
		new_ability_modifier = float(randi_range(2, max_range))
	
	self.bonus_ability = new_ability
	self.bonus_ability_mod = new_ability_modifier

func increment_temp_ability_mod(increase : float):
	_temp_ability_mod += increase

func base_calculated_damage():
	return randi_range(min_damage, max_damage)

func heal(heal_amount : int):
	_health = clamp(_health + heal_amount, 0, max_health)

func get_current_health():
	return _health

func reset():
	_health = max_health
	_temp_ability_mod = 0.0

func is_dead():
	return _health <= 0

func take_damage(damage : int):
	_health = clampi(_health - damage, 0, _health)
