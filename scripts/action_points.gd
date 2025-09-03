extends Node2D
class_name BattleCounters

@onready var attack:int = 0
@onready var defend:int = 0
@onready var spent_attack:int = 0
@onready var spent_defend:int = 0

@export var attack_sprite:Texture2D
@export var defend_sprite:Texture2D
@export var spent_attack_sprite:Texture2D
@export var spent_defend_sprite:Texture2D

@export var token_scale:float = 1.0

var _attack_nodes:Array = []
var _defend_nodes:Array = []
var _next_attack_to_spend:int = 0
var _next_defend_to_spend:int = 0

const GAP:float = 8.0

func _ready() -> void:
	GameRules.start_minigame.connect(generate_tokens)
	GameRules.spend_defend_token.connect(func(): spend_defend(1))
	GameRules.spend_attack_token.connect(func(): spend_attack(1))

func generate_tokens(blocks:int, attacks:int) -> void:
	attack = attacks
	defend = blocks
	spent_attack = 0
	spent_defend = 0
	_next_attack_to_spend = 0
	_next_defend_to_spend = 0
	_layout_tokens()
	_build_initial()

func _build_initial() -> void:
	_clear_tokens()
	_attack_nodes.clear()
	_defend_nodes.clear()

	for i in range(attack):
		var s = Sprite2D.new()
		s.texture = attack_sprite
		s.scale = Vector2.ONE * token_scale
		add_child(s)
		_attack_nodes.append(s)

	for i in range(defend):
		var s2 = Sprite2D.new()
		s2.texture = defend_sprite
		s2.scale = Vector2.ONE * token_scale
		add_child(s2)
		_defend_nodes.append(s2)

	_layout_tokens()

func _clear_tokens() -> void:
	for s in _attack_nodes:
		if is_instance_valid(s):
			s.queue_free()
	for s in _defend_nodes:
		if is_instance_valid(s):
			s.queue_free()

func _layout_tokens() -> void:
	var x = 0.0
	var y = position.y  # use node's current y
	for s in _attack_nodes:
		if is_instance_valid(s):
			var w = s.texture.get_width() * s.scale.x if s.texture else 0.0
			s.position = Vector2(x + w * 0.5, y)
			x += w + GAP

	for s in _defend_nodes:
		if is_instance_valid(s):
			var w2 = s.texture.get_width() * s.scale.x if s.texture else 0.0
			s.position = Vector2(x + w2 * 0.5, y)
			x += w2 + GAP

func spend_attack(count:int = 1) -> void:
	var to_spend = min(count, attack)
	for i in range(to_spend):
		if _next_attack_to_spend < _attack_nodes.size():
			var s:Sprite2D = _attack_nodes[_next_attack_to_spend]
			if is_instance_valid(s):
				s.texture = spent_attack_sprite
			_next_attack_to_spend += 1
			attack -= 1
			spent_attack += 1

func spend_defend(count:int = 1) -> void:
	var to_spend = min(count, defend)
	for i in range(to_spend):
		if _next_defend_to_spend < _defend_nodes.size():
			var s:Sprite2D = _defend_nodes[_next_defend_to_spend]
			if is_instance_valid(s):
				s.texture = spent_defend_sprite
			_next_defend_to_spend += 1
			defend -= 1
			spent_defend += 1
