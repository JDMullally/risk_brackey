extends Node2D
class_name GameManager

const GAME_WIN = "res://scenes/game_win.tscn"
const GAME_OVER = "res://scenes/game_over.tscn"

enum MacroGameState {Transition, PlayMiniGame, GameOver, Win}
enum MiniGameState {Setup, EnemyIntent, DoGambit, Wait, Game, PlayerTurn, MonsterTurn}

@onready var enemy: Enemy = $Enemy
@onready var player: Player = %Player
@onready var monster_damage_intent: Node2D = $"Bottom Screen/MonsterDamageIntent"
@onready var player_health: PlayerHealthBar = $"Bottom Screen/PlayerHealth"
@onready var monster_health: Node2D = $"Bottom Screen/MonsterHealth"
@onready var mini_game: MiniGame = $"Bottom Screen/MiniGame"
@onready var transition_timer: Timer = $TransitionTimer
@onready var gambit_window: Gambit = $"Bottom Screen/Gambit"

@onready var macro_game_state : MacroGameState = MacroGameState.Transition
@onready var mini_game_state : MiniGameState = MiniGameState.Setup
@onready var encounter_number : int = 1
@onready var monster_damage : int
@onready var current_successful_attacks : int = 0
@onready var current_successful_blocks : int = 0
@onready var current_gambit : GameRules.GambitType = GameRules.GambitType.None


func _ready() -> void:
	
	encounter_number = 1
	macro_game_state = MacroGameState.PlayMiniGame
	GameRules.player_attack_over.connect(func change_monster_turn(): change_mini_game_state(MiniGameState.MonsterTurn))
	GameRules.monster_attack_over.connect(func change_monster_turn(): change_mini_game_state(MiniGameState.Setup))
	GameRules.gambit_finished.connect(start_game)
	GameRules.monster_ready.connect(monster_ready)
	GameRules.mini_game_finished.connect(mini_game_done)
	GameRules.game_state_win.connect(func(): change_macro_game_state(MacroGameState.Win))
	transition_timer.wait_time = 0.4
	transition_timer.one_shot = true

func _process(delta: float) -> void:
	match macro_game_state:
		MacroGameState.PlayMiniGame:
			run_mini_game()
		MacroGameState.GameOver:
			if player.ready_for_game_over_screen():
				get_tree().change_scene_to_file(GAME_OVER)
		MacroGameState.Win:
			get_tree().change_scene_to_file(GAME_WIN)
			
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


func start_game(attack, block, gambit):
	current_gambit = gambit
	match current_gambit:
		GameRules.GambitType.Defense:
			var bonus_defends = 2
			GameRules.start_minigame.emit(block + bonus_defends, attack)
		GameRules.GambitType.Strength:
			var bonus_attacks = 2
			GameRules.start_minigame.emit(block, attack + bonus_attacks)
		GameRules.GambitType.Blight:
			GameRules.start_minigame.emit(block, attack)
		GameRules.GambitType.Rewrite:
			GameRules.start_minigame.emit(block, attack)
		_:
			GameRules.start_minigame.emit(block, attack)
	change_mini_game_state(MiniGameState.Wait)
	

func mini_game_done(sucessful_attacks, sucessful_blocks):
	current_successful_attacks = sucessful_attacks
	current_successful_blocks = sucessful_blocks
	change_mini_game_state(MiniGameState.PlayerTurn)

func player_turn(successful_attacks : int, successful_blocks : int):
	player.add_blocks(successful_blocks)
	match current_gambit:
		GameRules.GambitType.Reflect:
			player.deal_damage(successful_attacks)
			player.take_damage(successful_attacks, 0)
			if player.is_dead():
				change_macro_game_state(MacroGameState.GameOver)
			change_mini_game_state(MiniGameState.MonsterTurn)
		GameRules.GambitType.Lifesteal:
			player.deal_damage(successful_attacks)
			player.heal(successful_attacks)
			change_mini_game_state(MiniGameState.Wait)
		_:
			player.deal_damage(successful_attacks)
			change_mini_game_state(MiniGameState.Wait)
	GameRules.update_hp.emit()

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
