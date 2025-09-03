extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var result_sound: AudioStreamPlayer = $ResultSound

var player_points : int
var t : Tween
var wheel_result : GameRules.GambitType
var _prev_deg: float = 0.0
var step_deg : float = 45.0

func _ready() -> void:
	GameRules.spin_the_wheel.connect(spin)
	timer.timeout.connect(hide_wheel)
	self.hide()

func hide_wheel():
	GameRules.select_actions.emit(player_points, wheel_result)
	self.hide()

func spin(points : int):
	self.show()
	player_points = points
	wheel_result = GameRules.GambitType.None
	spin_then_slow(sprite_2d)

func _process(delta: float) -> void:
	play_sfx_for_sprite_rotation()

func play_sfx_for_sprite_rotation():
	var curr = fposmod(sprite_2d.rotation_degrees, 360.0)
	var diff = curr - _prev_deg
	if diff > 180.0:
		diff -= 360.0
	elif diff < -180.0:
		diff += 360.0
	if diff != 0.0:
		var dir = 1 if diff > 0.0 else -1
		var end_val = _prev_deg + diff
		var step = step_deg
		if dir > 0:
			var next = floor(_prev_deg / step) * step + step
			while next <= end_val + 0.0001:
				audio_stream_player.play()
				next += step
		else:
			var base = _prev_deg
			if fposmod(base, step) < 0.0001:
				base -= 0.0001
			var next = floor(base / step) * step
			while next >= end_val - 0.0001:
				audio_stream_player.play()
				next -= step
	_prev_deg = curr


func spin_then_slow(node: Node2D, slow_rotations: float = 2.0) -> Tween:
	t = get_tree().create_tween()
	if !t.finished.is_connected(resolve_gambit_wheel):
		t.finished.connect(resolve_gambit_wheel)
	var start := node.rotation
	
	var run_rot := TAU * randf_range(1.4, 2.5) * 5.0
	t.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT) 
	t.tween_property(node, "rotation", start + run_rot, randf_range(.7, 2.5))
	t.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(node, "rotation", start + run_rot + slow_rotations * TAU, randf_range(2.1, 4.8))
	return t

func resolve_gambit_wheel():
	var options = sprite_2d.get_children()
	var text : String = "[font_size=256][center][wave][rainbow]"
	var min_node: Sprite2D = options[0]
	var min_y = options[0].global_position.y
	for n in options:
		var y = n.global_position.y
		if y < min_y:
			min_y = y
			min_node = n
	match min_node.name:
		"Strength":
			wheel_result = GameRules.GambitType.Strength
			text = text + min_node.name
		"Blight":
			wheel_result = GameRules.GambitType.Blight
			text = text + min_node.name
		"Defense":
			wheel_result = GameRules.GambitType.Defense
			text = text + min_node.name
		"Reflect":
			wheel_result = GameRules.GambitType.Reflect
			text = text + min_node.name
		"Lifesteal":
			wheel_result = GameRules.GambitType.Lifesteal
			text = text + min_node.name
		"Rewrite":
			wheel_result = GameRules.GambitType.Rewrite
			text = text + min_node.name
		_:
			wheel_result = GameRules.GambitType.None
			text = "How did this even happen?"
	
	text = text + "[/rainbow][/wave][/center][/font_size]"
	GameRules.announce.emit(text)
	result_sound.play()
	timer.start()
