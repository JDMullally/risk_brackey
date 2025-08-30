extends Resource
class_name EnemyStats

enum BonusAbilityType {None, Block, Dodge, Crush, Enrage, Endure, Regenerate}

@export var max_health : int
var _health : int
@export var size_multiplier : float
@export var floating_margin : int
@export var max_damage : int
@export var min_damage : int
@export var enemy_sprite : SpriteFrames
@export var enemy_sprite_flipped : bool
@export_multiline var description : String
@export var bonus_ability : BonusAbilityType
@export var bonus_ability_mod : float
var _temp_ability_mod : float

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
