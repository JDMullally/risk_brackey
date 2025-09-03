extends RichTextLabel

@onready var timer: Timer = $Timer

func _ready() -> void:
	GameRules.announce.connect(show_announcement_text)

func _process(delta: float) -> void:
	if timer.is_stopped():
		self.hide()

func show_announcement_text(bbcode : String):
	self.clear()
	self.bbcode_enabled = true
	self.scroll_active = false
	timer.start()
	self.show()
	self.append_text(bbcode)
