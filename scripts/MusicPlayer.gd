extends Node

@onready var player: AudioStreamPlayer = %PlayerA

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

var songs: Array = []
var current_index: int = 0


func _ready() -> void:
	songs = [
		BATTLEFORGE, ELVEN_BATTLE, MYSTIC_MELEE, SHADOWSTRIKE, PALADIN_S_FURY,
		DARK_DOMINION, DRAGON_S_ROAR, WARLOCK_S_WRATH, THUNDEROUS_ROAR,
		SORCERER_S_SURGE, KNIGHT_S_VALOR, MYSTIC_MAYHEM, WARRIOR_OF_THE_WEST
	]
	songs.shuffle()
	player.finished.connect(play_new_song)
	# player.volume_db = silent_db
	player.bus = "Music"
	play_new_song()

func play_new_song():
	var song : AudioStream = songs[current_index]
	current_index = (current_index + 1) % len(songs)
	player.stream = song
	player.play()
