extends Panel

const MAIN_MENU = "res://scenes/main_menu.tscn"
const GAME_SCENE = "res://scenes/game_scene.tscn"
@onready var mouse_over: AudioStreamPlayer = $MouseOver
@onready var overlay: Panel = $Panel


func _ready() -> void:
	overlay.show()
	overlay.modulate.a = 1
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_out_and_hide()

func fade_out_and_hide() -> void:
	var tw := create_tween()
	tw.tween_property(overlay, "modulate:a", 0.0, 3.0)
	tw.finished.connect(func(): overlay.hide())

func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU)

func play_mouse_over_sound():
	if !mouse_over.playing:
		mouse_over.play()
