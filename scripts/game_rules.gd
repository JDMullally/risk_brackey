extends Node

enum CharType {Monster, Hero}

enum GambitType {Blight, Strength, Defense, Reflect, Health, Rewrite, None}

signal start_minigame(blocks : int, attacks : int)
signal mini_game_finished(successful_attack : int, successful_block : int)

signal spin_the_wheel

signal deal_damage_to_player(damage : int, block_damage : int)
signal deal_damage_to_monster(damage : int)

signal select_gambit(gambit : GambitType)
 
signal send_dodge_value(dodge_value : float)

signal start_gambit(points : int)
signal gambit_finished(damage, block)

signal player_attack_over
signal monster_attack_over

signal switch_monster(turn : int)

signal check_monster_ready
signal monster_ready
signal monster_dead

signal update_hp
