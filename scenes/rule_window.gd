extends Panel


func _ready():
	self.modulate.a = 1.0
	self.hide()

func _on_button_pressed() -> void:
	self.hide()
