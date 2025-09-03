extends AnimatedSprite2D
class_name Player

@export var stats : PlayerStats

@onready var animation_state: PlayerAnimationState = $AnimationState
@onready var hit: AudioStreamPlayer = $Hit
@onready var attack: AudioStreamPlayer = $Attack
@onready var block: AudioStreamPlayer = $Block
@onready var level_up: AudioStreamPlayer = $LevelUp

func _ready() -> void:
	GameRules.deal_damage_to_player.connect(take_damage)
	stats.set_health_max()
	animation_state.init(self)

func _process(delta: float) -> void:
	pass

func deal_damage(damage : int):
	GameRules.deal_damage_to_monster.emit(damage)
	animation_state.play_attack(damage)
	attack.play()

func take_damage(damage : int, crush_value):
	var prev_curr_hp = stats.current_health
	stats.take_damage(damage, crush_value)
	if stats.current_health == prev_curr_hp:
		block.play()
	hit.play()
	if stats.is_dead():
		animation_state.play_dying()
	else:
		if damage > 0:
			animation_state.play_hit()

func add_blocks(blocks : int):
	stats.add_blocks(blocks)

func ready_for_game_over_screen():
	return is_dead() and animation_state.is_current_animation_dead()

func is_dead():
	return stats.is_dead()

func start_running() -> void:
	animation_state.start_running()

func stop_running() -> void:
	animation_state.stop_running_after_loop()

func heal_and_increase_health():
	stats.heal_and_increase_health()

func increase_actions():
	stats.increase_num_actions()
	level_up.play()

func heal(value : int):
	stats.heal(value)
