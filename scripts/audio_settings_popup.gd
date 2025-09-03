extends Control
class_name AudioSettingsPopup

@export var min_db:float = -60.0
@export var step:float = 1.0

const BUS_MASTER = "Master"
const BUS_MUSIC = "Music"
const BUS_SFX = "SFX"

var _buses = [BUS_MASTER, BUS_MUSIC, BUS_SFX]
var _sliders = {}
var _value_labels = {}
var _mutes = {}

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0

	var backdrop = ColorRect.new()
	backdrop.color = Color(0, 0, 0, 0.5)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(center)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(640, 360)
	center.add_child(panel)

	var root = MarginContainer.new()
	root.add_theme_constant_override("margin_left", 24)
	root.add_theme_constant_override("margin_right", 24)
	root.add_theme_constant_override("margin_top", 24)
	root.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(root)

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.custom_minimum_size = Vector2(520, 0)
	vbox.add_theme_constant_override("separation", 12)
	root.add_child(vbox)

	var title = Label.new()
	title.text = "Settings"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	vbox.add_child(_make_separator())
	for bus_name in _buses:
		var row = _make_bus_row(bus_name)
		vbox.add_child(row)
	vbox.add_child(_make_separator())

	var buttons = HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_END
	buttons.add_theme_constant_override("separation", 16)
	vbox.add_child(buttons)

	var btn_return = Button.new()
	btn_return.text = "Return"
	btn_return.custom_minimum_size = Vector2(240, 64)
	btn_return.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_return.add_theme_font_size_override("font_size", 22)
	btn_return.pressed.connect(func(): queue_free())
	buttons.add_child(btn_return)

	_ensure_buses()
	_seed_from_current()
	_apply_settings_to_buses()
	grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if Input.is_action_just_pressed("ui_cancel"):
			queue_free()
			accept_event()

func _make_separator() -> Control:
	var sep = HSeparator.new()
	sep.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return sep

func _make_bus_row(bus_name:String) -> Control:
	var h = HBoxContainer.new()
	h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.custom_minimum_size = Vector2(0, 36)

	var name_label = Label.new()
	name_label.text = bus_name
	name_label.custom_minimum_size = Vector2(120, 0)
	h.add_child(name_label)

	var s = HSlider.new()
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.min_value = 0.0
	s.max_value = 100.0
	s.step = step
	s.value_changed.connect(func(val:float): _on_slider_changed(bus_name, val))
	h.add_child(s)
	_sliders[bus_name] = s

	var val_label = Label.new()
	val_label.custom_minimum_size = Vector2(60, 0)
	val_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	h.add_child(val_label)
	_value_labels[bus_name] = val_label

	var mute = CheckBox.new()
	mute.text = "Mute"
	mute.toggled.connect(func(on:bool): _on_mute_toggled(bus_name, on))
	h.add_child(mute)
	_mutes[bus_name] = mute

	return h

func _ensure_buses() -> void:
	_ensure_bus(BUS_MUSIC)
	_ensure_bus(BUS_SFX)

func _ensure_bus(name:String) -> void:
	var idx = AudioServer.get_bus_index(name)
	if idx == -1:
		var insert_at = AudioServer.get_bus_count()
		AudioServer.add_bus(insert_at)
		AudioServer.set_bus_name(insert_at, name)

func _seed_from_current() -> void:
	for b in _buses:
		var db = _get_bus_db(b)
		var lin = db_to_linear(db)
		var pct = int(round(clampf(lin, 0.0, 1.0) * 100.0))
		_sliders[b].value = pct
		_mutes[b].button_pressed = _get_bus_mute(b)
	_update_value_labels()

func _apply_settings_to_buses() -> void:
	for b in _buses:
		_apply_bus_from_ui(b)

func _apply_bus_from_ui(bus_name:String) -> void:
	var idx = AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	var pct = float(_sliders[bus_name].value)
	var lin = pct * 0.01
	var db = min_db
	if lin > 0.0:
		db = linear_to_db(lin)
	AudioServer.set_bus_volume_db(idx, db)
	AudioServer.set_bus_mute(idx, _mutes[bus_name].button_pressed)

func _get_bus_db(bus_name:String) -> float:
	var idx = AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return 0.0
	return AudioServer.get_bus_volume_db(idx)

func _get_bus_mute(bus_name:String) -> bool:
	var idx = AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return false
	return AudioServer.is_bus_mute(idx)

func _on_slider_changed(bus_name:String, value:float) -> void:
	_apply_bus_from_ui(bus_name)
	_update_value_label(bus_name, value)

func _on_mute_toggled(bus_name:String, on:bool) -> void:
	_apply_bus_from_ui(bus_name)

func _update_value_labels() -> void:
	for b in _buses:
		_update_value_label(b, float(_sliders[b].value))

func _update_value_label(bus_name:String, v:float) -> void:
	var pct = int(round(v))
	_value_labels[bus_name].text = str(pct, "%")
