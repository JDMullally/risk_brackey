extends HealthBar
class_name PlayerHealthBar

@export var character : Player

func _ready() -> void:
	GameRules.update_hp.connect(update_health_bar)
	update_health_bar()

func update_health_bar():
	clear_all_hearts()
	fill_health_bar(character.stats.get_current_health(), character.stats.max_hp)
	
