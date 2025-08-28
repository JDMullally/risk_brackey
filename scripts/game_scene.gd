extends Node2D
class_name GameManager

 #- Monster shows it's damage Intent that turn
 #- Gambit Window appears where the Player can select how many successes/failures
   #- Gambit Window gives a boon and bane (example 2 addition attack attempts but the boss gains Enrage 2)
 #- Player Plays Mini-Game
 #- Mini-Game ends and the values are collected.
 #- Damage is dealt to either enemy and player.
 #- Turn restarts

@onready var enemy: Enemy = $Enemy
@onready var player: Player = %PlayerModel
@onready var monster_damage_intent: Node2D = $"Bottom Screen/MonsterDamageIntent"
@onready var player_health: PlayerHealthBar = $"Bottom Screen/PlayerHealth"
@onready var monster_health: Node2D = $"Bottom Screen/MonsterHealth"
@onready var mini_game: MiniGame = $"Bottom Screen/MiniGame"
@onready var transition_timer: Timer = $TransitionTimer
@onready var camera_2d: Camera2D = $Camera2D

var mini_game_state : MiniGameState = MiniGameState.Setup
var monster_damage : int

var current_successful_attacks : int = 0
var current_successful_blocks : int = 0

enum MiniGameState {Setup, EnemyIntent, Gambit, Game, AwaitGame, DealDamage}

func run_mini_game():
	# print(MiniGameState.keys()[mini_game_state])
	if transition_timer.is_stopped():
		match mini_game_state:
			MiniGameState.Setup:
				setup()
			MiniGameState.EnemyIntent:
				get_monster_damage_intent()
			MiniGameState.Gambit:
				gambit()
			MiniGameState.Game:
				start_game()
			MiniGameState.DealDamage:
				print("hi!")
				deal_damage(current_successful_attacks, current_successful_blocks)
			_:
				pass

func _process(delta: float) -> void:
	run_mini_game()

func change_mini_game_state(new_state : MiniGameState):
	mini_game_state = new_state
	transition_timer.start()

func _ready() -> void:
	GameRules.monster_ready.connect(monster_ready)
	GameRules.mini_game_finished.connect(mini_game_done)
	transition_timer.wait_time = 0.4
	transition_timer.one_shot = true

func setup():
	GameRules.check_monster_ready.emit()
	
func monster_ready():
	change_mini_game_state(MiniGameState.EnemyIntent)

func gambit():
	change_mini_game_state(MiniGameState.Game)

func start_game():
	GameRules.start_minigame.emit(2, 1)
	change_mini_game_state(MiniGameState.AwaitGame)

func mini_game_done(sucessful_attacks, sucessful_blocks):
	current_successful_attacks = sucessful_attacks
	current_successful_blocks = sucessful_blocks
	change_mini_game_state(MiniGameState.DealDamage)

func deal_damage(successful_attacks : int, successful_blocks : int):
	print(successful_attacks, successful_blocks)
	player.stats.add_blocks(successful_blocks)
	player.deal_damage(successful_attacks)
	GameRules.update_hp.emit()
	enemy.deal_damage(monster_damage)
	GameRules.update_hp.emit()
	change_mini_game_state(MiniGameState.Setup)

func get_monster_damage_intent():
	monster_damage = enemy.calculate_damage()
	monster_damage_intent.hide_monster_damage_intent()
	monster_damage_intent.recieve_monster_damage_intent(monster_damage)
	change_mini_game_state(MiniGameState.Gambit)
