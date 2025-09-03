extends Resource
class_name PlayerStats

@export var max_hp : int
@export var num_actions : int
@export var health_per_round : int
var current_health : int
var current_blocks : int = 0

func heal_and_increase_health():
	max_hp = max_hp + 1
	current_health = clampi(current_health + 1 + health_per_round, 0, max_hp)
	GameRules.update_hp.emit()

func increase_num_actions():
	num_actions += 1

func set_health_max():
	current_health = int(max_hp)

func add_blocks(blocks):
	current_blocks = blocks
	
func reset_blocks():
	current_blocks = 0

func get_current_health():
	return current_health

func is_dead():
	return current_health <= 0

func take_damage(damage : int, crush_value):
	var actual_blocks = clampi((current_blocks - crush_value), 0, current_blocks)
	var new_damage = clampi(damage - actual_blocks, 0, damage)
	current_health = clampi(current_health - new_damage, 0, current_health)

func heal(value : int):
	current_health = clampi(current_health + value, 0, max_hp)
