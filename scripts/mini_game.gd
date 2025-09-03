extends Node2D
class_name MiniGame

@export var arrow_speed: float = 180.0
@export var circle_radius: float = 58.0
@export var enemy_dodge: float = 1.5
@export var target_image : Texture

@onready var success: AudioStreamPlayer = $Success
@onready var miss: AudioStreamPlayer = $Miss

@onready var attack_success: Node2D = $AttackSuccess
@onready var defend_success: Node2D = $DefendSuccess
@onready var arrow_sprite: Sprite2D = $Arrow/ArrowSprite
@onready var target_sprite: Sprite2D = $Target/TargetSprite

@onready var transition_timer: Timer = $TransitionTimer
@onready var arrow: Node2D = %Arrow
@onready var target: Node2D = %Target

enum Mode {Attack, Block, End}

var mode : Mode
var blocks : int = 1
var attacks : int = 1
var successful_blocks : int = 0
var successful_attacks : int = 0
var stopped : bool = false

var arrow_angle: float = 0.0
var target_angle: float = 180.0
var target_range: float = 25.0
var direction: float = 1

func _ready() -> void:
	success.volume_db = success.volume_db + 10
	miss.volume_db = miss.volume_db + 10
	GameRules.start_minigame.connect(start)
	GameRules.send_dodge_value.connect(set_game_difficulty)
	stop()

func _process(delta: float) -> void:
	if mode == Mode.End and transition_timer.is_stopped():
		stop()
	elif !stopped and transition_timer.is_stopped():
		play_mini_game(delta)

func stop():
	if !stopped:
		stopped = true
		hide()
		GameRules.mini_game_finished.emit(successful_attacks, successful_blocks)

func start(blocks, attacks):
	self.blocks = blocks
	self.attacks = attacks
	reset_successes()
	transition_mode(Mode.Attack)
	move_target_random()
	show()
	stopped = false

func set_attack_textures():
	arrow_sprite.texture.set_region(Rect2(Vector2(32, 160), Vector2(32, 32)))
	target_sprite.texture.set_region(Rect2(Vector2(0, 0), Vector2(32, 32)))

func set_defend_textures():
	arrow_sprite.texture.set_region(Rect2(Vector2(0, 192), Vector2(32, 32)))
	target_sprite.texture.set_region(Rect2(Vector2(32, 224), Vector2(32, 32)))

func transition_mode(given_mode : Mode):
	match given_mode:
		Mode.Attack:
			if attacks > 0:
				mode = Mode.Attack
				set_attack_textures()
				transition_timer.start()
			else:
				mode = Mode.Block
				set_defend_textures()
				transition_timer.start()
		Mode.Block:
			if blocks > 0:
				mode = Mode.Block
				set_defend_textures()
				transition_timer.start()
			else:
				mode = Mode.End
				transition_timer.start()
		Mode.End:
			mode = Mode.End
			transition_timer.start()

func move_target_random():
	move_target(randf_range(0, 360.0))

func move_target(angle : float):
	target_angle = angle
	target.position = Vector2.RIGHT.rotated(deg_to_rad(angle)) * circle_radius

func play_mini_game(delta: float):
	arrow_angle += direction * arrow_speed * delta
	arrow_angle = fmod(arrow_angle, 360.0)
	
	var arrow_pos = Vector2.RIGHT.rotated(deg_to_rad(arrow_angle)) * circle_radius
	arrow.position = arrow_pos
	
	if Input.is_action_just_pressed("ui_accept"):
		_check_hit()
 
func decrement_failures():
	match mode:
		Mode.Attack:
			attacks -= 1
			GameRules.spend_attack_token.emit()
			if attacks <= 0:
				transition_mode(Mode.Block)
		Mode.Block:
			blocks -= 1
			GameRules.spend_defend_token.emit()
			if blocks <= 0:
				transition_mode(Mode.End)

func reset_successes():
	successful_attacks = 0
	successful_blocks = 0
	defend_success.update_text(successful_blocks)
	attack_success.update_text(successful_attacks)

func increment_success():
	match mode:
		Mode.Attack:
			successful_attacks += 1
			attack_success.update_text(successful_attacks)
		Mode.Block:
			successful_blocks += 1
			defend_success.update_text(successful_blocks)

func _check_hit() -> void:
	var diff = absf(wrapf(arrow_angle - target_angle, -180.0, 180.0))
	if diff <= target_range:
		arrow_speed = arrow_speed * enemy_dodge
		increment_success()
		success.play()
	else:
		miss.play()
		decrement_failures()
		arrow_speed = 180.0
	move_target_random()
	direction = direction * -1

func set_game_difficulty(dodge_value : float):
	enemy_dodge = dodge_value
