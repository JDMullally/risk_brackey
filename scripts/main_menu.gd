extends Control
class_name MainMenu

const GAME_SCENE = "res://scenes/game_scene.tscn"
var _settings: AudioSettingsPopup = null

@onready var title: RichTextLabel = $RichTextLabel

@onready var mouse_over: AudioStreamPlayer = $MouseOver
@onready var click: AudioStreamPlayer = $Click
@onready var music: AudioStreamPlayer = $Music
@onready var start_game: Button = $VBoxContainer/StartGame
@onready var settings: Button = $VBoxContainer/Settings
@onready var rule_window: Panel = $RuleWindow


func _ready() -> void:
	music.finished.connect(func(): music.play())
	
func set_title():
	title.clear()
	title.append_text("[font_size=96][center][wave]Knight's Gambit[/wave][/center][/font_size]")

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_settings_pressed() -> void:
	if _settings and is_instance_valid(_settings):
		_settings.show()
		_settings.grab_focus()
		return
	_settings = AudioSettingsPopup.new()
	_settings.name = "AudioSettingsPopup"
	add_child(_settings)
	_settings.set_anchors_preset(Control.PRESET_FULL_RECT)
	_settings.show()

func play_mouse_over_sound():
	if !mouse_over.playing:
		mouse_over.play()

func _how_to_play_pressed():
	rule_window.show()
	

func close_rule_window() -> void:
	rule_window.hide()
