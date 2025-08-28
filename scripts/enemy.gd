extends Node2D
class_name Enemy

@export var enemy_stats : EnemyStats
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var current_animation : String = "idle"
var turn_damage : int


func _ready():
	GameRules.check_monster_ready.connect(check_monster_ready)
	animated_sprite_2d.play(current_animation)
	setup()

func check_monster_ready():
	GameRules.monster_ready.emit()

func reset_to_idle():
	if current_animation == "idle":
		pass
	elif animated_sprite_2d.frame == animated_sprite_2d.sprite_frames.get_frame_count(current_animation)- 1:
		current_animation = "idle"
		animated_sprite_2d.play(current_animation)

func setup():
	if !GameRules.deal_damage_to_monster.is_connected(take_damage):
		GameRules.deal_damage_to_monster.connect(take_damage)
	enemy_stats.reset()
	setup_sprite()
	send_dodge_value()

func calculate_damage():
	var total_damage : int
	match enemy_stats.bonus_ability:
		enemy_stats.BonusAbilityType.Enrage:
			total_damage = enemy_stats.base_calculated_damage() + enemy_stats._temp_ability_mod
		_:
			total_damage = enemy_stats.base_calculated_damage()
	return total_damage

func send_dodge_value():
	pass

func deal_damage(turn_damage):
	match enemy_stats.bonus_ability:
		enemy_stats.BonusAbilityType.Crush:
			GameRules.deal_damage_to_player.emit(turn_damage, enemy_stats.bonus_ability_mod)
		_:
			GameRules.deal_damage_to_player.emit(turn_damage, 0)
	change_animation("attack")

func setup_sprite():
	animated_sprite_2d.sprite_frames = enemy_stats.enemy_sprite
	current_animation = "idle"
	if enemy_stats.enemy_sprite_flipped:
		animated_sprite_2d.scale = Vector2(-1, 1)
	else:
		animated_sprite_2d.scale = Vector2(1, 1)
	animated_sprite_2d.play(current_animation)

func change_animation(new_animation : String):
	current_animation = new_animation
	animated_sprite_2d.play(new_animation)

func _process(delta: float) -> void:
	reset_to_idle()

func enemy_dead():
	return enemy_stats.is_dead()

func take_damage(damage : int):
	var total_damage_taken : int
	match enemy_stats.bonus_ability:
		enemy_stats.BonusAbilityType.Endure:
			if damage > enemy_stats.bonus_ability_mod:
				total_damage_taken = damage
			else:
				total_damage_taken = 0
		enemy_stats.BonusAbilityType.Block:
			var new_damage = clampi(damage - enemy_stats.bonus_ability_mod, 0, damage)
			total_damage_taken = new_damage
		enemy_stats.BonusAbilityType.Enrage:
			var enrage_amount = ceili(float(damage)/2.0) * enemy_stats.bonus_ability_mod
			enemy_stats.increment_temp_ability_mod(enrage_amount)
			total_damage_taken = damage
		_:
			total_damage_taken = damage
	
	enemy_stats.take_damage(total_damage_taken)
	if total_damage_taken > 0:
		change_animation("hit")
