extends Resource
class_name PlayerStats

@export var max_hp : int
@export var num_actions : int
var current_health : int = max_hp
var current_blocks : int = 0

func add_blocks(blocks):
	current_blocks = blocks
	
func reset_blocks():
	current_blocks = 0

func get_current_health():
	return current_health

func is_dead():
	return current_health <= 0

func take_damage(damage : int):
	var new_damage = clampi(damage - current_blocks, 0, damage)
	current_health = clampi(current_health - new_damage, 0, current_health)
