extends Panel
class_name EnemyTooltip

@export var max_width: int = 420
@export var mouse_offset := Vector2(16, 12)

@onready var text_node: RichTextLabel = $MarginContainer/RichTextLabel

var _follow_mouse := false

func _ready() -> void:
	# Escape any parent Container sizing rules.
	top_level = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false

	# RichTextLabel setup
	text_node.bbcode_enabled = true
	text_node.fit_content = true
	text_node.autowrap_mode = TextServer.AUTOWRAP_WORD
	text_node.custom_minimum_size.x = max_width

	# Nice padding via the Panel's stylebox content margins
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0.85)
	sb.corner_radius_top_left = 10
	sb.corner_radius_top_right = 10
	sb.corner_radius_bottom_left = 10
	sb.corner_radius_bottom_right = 10
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	add_theme_stylebox_override("panel", sb)

func set_text(bbcode: String) -> void:
	text_node.clear()
	bbcode = "[font_size=24]" + bbcode + "[/font_size]"
	text_node.append_text(bbcode)
	await get_tree().process_frame
	_size_to_content()

func show_at_mouse() -> void:
	_follow_mouse = true
	visible = true
	_update_position(true)

func show_at_panel(panel: Control) -> void:
	_follow_mouse = false
	visible = true
	global_position = panel.get_global_rect().end + mouse_offset
	_clamp_to_viewport()

func hide_tooltip() -> void:
	_follow_mouse = false
	visible = false

func _process(_dt: float) -> void:
	if _follow_mouse and visible:
		_update_position(false)

func _update_position(force_now: bool) -> void:
	global_position = get_viewport().get_mouse_position() + mouse_offset
	if force_now:
		await get_tree().process_frame
	_clamp_to_viewport()

func _clamp_to_viewport() -> void:
	var vp := get_viewport_rect().size
	var sz := size
	var pos := global_position
	pos.x = clampf(pos.x, 0.0, vp.x - sz.x)
	pos.y = clampf(pos.y, 0.0, vp.y - sz.y)
	global_position = pos

func _size_to_content() -> void:
	var min_sz := get_combined_minimum_size()
	custom_minimum_size = min_sz
	reset_size()
