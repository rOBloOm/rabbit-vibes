extends Node2D

const LOOP_WIDTH := 3600.0
const BIRD_NAMES := ["BirdA", "BirdB", "BirdC"]

var _birds: Array[Node2D] = []
var _left_wings: Array[Node2D] = []
var _right_wings: Array[Node2D] = []
var _base_positions: Array[Vector2] = []
var _time := 0.0

func _ready() -> void:
	for bird_name in BIRD_NAMES:
		_birds.append(get_node(bird_name))
		_left_wings.append(get_node("%s/WingLeft" % bird_name))
		_right_wings.append(get_node("%s/WingRight" % bird_name))
		_base_positions.append(_birds.back().position)

func _process(delta: float) -> void:
	_time += delta
	for i in range(_birds.size()):
		var phase := i * 0.8
		var speed := 58.0 + i * 18.0
		var flap := sin(_time * (7.0 + i) + phase)
		var x := fposmod(_base_positions[i].x + _time * speed, LOOP_WIDTH + 220.0) - 110.0
		var y := _base_positions[i].y + sin(_time * 0.9 + phase) * 18.0
		_birds[i].position = Vector2(x, y)
		_birds[i].rotation = sin(_time * 0.5 + phase) * 0.04
		_left_wings[i].rotation = -0.45 + flap * 0.28
		_right_wings[i].rotation = 0.45 - flap * 0.28