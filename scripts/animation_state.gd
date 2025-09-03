extends Node
class_name PlayerAnimationState

enum State { IDLE, RUNNING, ATTACKING, HIT, DYING, DEAD }


@onready var attack_animations : Array = ["attack_1", "attack_2", "attack_3"]
@onready var idle : String = "idle"
@onready var run : String = "running"
@onready var dying : String = "dying"
@onready var dead : String = "dead"
@onready var hit : String = "hit"

var player: Player
var anim: AnimatedSprite2D
var hit_timer: Timer

var state: State = State.IDLE
var _pending_run_stop: bool = false
var _current_attack: StringName = ""


func init(p: Player) -> void:
	player = p
	anim = p
	hit_timer = Timer.new()
	hit_timer.one_shot = true
	hit_timer.wait_time = .5

	_play(idle)
	state = State.IDLE

	if not anim.animation_finished.is_connected(_on_animation_finished):
		anim.animation_finished.connect(_on_animation_finished)
	if not anim.animation_looped.is_connected(_on_animation_looped):
		anim.animation_looped.connect(_on_animation_looped)

	if hit_timer and not hit_timer.timeout.is_connected(_on_hit_timeout):
		hit_timer.timeout.connect(_on_hit_timeout)


func play_attack(damage : int) -> void:
	var name = attack_animations[randi_range(0, 2)]
	
	if _is_locked():
		return
	if not _has_anim(name):
		push_warning("Missing attack animation: %s" % name)
		return
	state = State.ATTACKING
	_current_attack = name
	_play(name)

func play_hit() -> void:
	if _is_locked():
		return
	if _has_anim(hit):
		state = State.HIT
		_play(hit)

func is_current_animation_dead() -> bool:
	return state == State.DEAD

func play_dying() -> void:
	if state == State.DEAD or state == State.DYING:
		return
	if _has_anim(dying):
		state = State.DYING
		_play(dying)
	else:
		_go_dead()

func start_running() -> void:
	if _is_locked():
		return
	_pending_run_stop = false
	state = State.RUNNING
	_play(run)

func stop_running_after_loop() -> void:
	if state == State.RUNNING:
		_pending_run_stop = true

func _on_animation_finished() -> void:
	match state:
		State.DYING:
			_go_dead()
		State.ATTACKING:
			_go_idle_if_not_locked()
			GameRules.player_attack_over.emit()
		State.HIT:
			if hit_timer == null or hit_timer.is_stopped():
				_go_idle_if_not_locked()
		_:
			pass

func _on_animation_looped() -> void:
	if state == State.RUNNING and _pending_run_stop:
		_pending_run_stop = false
		_go_idle_if_not_locked()

func _on_hit_timeout() -> void:
	if state == State.HIT:
		_go_idle_if_not_locked()

func _go_dead() -> void:
	state = State.DEAD
	if _has_anim(dead):
		_play(dead)
	else:
		_play(idle)

func _go_idle_if_not_locked() -> void:
	if _is_locked():
		return
	state = State.IDLE
	_play(idle)

func _is_locked() -> bool:
	return state == State.DYING or state == State.DEAD

func _has_anim(name: StringName) -> bool:
	return anim.sprite_frames != null and anim.sprite_frames.has_animation(name)

func _play(name: StringName) -> void:
	if _has_anim(name):
		anim.play(name)
