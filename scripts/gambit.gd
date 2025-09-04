extends Panel
class_name Gambit

@onready var damage_label: RichTextLabel = $DamageLabel
@onready var block_label: RichTextLabel = $BlockLabel
@onready var point_label: RichTextLabel = $PointLabel
@onready var left_arrow: TextureRect = $LeftArrow
@onready var right_arrow: TextureRect = $RightArrow
@onready var continue_arrow: TextureRect = $ContinueArrow
@onready var click_sfx: AudioStreamPlayer = $ClickSFX

@onready var undo: TextureRect = $Undo
@onready var gambit_info: RichTextLabel = $GambitInfo

var max_points : int = 5
var points: int = max_points
var damage: int = 0
var block: int = 0
var current_gambit : GameRules.GambitType = GameRules.GambitType.None

func _ready() -> void:
	GameRules.select_actions.connect(select_actions)
	GameRules.get_gambit.connect(get_gambit_result)
	left_arrow.mouse_filter = Control.MOUSE_FILTER_STOP
	right_arrow.mouse_filter = Control.MOUSE_FILTER_STOP

	left_arrow.gui_input.connect(_on_left_arrow_input)
	right_arrow.gui_input.connect(_on_right_arrow_input)
	continue_arrow.gui_input.connect(_on_continue_arrow_input)
	undo.gui_input.connect(_on_undo_input)
	_update_labels()
	hide()

func select_actions(given_points : int, gambit_type : GameRules.GambitType):
	current_gambit = gambit_type
	set_gambit_info(gambit_type)
	match current_gambit:
		GameRules.GambitType.Blight:
			max_points = clampi(given_points - 1, 0, given_points)
			points = max_points
		_:
			max_points = given_points
			points = max_points
	damage = 0
	block = 0
	modulate.a = .8
	_update_labels()
	show()


func set_gambit_info(gambit_type : GameRules.GambitType):
	gambit_info.clear()
	var text = "[font_size=18]"
	match gambit_type:
		GameRules.GambitType.Strength:
			text = text + "[color=ORANGE_RED][Strength][/color]: Increase the number of your attacks by 2."
		GameRules.GambitType.Blight:
			text = text + "[color=DARK_OLIVE_GREEN][Blight][/color]: Lose one action point this turn."
		GameRules.GambitType.Defense:
			text = text + "[color=CADET_BLUE][Defense][/color]: Increase the number of your blocks by 2."
		GameRules.GambitType.Reflect:
			text = text + "[color=PALE_GOLDENROD][Reflect][/color]: You deal your damage to your enemy and yourself.  This self damage can be blocked."
		GameRules.GambitType.Lifesteal:
			text = text + "[color=CRIMSON][Lifesteal][/color]: You heal for the damage you would do on your turn, regardless if the monster blocks it or not."
		GameRules.GambitType.Rewrite:
			text = text + "[color=ORCHID][Rewrite][/color]: Changes an enemy's ability to a random one."
			GameRules.change_monster_affix.emit()
		GameRules.GambitType.None:
			text = ""
		_:
			text = text + "How did this even happen?"
	text = text + "[/font_size]"
	gambit_info.append_text(text)

func get_gambit_result(gambit : GameRules.GambitType):
	GameRules.gambit_finished.emit(damage, block, gambit)

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
			GameRules.gambit_finished.emit(damage, block, current_gambit)
			self.hide()
		)

func _on_undo_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		click_sfx.play()
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
		click_sfx.play()
		_click_tween(left_arrow)
		if points > 0:
			points -= 1
			damage += 1
			_update_labels()

func _on_right_arrow_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		click_sfx.play()
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
	damage_label.clear()
	block_label.clear()
	point_label.clear()
	
	damage_label.append_text("[center][font_size=30]" + str(damage) + "[/font_size][/center]")
	block_label.append_text("[center][font_size=30]" + str(block) + "[/font_size][/center]")
	
	match current_gambit:
		GameRules.GambitType.Blight:
			point_label.append_text("[pulse freq=1.0 color=#ffffff40 ease=-2.0][color=DARK_OLIVE_GREEN][center][font_size=30]" + str(points) + "[/font_size][/center][/color][/pulse]")
		_:
			point_label.append_text("[center][font_size=30]" + str(points) + "[/font_size][/center]")
	
	continue_arrow.visible = (points == 0)
	undo.visible = (points < max_points)
	
	var can_spend := points > 0
	left_arrow.modulate = Color(1, 1, 1, 1.0 if can_spend else 0.4)
	right_arrow.modulate = Color(1, 1, 1, 1.0 if can_spend else 0.4)
