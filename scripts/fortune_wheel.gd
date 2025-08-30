extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D
var t : Tween
@onready var timer: Timer = $Timer
@onready var rich_text_label: RichTextLabel = $RichTextLabel
var wheel_result : GameRules.GambitType

func _ready() -> void:
	GameRules.spin_the_wheel.connect(spin_the_wheeeeel)
	rich_text_label.bbcode_enabled = true
	rich_text_label.scroll_active = false
	timer.timeout.connect(hide_wheel)
	spin_then_slow(sprite_2d)

func hide_wheel():
	GameRules.get_gambit.emit(wheel_result)
	self.hide()

func spin_the_wheeeeel():
	self.show()
	wheel_result = GameRules.GambitType.None
	spin_then_slow(sprite_2d)

func spin_then_slow(node: Node2D, slow_rotations: float = 2.0) -> Tween:
	t = get_tree().create_tween()
	if !t.finished.is_connected(resolve_gambit_wheel):
		t.finished.connect(resolve_gambit_wheel)
	var start := node.rotation
	
	var run_rot := TAU * randf_range(1.4, 2.5) * 5.0
	t.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT) 
	t.tween_property(node, "rotation", start + run_rot, randf_range(4.0, 8.0))
	t.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(node, "rotation", start + run_rot + slow_rotations * TAU, randf_range(4.0, 8.0))
	return t

func resolve_gambit_wheel():
	var options = sprite_2d.get_children()
	var text : String = "[wave][rainbow]"
	var min_node: Sprite2D = options[0]
	var min_y = options[0].global_position.y
	for n in options:
		var y = n.global_position.y
		if y < min_y:
			min_y = y
			min_node = n
	match min_node.name:
		"Strength":
			wheel_result = GameRules.GambitType.None
			text = text + min_node.name
		"Blight":
			wheel_result = GameRules.GambitType.None
			text = text + min_node.name
		"Defense":
			wheel_result = GameRules.GambitType.None
			text = text + min_node.name
		"Reflect":
			wheel_result = GameRules.GambitType.None
			text = text + min_node.name
		"Health":
			wheel_result = GameRules.GambitType.None
			text = text + min_node.name
		"Rewrite":
			wheel_result = GameRules.GambitType.None
			text = text + min_node.name
	
	text = text + "[/rainbow][/wave]"
	rich_text_label.clear()
	rich_text_label.append_text(text)
	bounce_text_tween(rich_text_label)
	
func bounce_text_tween(label: RichTextLabel) -> Tween:
	label.visible = true
	label.scale = Vector2.ONE * 0.1
	var t := get_tree().create_tween()
	t.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(label, "scale", Vector2.ONE * 2.0, 0.7) 
	t.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	t.tween_property(label, "scale", Vector2.ONE * 0.05, 0.3)
	t.finished.connect(func():
		label.visible = false
		label.scale = Vector2.ONE
		timer.start()
	)
	return t
