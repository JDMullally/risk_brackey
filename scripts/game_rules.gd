extends Node

enum CharType {Monster, Hero}

signal start_minigame(blocks : int, attacks : int)

signal deal_damage_to_player(damage : int, block_damage : int)
signal deal_damage_to_monster(damage : int)

signal request_player_health
