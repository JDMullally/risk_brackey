extends Panel
class_name Gambit

@onready var damage_label: RichTextLabel = $DamageLabel
@onready var block_label: RichTextLabel = $BlockLabel
@onready var point_label: RichTextLabel = $PointLabel
@onready var left_arrow: TextureRect = $LeftArrow
@onready var right_arrow: TextureRect = $RightArrow
@onready var continue_arrow: TextureRect = $ContinueArrow
@onready var gambit_arrow: TextureRect = $GambitArrow

@onready var undo: TextureRect = $Undo
@onready var fortune_wheel: Node2D = $FortuneWheel

var max_points : int = 5
var points: int = max_points
var damage: int = 0
var block: int = 0

func _ready() -> void:
	GameRules.start_gambit.connect(start_gambit)
	GameRules.select_gambit.connect(get_gambit_result)
	left_arrow.mouse_filter = Control.MOUSE_FILTER_STOP
	right_arrow.mouse_filter = Control.MOUSE_FILTER_STOP

	left_arrow.gui_input.connect(_on_left_arrow_input)
	right_arrow.gui_input.connect(_on_right_arrow_input)
	continue_arrow.gui_input.connect(_on_continue_arrow_input)
	gambit_arrow.gui_input.connect(_on_gambit_arrow_input)
	undo.gui_input.connect(_on_undo_input)
	_update_labels()
	hide()

func start_gambit(given_points : int):
	max_points = given_points
	points = max_points
	damage = 0
	block = 0
	modulate.a = .8
	_update_labels()
	show()


func _on_gambit_arrow_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var t := get_tree().create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.tween_property(continue_arrow, "scale", Vector2(1.15, 1.15), 0.08)
		t.tween_property(continue_arrow, "scale", Vector2(1.0, 1.0), 0.10)
		t.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		t.tween_property(self, "modulate:a", 0.0, 0.3)
		t.finished.connect(func():
			var c := modulate
			c.a = .8
			modulate = c
			GameRules.spin_the_wheel.emit()
			self.hide()
		)

func get_gambit_result(gambit : GameRules.GambitType):
	GameRules.gambit_finished.emit(damage, block, gambit)

func _on_continue_arrow_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var t := get_tree().create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.tween_property(continue_arrow, "scale", Vector2(1.15, 1.15), 0.08)
		t.tween_property(continue_arrow, "scale", Vector2(1.0, 1.0), 0.10)
		t.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		t.tween_property(self, "modulate:a", 0.0, 0.3)
		t.finished.connect(func():
			var c := modulate
			c.a = .8
			modulate = c
			GameRules.gambit_finished.emit(damage, block, GameRules.GambitType.None)
			self.hide()
		)

func _on_undo_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var tween := get_tree().create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(undo, "rotation_degrees", -359.0, 0.2)
		tween.finished.connect(func():
			undo.rotation_degrees = 0.0
			points = max_points
			damage = 0
			block = 0
			_update_labels()
			undo.visible = false
		)

func _on_left_arrow_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_click_tween(left_arrow)
		if points > 0:
			points -= 1
			damage += 1
			_update_labels()

func _on_right_arrow_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_click_tween(right_arrow)
		if points > 0:
			points -= 1
			block += 1
			_update_labels()

func _click_tween(node: Control) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(node, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(node, "scale", Vector2(1.0, 1.0), 0.1)

func _update_labels() -> void:
	damage_label.text = "[center][font_size=30]" + str(damage) + "[/font_size][/center]"
	block_label.text = "[center][font_size=30]" + str(block) + "[/font_size][/center]"
	point_label.text = "[center][font_size=30]" + str(points) + "[/font_size][/center]"
	
	continue_arrow.visible = (points == 0)
	gambit_arrow.visible = (points == 0)
	undo.visible = (points < max_points)
	
	var can_spend := points > 0
	left_arrow.modulate = Color(1, 1, 1, 1.0 if can_spend else 0.4)
	right_arrow.modulate = Color(1, 1, 1, 1.0 if can_spend else 0.4)
