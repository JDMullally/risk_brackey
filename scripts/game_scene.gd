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

var gamestate : State = State.Setup
var monster_damage : int

enum State {Setup, EnemyIntent, Gambit, Game, AwaitGame, DealDamage}

func _ready() -> void:
	GameRules.mini_game_finished.connect(mini_game_done)
	
func setup():
	GameRules.check_monster_ready()
	
func monster_ready():
	gamestate = State.EnemyIntent

func gambit():
	gamestate = State.Game

func start_game():
	GameRules.start_minigame.emit()
	gamestate = State.AwaitGame

func mini_game_done():
	gamestate = State.DealDamage

func deal_damage(successful_attacks : int, successful_blocks : int):
	player.stats.add_blocks(successful_blocks)
	enemy.take_damage(successful_attacks)
	player.take_damage(monster_damage)
	gamestate = State.Setup

func get_monster_damage_intent():
	monster_damage = enemy.calculate_damage()
	monster_damage_intent.recieve_monster_damage_intent(monster_damage)
	gamestate = State.Gambit
