extends Node2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var rich_text_label: RichTextLabel = $RichTextLabel

func _ready() -> void:
	hide_monster_damage_intent()

func recieve_monster_damage_intent(damage : int):
	self.show()
	rich_text_label.bbcode_enabled = true
	rich_text_label.append_text("[center][color=Red]" + str(damage) + "[/color][/center]")

func hide_monster_damage_intent():
	rich_text_label.clear()
	self.hide()
