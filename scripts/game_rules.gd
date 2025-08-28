extends Node

enum CharType {Monster, Hero}

signal start_minigame(blocks : int, attacks : int)
signal mini_game_finished(successful_attack : int, successful_block : int)
signal deal_damage_to_player(damage : int, block_damage : int)
signal deal_damage_to_monster(damage : int)
signal check_monster_ready
signal monster_ready

signal update_hp
