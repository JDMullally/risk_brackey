extends Node2D
class_name HealthBar
const HEARTS = preload("res://art/sprites/hearts/hearts.png")
var last_heart_position : Vector2

func clear_all_hearts():
	for child in self.get_children():
		child.queue_free()

func calculate_heart_position(num : int):
	var y: int = 0
	var x = (num % 8) * 32
	if num >= 8:
		y = (num / 8) * 32
	return Vector2(x, y)

func fill_heath_bar():
	pass

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

func fill_health_bar(current_health : int, max_health : int):
	for i in range(current_health):
		var new_sprite = Sprite2D.new()
		new_sprite.scale = Vector2(2.0, 2.0)
		new_sprite.texture = full_heart()
		new_sprite.position = calculate_heart_position(i)
		self.add_child(new_sprite)
		
	for i in range(current_health, max_health):
		var new_sprite = Sprite2D.new()
		new_sprite.scale = Vector2(2.0, 2.0)
		new_sprite.texture = empty_heart()
		new_sprite.position = calculate_heart_position(i)
		self.add_child(new_sprite)
