extends Control

@onready var timer: Timer = $Timer
@onready var rich_text_label: RichTextLabel = $RichTextLabel

func show_text(bbcode: String):
	rich_text_label.clear()
	rich_text_label.show()
	rich_text_label.bbcode_enabled = true
	rich_text_label.scroll_active = false
	timer.one_shot = true
	timer.wait_time = 0.5
	
	var new_text = "[font_size=24][shake rate=20.0 level=5 connected=1]" + bbcode + "[/shake][/font_size]"
	rich_text_label.append_text(new_text)
	timer.start()

func _process(delta: float) -> void:
	if timer.is_stopped():
		rich_text_label.hide()
