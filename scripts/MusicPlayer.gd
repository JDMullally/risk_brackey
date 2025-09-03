extends Node

@onready var _player_a: AudioStreamPlayer = %PlayerA
@onready var _player_b: AudioStreamPlayer = %PlayerB

const BATTLEFORGE = preload("res://art/music/1 - Heavy Combat - Battleforge.wav")
const ELVEN_BATTLE = preload("res://art/music/2 - Heavy Combat - Elven Battle.wav")
const MYSTIC_MELEE = preload("res://art/music/3 - Heavy Combat - Mystic Melee.wav")
const SHADOWSTRIKE = preload("res://art/music/4 - Heavy Combat - Shadowstrike.wav")
const PALADIN_S_FURY = preload("res://art/music/5 - Heavy Combat - Paladin's Fury.wav")
const DARK_DOMINION = preload("res://art/music/6 - Heavy Combat - Dark Dominion.wav")
const DRAGON_S_ROAR = preload("res://art/music/7 - Heavy Combat - Dragon's Roar.wav")
const WARLOCK_S_WRATH = preload("res://art/music/8 - Heavy Combat - Warlock's Wrath.wav")
const THUNDEROUS_ROAR = preload("res://art/music/9 - Heavy Combat - Thunderous Roar.wav")
const SORCERER_S_SURGE = preload("res://art/music/10 - Heavy Combat - Sorcerer's Surge.wav")
const KNIGHT_S_VALOR = preload("res://art/music/11 - Heavy Combat - Knight's Valor.wav")
const MYSTIC_MAYHEM = preload("res://art/music/12 - Heavy Combat - Mystic Mayhem.wav")
const WARRIOR_OF_THE_WEST = preload("res://art/music/13 - Heavy Combat - Warrior of the West.wav")

@export var fade_time: float = 2.0
@export var silent_db: float = -40.0

var _songs: Array = []
var _current_index: int = 0
var _use_a: bool = true
var _crossfade_timer: Timer
var _is_crossfading: bool = false
var _crossfade_refcount: int = 0

func _ready() -> void:
	_songs = [
		BATTLEFORGE, ELVEN_BATTLE, MYSTIC_MELEE, SHADOWSTRIKE, PALADIN_S_FURY,
		DARK_DOMINION, DRAGON_S_ROAR, WARLOCK_S_WRATH, THUNDEROUS_ROAR,
		SORCERER_S_SURGE, KNIGHT_S_VALOR, MYSTIC_MAYHEM, WARRIOR_OF_THE_WEST
	]
	_player_a.finished.connect(_on_finished_a)
	_player_b.finished.connect(_on_finished_b)
	_player_a.volume_db = silent_db
	_player_b.volume_db = silent_db
	_player_a.bus = "Music"
	_player_b.bus = "Music"
	_crossfade_timer = Timer.new()
	_crossfade_timer.one_shot = true
	add_child(_crossfade_timer)
	_crossfade_timer.timeout.connect(_on_crossfade_time)
	_play_index(_current_index)

func _process(_delta: float) -> void:
	if not _is_crossfading:
		_ensure_single_player()

func _play_index(index: int) -> void:
	if _songs.is_empty():
		return
	var playlist_size: int = _songs.size()
	_current_index = (index % playlist_size + playlist_size) % playlist_size
	var next_stream: AudioStream = _songs[_current_index]
	var active: AudioStreamPlayer = _player_a if _use_a else _player_b
	var idle: AudioStreamPlayer = _player_b if _use_a else _player_a
	idle.stop()
	idle.stream = next_stream
	idle.volume_db = silent_db
	idle.play()
	_start_crossfade(idle, active)
	_use_a = not _use_a
	_schedule_crossfade_for(idle)

func _start_crossfade(fade_in_player: AudioStreamPlayer, fade_out_player: AudioStreamPlayer) -> void:
	_is_crossfading = true
	_crossfade_refcount += 1
	var tw: Tween = create_tween()
	tw.set_parallel(true)
	tw.tween_property(fade_in_player, "volume_db", 0.0, fade_time)
	tw.tween_property(fade_out_player, "volume_db", silent_db, fade_time)
	tw.finished.connect(_on_crossfade_tween_finished)

func _on_crossfade_tween_finished() -> void:
	_crossfade_refcount -= 1
	if _crossfade_refcount <= 0:
		_crossfade_refcount = 0
		_is_crossfading = false
		_ensure_single_player()

func _schedule_crossfade_for(player: AudioStreamPlayer) -> void:
	_crossfade_timer.stop()
	var length: float = 0.0
	if player.stream:
		length = player.stream.get_length()
	if length > 0.0 and length > fade_time + 0.1:
		_crossfade_timer.wait_time = max(0.1, length - fade_time)
		_crossfade_timer.start()

func _on_crossfade_time() -> void:
	var next_index: int = (_current_index + 1) % _songs.size()
	_play_index(next_index)

func _on_finished_a() -> void:
	if not _player_b.playing:
		_on_crossfade_time()

func _on_finished_b() -> void:
	if not _player_a.playing:
		_on_crossfade_time()

func _ensure_single_player() -> void:
	var a_playing: bool = _player_a.playing
	var b_playing: bool = _player_b.playing
	if a_playing and b_playing:
		if _player_a.volume_db >= _player_b.volume_db:
			_player_b.stop()
			_player_b.volume_db = silent_db
		else:
			_player_a.stop()
			_player_a.volume_db = silent_db
