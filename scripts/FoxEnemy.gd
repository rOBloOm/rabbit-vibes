extends Area2D

@export var patrol_distance := 200.0
@export var speed := 85.0

@onready var _visual_root: Node2D = $Visual

var _start_position := Vector2.ZERO
var _direction := 1.0
var _time := 0.0

func _ready() -> void:
	_start_position = position
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	_time += delta
	position += Vector2.RIGHT * _direction * speed * delta
	if position.x > _start_position.x + patrol_distance:
		position = Vector2(_start_position.x + patrol_distance, position.y)
		_direction = -1.0
	elif position.x < _start_position.x - patrol_distance:
		position = Vector2(_start_position.x - patrol_distance, position.y)
		_direction = 1.0
	_visual_root.scale = Vector2(_direction, 1.0)
	_visual_root.position = Vector2(0.0, absf(sin(_time * 5.0)) * 2.0)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.defeat()