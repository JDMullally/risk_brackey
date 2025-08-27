extends AnimatedSprite2D
class_name Player

@export var stats : PlayerStats

func _ready() -> void:
	self.play("idle")

func start_idle():
	self.play("idle")

func take_damage(damage : int):
	stats.take_damage(damage)
	
	
