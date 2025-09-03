extends Panel

@onready var click_sfx: AudioStreamPlayer = $ClickSFX
@onready var gambit_arrow: TextureRect = $GambitArrow
@onready var continue_arrow: TextureRect = $ContinueArrow

var player_actions : int = 0

func _ready() -> void:
	GameRules.start_gambit.connect(select_gambit)
	continue_arrow.gui_input.connect(_on_continue_arrow_input)
	gambit_arrow.gui_input.connect(_on_gambit_arrow_input)

func select_gambit(points : int):
	self.show()
	player_actions = points

func _on_gambit_arrow_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		click_sfx.play()
		var t := get_tree().create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.tween_property(gambit_arrow, "scale", Vector2(1.15, 1.15), 0.08)
		t.tween_property(gambit_arrow, "scale", Vector2(1.0, 1.0), 0.10)
		t.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		t.tween_property(self, "modulate:a", 0.0, 0.3)
		t.finished.connect(func():
			var c := modulate
			c.a = .8
			modulate = c
			GameRules.spin_the_wheel.emit(player_actions)
			self.hide()
		)

func _on_continue_arrow_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		click_sfx.play()
		var t := get_tree().create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.tween_property(continue_arrow, "scale", Vector2(1.15, 1.15), 0.08)
		t.tween_property(continue_arrow, "scale", Vector2(1.0, 1.0), 0.10)
		t.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		t.tween_property(self, "modulate:a", 0.0, 0.3)
		t.finished.connect(func():
			var c := modulate
			c.a = .8
			modulate = c
			GameRules.select_actions.emit(player_actions, GameRules.GambitType.None)
			self.hide()
			)
