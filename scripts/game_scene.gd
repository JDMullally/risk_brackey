extends Node2D
class_name GameManager

#                         ROUND DESCRIPTION                                    #
 #- Monster shows it's damage Intent that turn
 #- Gambit Window appears where the Player can select how many successes/failures
   #- Gambit Window gives a boon and bane (example 2 addition attack attempts but the boss gains Enrage 2)
 #- Player Plays Mini-Game
 #- Mini-Game ends and the values are collected.
 #- Damage is dealt to either enemy and player.
 #- Turn restarts
# ##############################################################################


@onready var enemy: Enemy = $Enemy
@onready var player: Player = %Player
@onready var monster_damage_intent: Node2D = $"Bottom Screen/MonsterDamageIntent"
@onready var player_health: PlayerHealthBar = $"Bottom Screen/PlayerHealth"
@onready var monster_health: Node2D = $"Bottom Screen/MonsterHealth"
@onready var mini_game: MiniGame = $"Bottom Screen/MiniGame"
@onready var transition_timer: Timer = $TransitionTimer
@onready var camera_2d: Camera2D = $Camera2D
@onready var gambit_window: Gambit = $"Bottom Screen/Gambit"

var macro_game_state : MacroGameState = MacroGameState.Transition
var mini_game_state : MiniGameState = MiniGameState.Setup
var monster_damage : int
var encounter_number : int = 1
var current_successful_attacks : int = 0
var current_successful_blocks : int = 0

enum MacroGameState {Transition, PlayMiniGame, GameOver, Win}

enum MiniGameState {Setup, EnemyIntent, DoGambit, Wait, Game, PlayerTurn, MonsterTurn}

func _ready() -> void:
	encounter_number = 1
	macro_game_state = MacroGameState.PlayMiniGame
	GameRules.player_attack_over.connect(func change_monster_turn(): change_mini_game_state(MiniGameState.MonsterTurn))
	GameRules.monster_attack_over.connect(func change_monster_turn(): change_mini_game_state(MiniGameState.Setup))
	GameRules.gambit_finished.connect(start_game)
	GameRules.monster_ready.connect(monster_ready)
	GameRules.mini_game_finished.connect(mini_game_done)
	transition_timer.wait_time = 0.4
	transition_timer.one_shot = true

func _process(delta: float) -> void:
	match macro_game_state:
		MacroGameState.PlayMiniGame:
			run_mini_game()
		MacroGameState.GameOver:
			get_tree().quit()
		MacroGameState.Win:
			get_tree().quit()
			
	# print(MiniGameState.keys()[mini_game_state])

func run_mini_game():
	if transition_timer.is_stopped():
		match mini_game_state:
			MiniGameState.Setup:
				setup()
			MiniGameState.EnemyIntent:
				get_monster_damage_intent()
			MiniGameState.DoGambit:
				gambit()
			MiniGameState.PlayerTurn:
				player_turn(current_successful_attacks, current_successful_blocks)
			MiniGameState.MonsterTurn:
				monster_turn()
			_:
				pass


func change_macro_game_state(new_state : MacroGameState):
	macro_game_state = new_state

func change_mini_game_state(new_state : MiniGameState):
	mini_game_state = new_state
	transition_timer.start()

func setup():
	monster_ready()
	
func monster_ready():
	change_macro_game_state(MacroGameState.PlayMiniGame)
	change_mini_game_state(MiniGameState.EnemyIntent)

func gambit():
	GameRules.start_gambit.emit(player.stats.num_actions)
	change_mini_game_state(MiniGameState.Wait)

func start_game(attack, block):
	GameRules.start_minigame.emit(block, attack)
	change_mini_game_state(MiniGameState.Wait)

func mini_game_done(sucessful_attacks, sucessful_blocks):
	current_successful_attacks = sucessful_attacks
	current_successful_blocks = sucessful_blocks
	change_mini_game_state(MiniGameState.PlayerTurn)

func player_turn(successful_attacks : int, successful_blocks : int):
	player.add_blocks(successful_blocks)
	player.deal_damage(successful_attacks)
	GameRules.update_hp.emit()
	change_mini_game_state(MiniGameState.Wait)

func monster_turn():
	if enemy.enemy_dead():
		player.heal_and_increase_health()
		if encounter_number % 3 == 0:
			player.increase_actions()
		change_mini_game_state(MiniGameState.Setup)
		change_macro_game_state(MacroGameState.Transition)
		encounter_number += 1
		enemy.switch_monster(encounter_number)
	else:
		enemy.deal_damage(monster_damage)
		GameRules.update_hp.emit()
		if player.is_dead():
			change_macro_game_state(MacroGameState.GameOver)
		change_mini_game_state(MiniGameState.Setup)

func get_monster_damage_intent():
	enemy.heal_if_able()
	GameRules.update_hp.emit()
	enemy.send_dodge_value()
	monster_damage = enemy.calculate_damage()
	monster_damage_intent.hide_monster_damage_intent()
	monster_damage_intent.recieve_monster_damage_intent(monster_damage)
	change_mini_game_state(MiniGameState.DoGambit)
