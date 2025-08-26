extends Node2D
const HEARTS = preload("res://art/sprites/hearts/hearts.png")
@export var character: Player

func _ready() -> void:
	fill_health_bar()

func fill_health_bar():
	var current_health = character.stats.get_current_health()
	var max_health = character.stats.max_hp
	for i in range(max_health):
		var new_sprite = Sprite2D.new()
		new_sprite.scale = Vector2(2.0, 2.0)
		new_sprite.texture = full_heart()
		new_sprite.position.x = i * 32 + 20
		self.add_child(new_sprite)

func empty_heart() -> AtlasTexture:
	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = HEARTS
	atlas_texture.region.position = Vector2(16.0, 0.0)
	atlas_texture.region.size = Vector2(16.0, 16.0)
	return atlas_texture
	
func full_heart() -> AtlasTexture:
	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = HEARTS
	atlas_texture.region.position = Vector2(0.0, 0.0)
	atlas_texture.region.size = Vector2(16.0, 16.0)
	return atlas_texture
