extends AnimatedSprite2D
class_name Player

@export var stats : PlayerStats
var current_animation : String
var attack_animations : Array

func _ready() -> void:
	attack_animations = ["attack_1", "attack_2", "attack_3"]
	stats.set_health_max()
	change_animation("idle")

func change_animation(new_animation : String):
	current_animation = new_animation
	self.play(new_animation)

func reset_to_idle():
	if current_animation == "idle" or current_animation == "dead" or current_animation == "running":
		pass
	elif current_animation == "dying" and self.frame == self.sprite_frames.get_frame_count(current_animation) - 1:
		change_animation("dead")
	elif self.frame == self.sprite_frames.get_frame_count(current_animation) - 1:
		change_animation("idle")

func _process(delta: float) -> void:
	reset_to_idle()

func start_idle():
	change_animation("idle")

func deal_damage(damage : int):
	var random_attack = attack_animations[randi_range(0, 2)]
	change_animation(random_attack)
	GameRules.deal_damage_to_monster.emit(damage)

func stop_running():
	start_idle()

func start_running():
	change_animation("running")

func take_damage(damage : int):
	change_animation("hit")
	stats.take_damage(damage)

func kill_player():
	change_animation("dying")

func is_dead():
	return stats.is_dead()
	
