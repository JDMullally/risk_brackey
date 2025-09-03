extends Node

enum CharType {Monster, Hero}

enum GambitType {Blight, Strength, Defense, Reflect, Lifesteal, Rewrite, None}

signal start_minigame(blocks : int, attacks : int)
signal mini_game_finished(successful_attack : int, successful_block : int)

signal spend_attack_token
signal spend_defend_token
signal announce
signal spin_the_wheel

signal game_state_win

signal deal_damage_to_player(damage : int, block_damage : int)
signal deal_damage_to_monster(damage : int)

signal get_gambit(gambit : GambitType)
signal select_actions(points : int)
signal send_dodge_value(dodge_value : float)

signal start_gambit(points : int)
signal gambit_finished(damage: int, block: int, gambit : GambitType)

signal player_attack_over
signal monster_attack_over
signal change_monster_affix
signal blight_bonus

signal switch_monster(turn : int)

signal check_monster_ready
signal monster_ready
signal monster_dead

signal update_hp
