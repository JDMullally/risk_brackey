extends AnimatedSprite2D
class_name Player

@export var stats : PlayerStats

func _ready() -> void:
	self.play("idle")
