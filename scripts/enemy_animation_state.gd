extends Node
class_name EnemyAnimationState

enum State { IDLE, RUNNING, ATTACKING, HIT, DYING, DEAD }

@export var idle_anim: StringName = "idle"
@export var run_anim: StringName = "move"
@export var hit_anim: StringName = "hit"
@export var hit_no_damage_anim: StringName = "hit_no_damage"
@export var dying_anim: StringName = "dying"
@export var dead_anim: StringName = "dead"
@export var attack_anim: StringName = "attack"

var enemy: Enemy
var anim: AnimatedSprite2D
var state: State = State.IDLE
var _pending_run_stop := false
var _current_attack: StringName = ""

func init(e: Enemy) -> void:
	enemy = e
	anim = e.animated_sprite_2d

	_play(idle_anim)
	state = State.IDLE

	var finish_cb := Callable(self, "_on_animation_finished")
	if anim.has_signal("animation_finished") and not anim.is_connected("animation_finished", finish_cb):
		anim.connect("animation_finished", finish_cb)
	var loop_cb := Callable(self, "_on_animation_looped")
	if anim.has_signal("animation_looped") and not anim.is_connected("animation_looped", loop_cb):
		anim.connect("animation_looped", loop_cb)
	else:
		var frame_cb := Callable(self, "_on_frame_changed")
		if anim.has_signal("frame_changed") and not anim.is_connected("frame_changed", frame_cb):
			anim.connect("frame_changed", frame_cb)


func play_hit() -> void:
	if _is_locked(): return
	if _has_anim(hit_anim):
		state = State.HIT
		_play(hit_anim)

func play_hit_no_damage() -> void:
	if _is_locked(): return
	if _has_anim(hit_no_damage_anim):
		state = State.HIT
		_play(hit_no_damage_anim)

func play_dying() -> void:
	if state == State.DYING or state == State.DEAD: return
	if _has_anim(dying_anim):
		state = State.DYING
		_play(dying_anim)
	else:
		_go_dead()

func play_attack() -> void:
	if _is_locked(): return
	if _has_anim(attack_anim):
		state = State.ATTACKING
		_play(attack_anim)

func start_running() -> void:
	if _is_locked(): return
	_pending_run_stop = false
	state = State.RUNNING
	_play(run_anim)

func stop_running_after_loop() -> void:
	if state == State.RUNNING:
		_pending_run_stop = true

func _on_animation_finished() -> void:
	match state:
		State.DYING:
			_go_dead()
		State.ATTACKING, State.HIT:
			_go_idle_if_not_locked()
		_:
			pass

func _on_animation_looped() -> void:
	if state == State.RUNNING and _pending_run_stop:
		_pending_run_stop = false
		_go_idle_if_not_locked()

func _on_frame_changed() -> void:
	if state == State.RUNNING and _pending_run_stop and anim.frame == 0:
		_pending_run_stop = false
		_go_idle_if_not_locked()

func _go_dead() -> void:
	state = State.DEAD
	if _has_anim(dead_anim):
		_play(dead_anim)
	else:
		_play(idle_anim) 

func _go_idle_if_not_locked() -> void:
	if _is_locked(): 
		return
	state = State.IDLE
	_play(idle_anim)

func _is_locked() -> bool:
	return state == State.DYING or state == State.DEAD

func _has_anim(name: StringName) -> bool:
	return anim.sprite_frames != null and anim.sprite_frames.has_animation(name)

func _play(name: StringName) -> void:
	if _has_anim(name):
		anim.play(name)
