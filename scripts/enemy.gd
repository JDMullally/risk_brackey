extends Node2D
class_name Enemy

signal slide_in_finished

const SLIME = preload("res://resources/enemy/slime.tres")
const BUSH = preload("res://resources/enemy/bush.tres")
const MUSHROOM = preload("res://resources/enemy/mushroom.tres")

const BAT = preload("res://resources/enemy/bat.tres")
const WARLOCK = preload("res://resources/enemy/warlock.tres")
const SWORD_GHOST = preload("res://resources/enemy/sword_ghost.tres")

const SLASHING_GOLEM = preload("res://resources/enemy/slashing_golem.tres")
const RAMPAGING_GOLEM = preload("res://resources/enemy/rampaging_golem.tres")
const GREATER_GOLEM = preload("res://resources/enemy/greater_golem.tres")

@export var enemy_stats : EnemyStats
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_state: EnemyAnimationState = $AnimationState
@onready var hit: AudioStreamPlayer = $Hit
@onready var block: AudioStreamPlayer = $Block

var base_dodge : float = 1.5
var turn_damage : int
var monster_ready : bool

@export var use_target_80pct: bool = true
@export var target_x_px: float = 1007.0
@export var slide_in_duration: float = 0.9
@export var start_padding_px: float = 200.0

func switch_monster(turn : int):
	var next_stats: EnemyStats = _choose_stats_for_turn(turn)
	if !next_stats:
		return
	enemy_stats = next_stats.duplicate(true)
	enemy_stats.reset()
	GameRules.update_hp.emit()
	monster_ready = false
	setup()
	var y := global_position.y
	var target_x := _compute_target_x()
	var start_x := maxf(get_viewport_rect().size.x + start_padding_px, target_x + start_padding_px)
	global_position = Vector2(start_x, y)
	if animated_sprite_2d.sprite_frames and animated_sprite_2d.sprite_frames.has_animation("idle"):
		animated_sprite_2d.play("idle")
	var t := get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(self, "position", Vector2(target_x, y), slide_in_duration)
	t.finished.connect(func ():
		monster_ready = true
		check_monster_ready()
	)

func _ready():
	monster_ready = true
	GameRules.switch_monster.connect(switch_monster)
	GameRules.check_monster_ready.connect(check_monster_ready)
	GameRules.change_monster_affix.connect(rewrite)
	GameRules.blight_bonus.connect(blight_damage_buff)
	setup()

func rewrite():
	enemy_stats.rewrite_gambit()

func blight_damage_buff():
	enemy_stats.blight_gambit()

func check_monster_ready():
	if monster_ready:
		GameRules.monster_ready.emit()

func setup():
	if !GameRules.deal_damage_to_monster.is_connected(take_damage):
		GameRules.deal_damage_to_monster.connect(take_damage)
	enemy_stats.reset()
	setup_sprite()
	animation_state.init(self)
	send_dodge_value()

func calculate_damage():
	var total_damage : int
	match enemy_stats.bonus_ability:
		enemy_stats.BonusAbilityType.Enrage:
			total_damage = enemy_stats.base_calculated_damage() + enemy_stats._temp_ability_mod
		_:
			total_damage = enemy_stats.base_calculated_damage()
	return total_damage

func heal(value : int):
	enemy_stats.heal(value)

func heal_if_able():
	match enemy_stats.bonus_ability:
			EnemyStats.BonusAbilityType.Regenerate:
				enemy_stats.heal(enemy_stats.bonus_ability_mod)
			_:
				pass

func send_dodge_value():
	match enemy_stats.bonus_ability:
		EnemyStats.BonusAbilityType.Dodge:
			GameRules.send_dodge_value.emit(enemy_stats.bonus_ability_mod)
		_:
			GameRules.send_dodge_value.emit(base_dodge)

func deal_damage(turn_damage):
	match enemy_stats.bonus_ability:
		enemy_stats.BonusAbilityType.Crush:
			GameRules.deal_damage_to_player.emit(turn_damage, enemy_stats.bonus_ability_mod)
		_:
			GameRules.deal_damage_to_player.emit(turn_damage, 0)
	animation_state.play_attack()

func setup_sprite():
	animated_sprite_2d.sprite_frames = enemy_stats.enemy_sprite
	if enemy_stats.enemy_sprite_flipped:
		animated_sprite_2d.scale = Vector2(-enemy_stats.size_multiplier, enemy_stats.size_multiplier)
	else:
		animated_sprite_2d.scale = Vector2(enemy_stats.size_multiplier, enemy_stats.size_multiplier)
	nudge_above_y(animated_sprite_2d, 346, enemy_stats.floating_margin)

func _process(delta: float) -> void:
	send_dodge_value()

func enemy_dead():
	return enemy_stats.is_dead()


func take_damage(damage : int):
	var total_damage_taken : int
	match enemy_stats.bonus_ability:
		enemy_stats.BonusAbilityType.Endure:
			if damage > enemy_stats.bonus_ability_mod:
				total_damage_taken = damage
			else:
				total_damage_taken = 0
		enemy_stats.BonusAbilityType.Block:
			var new_damage = clampi(damage - enemy_stats.bonus_ability_mod, 0, damage)
			total_damage_taken = new_damage
		enemy_stats.BonusAbilityType.Enrage:
			var enrage_amount = ceili(float(damage)/2.0) * enemy_stats.bonus_ability_mod
			enemy_stats.increment_temp_ability_mod(enrage_amount)
			total_damage_taken = damage
		_:
			total_damage_taken = damage
	enemy_stats.take_damage(total_damage_taken)
	if total_damage_taken > 0:
		if enemy_stats.is_dead():
			animation_state.play_dying()
		else:
			animation_state.play_hit()
		hit.play()
	if total_damage_taken <= 0:
		animation_state.play_hit_no_damage()
		block.play()


func get_sprite_screen_aabb(s: AnimatedSprite2D) -> Rect2:
	var frames := s.sprite_frames
	if frames == null:
		return Rect2(s.global_position, Vector2.ZERO)
	var tex: Texture2D = frames.get_frame_texture(s.animation, s.frame)
	if tex == null:
		return Rect2(s.global_position, Vector2.ZERO)
	var size := tex.get_size()
	var tl := Vector2.ZERO
	var tr := Vector2(size.x, 0.0)
	var bl := Vector2(0.0, size.y)
	var br := size
	if s.centered:
		var half := size * 0.5
		tl = -half
		tr = Vector2(half.x, -half.y)
		bl = Vector2(-half.x, half.y)
		br = half
	tl += s.offset
	tr += s.offset
	bl += s.offset
	br += s.offset
	var xform := s.get_global_transform_with_canvas()
	var pts := [xform * tl, xform * tr, xform * bl, xform * br]
	var min_x : int = pts[0].x
	var min_y : int = pts[0].y
	var max_x : int = pts[0].x
	var max_y : int = pts[0].y
	for p in pts:
		min_x = min(min_x, p.x)
		min_y = min(min_y, p.y)
		max_x = max(max_x, p.x)
		max_y = max(max_y, p.y)
	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))

func is_entirely_above_y(s: AnimatedSprite2D, y_line: float = 346.0) -> bool:
	var aabb := get_sprite_screen_aabb(s)
	var bottom := aabb.position.y + aabb.size.y
	return bottom < y_line

func nudge_above_y(s: AnimatedSprite2D, y_line: float = 346.0, margin: float = 0.0) -> void:
	var aabb := get_sprite_screen_aabb(s)
	var bottom := aabb.position.y + aabb.size.y
	if bottom >= y_line - margin:
		var dy := (y_line - margin) - bottom
		s.global_position.y += dy

func _choose_stats_for_turn(turn: int) -> EnemyStats:
	match turn:
		2:
			return BUSH
		3:
			return MUSHROOM
		4:
			return BAT
		5:
			return WARLOCK
		6:
			return SWORD_GHOST
		7:
			return SLASHING_GOLEM
		8:
			return SLASHING_GOLEM
		9:
			return GREATER_GOLEM
		10:
			GameRules.game_state_win.emit()
			return
		_:
			return

func _compute_target_x() -> float:
	var vw := get_viewport_rect().size.x
	return vw * 0.8 if use_target_80pct else target_x_px
