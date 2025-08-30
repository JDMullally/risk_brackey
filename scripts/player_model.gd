extends AnimatedSprite2D
class_name Player

@export var stats : PlayerStats

@onready var animation_state: PlayerAnimationState = $AnimationState

func _ready() -> void:
	GameRules.deal_damage_to_player.connect(take_damage)
	stats.set_health_max()
	animation_state.init(self)

func _process(delta: float) -> void:
	pass

func deal_damage(damage : int):
	GameRules.deal_damage_to_monster.emit(damage)
	animation_state.play_attack(damage)

func take_damage(damage : int, crush_value):
	stats.take_damage(damage, crush_value)
	if stats.is_dead():
		animation_state.play_dying()
	else:
		if damage > 0:
			animation_state.play_hit()

func add_blocks(blocks : int):
	stats.add_blocks(blocks)

func is_dead():
	return stats.is_dead()

func start_running() -> void:
	animation_state.start_running()

func stop_running() -> void:
	animation_state.stop_running_after_loop()

func heal_and_increase_health():
	stats.heal_and_increase_health()
