extends Panel
class_name HoverInfoPanel

const ENDURE = Rect2(Vector2(256, 96), Vector2(32, 32))
const BLOCK = Rect2(Vector2(224, 96), Vector2(32, 32))
const NONE = Rect2(Vector2(64, 0), Vector2(32, 32))
const CRUSH = Rect2(Vector2(352, 96), Vector2(32, 32))
const ENRAGE = Rect2(Vector2(128, 0), Vector2(32, 32))
const DODGE = Rect2(Vector2(384, 96), Vector2(32, 32))
const REGENERATE = Rect2(Vector2(160, 96), Vector2(32, 32))

enum AbilityNumber {One, Two}

@onready var sprite_2d: Sprite2D = $Sprite2D
@export var texture : Texture2D
@export var enemy: Enemy
@export var tooltip: EnemyTooltip
@export var use_mouse_follow_tooltip := true
@export var normal_bg: Color = Color(0.12, 0.12, 0.16, 1.0)
@export var hover_bg: Color = Color(0.20, 0.20, 0.28, 1.0)
@export var tween_time := 0.08

var bonus_ability : EnemyStats.BonusAbilityType
var bonus_ability_value : int
var _tween: Tween
var atlas_texture : AtlasTexture

func change_image():
	if !atlas_texture:
		atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = texture
		
	
	self.show()
	match bonus_ability:
		EnemyStats.BonusAbilityType.None:
			atlas_texture.set_region(NONE)
			self.hide()
		EnemyStats.BonusAbilityType.Block:
			atlas_texture.set_region(BLOCK)
		EnemyStats.BonusAbilityType.Dodge:
			atlas_texture.set_region(DODGE)
		EnemyStats.BonusAbilityType.Crush:
			atlas_texture.set_region(CRUSH)
		EnemyStats.BonusAbilityType.Enrage:
			atlas_texture.set_region(ENRAGE)
		EnemyStats.BonusAbilityType.Endure:
			atlas_texture.set_region(ENDURE)
		EnemyStats.BonusAbilityType.Regenerate:
			atlas_texture.set_region(REGENERATE)
		_:
			self.hide()
	sprite_2d.texture = atlas_texture

func refresh():
	if enemy:
		bonus_ability = enemy.enemy_stats.bonus_ability
		bonus_ability_value = enemy.enemy_stats.bonus_ability_mod
		change_image()

func _process(delta: float) -> void:
	refresh()

func _ready() -> void:
	# StyleBox so we can change bg color nicely
	var sb := StyleBoxFlat.new()
	sb.bg_color = normal_bg
	sb.corner_radius_top_left = 12
	sb.corner_radius_top_right = 12
	sb.corner_radius_bottom_left = 12
	sb.corner_radius_bottom_right = 12
	add_theme_stylebox_override("panel", sb)

	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)
	gui_input.connect(_on_gui_input)
	refresh()

func _on_mouse_enter() -> void:
	_highlight(true)
	_show_tooltip()

func _on_mouse_exit() -> void:
	_highlight(false)
	if tooltip:
		tooltip.hide_tooltip()

func _on_gui_input(event: InputEvent) -> void:
	# Optional: keep tooltip following mouse while still inside the panel
	if tooltip and tooltip.visible and event is InputEventMouseMotion and use_mouse_follow_tooltip:
		tooltip.show_at_mouse()

func _highlight(hovering: bool) -> void:
	var sb := get_theme_stylebox("panel") as StyleBoxFlat
	if not sb:
		return
	if _tween and _tween.is_running():
		_tween.kill()

	_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var from_col := sb.bg_color
	var to_col := hover_bg if hovering else normal_bg
	_tween.tween_property(sb, "bg_color", to_col, tween_time)

func _show_tooltip() -> void:
	if not tooltip or not enemy:
		return
	
	refresh()
	
	enemy.enemy_stats.description
	
	var text = ""
	var ability_mod = str(int(bonus_ability_value))

	match bonus_ability:
		EnemyStats.BonusAbilityType.None:
			text = text + "[color=LIGHT_GRAY]This creature has no defining abilities.[/color]"
		EnemyStats.BonusAbilityType.Block:
			text = text + "[color=SLATE_GRAY]Block " + ability_mod + "[/color]: "
			text = text + "\nThis creature is able to block up to " + ability_mod + " additional damage."
		EnemyStats.BonusAbilityType.Dodge:
			text = text + "[color=LIGHT_GREEN]Dodge " + ability_mod + "[/color]: "
			text = text + "\nThis creature causes subsequent target hits to be much harder."
		EnemyStats.BonusAbilityType.Crush:
			text = text + "[color=DARK_SLATE_GRAY]Crush " + ability_mod + "[/color]: "
			text = text + "\nThis creature pierces up to " + ability_mod + " block value when it attacks."
		EnemyStats.BonusAbilityType.Enrage:
			text = text + "[color=RED]Enrage " + ability_mod + "[/color]: "
			text = text + "\nEvery 2 damage this creature takes, it gains " + ability_mod + " permanent damage."
		EnemyStats.BonusAbilityType.Endure:
			text = text + "[color=TEAL]Endure " + ability_mod + "[/color]: "
			text = text + "\nThis creature ignores any damage value less than or equal to " + ability_mod + "."
		EnemyStats.BonusAbilityType.Regenerate:
			text = text + "[color=WEB_GREEN]Regenerate " + ability_mod + "[/color]: "
			text = text + "\nIf this creature is still alive at the end of a round, it will regenerate " + ability_mod + " health."
		_:
			pass
	tooltip.set_text(text)

	if use_mouse_follow_tooltip:
		tooltip.show_at_mouse()
	else:
		tooltip.show_at_panel(self)
