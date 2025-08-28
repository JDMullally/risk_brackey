extends HealthBar
@export var character: Enemy

func _ready() -> void:
	GameRules.update_hp.connect(update_health_bar)
	update_health_bar()

func update_health_bar():
	clear_all_hearts()
	fill_health_bar(character.enemy_stats.get_current_health(), character.enemy_stats.max_health)
