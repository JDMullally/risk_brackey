extends Node2D

@onready var label: Label = $Label
@onready var sprite_2d: Sprite2D = $Sprite2D
@export var texture : Texture
var tween : Tween
var tween_in_progress := false

func bounce():
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween_in_progress = true
	self.scale = Vector2(1.1, 1.1)
	tween.tween_property(self, "scale", Vector2(1, 1), .3)
	await tween.finished
	tween.kill()
	tween_in_progress = false

func _ready() -> void:
	sprite_2d.texture = texture
	label.text = "0"

func update_text(new_number : int) -> void:
	label.text = str(new_number)
	bounce()
