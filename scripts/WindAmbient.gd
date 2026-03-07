extends Node2D

const LOOP_WIDTH := 3500.0
const GUST_NAMES := ["GustA", "GustB", "GustC"]
const MOTE_NAMES := ["Mote1", "Mote2", "Mote3", "Mote4", "Mote5", "Mote6", "Mote7", "Mote8"]

var _gusts: Array[Node2D] = []
var _motes: Array[Node2D] = []
var _gust_bases: Array[Vector2] = []
var _mote_bases: Array[Vector2] = []
var _time := 0.0

func _ready() -> void:
	for gust_name in GUST_NAMES:
		var gust: Node2D = get_node(gust_name)
		_gusts.append(gust)
		_gust_bases.append(gust.position)
	for mote_name in MOTE_NAMES:
		var mote: Node2D = get_node(mote_name)
		_motes.append(mote)
		_mote_bases.append(mote.position)

func _process(delta: float) -> void:
	_time += delta
	for i in range(_gusts.size()):
		var phase := i * 0.9
		var x := fposmod(_gust_bases[i].x + _time * (120.0 + i * 24.0), LOOP_WIDTH + 280.0) - 140.0
		var y := _gust_bases[i].y + sin(_time * 0.8 + phase) * 14.0
		_gusts[i].position = Vector2(x, y)
		_gusts[i].scale = Vector2(1.0 + 0.08 * sin(_time + phase), 1.0)
	for i in range(_motes.size()):
		var phase := i * 0.55
		var x := fposmod(_mote_bases[i].x + _time * (36.0 + i * 4.0), LOOP_WIDTH + 120.0) - 60.0
		var y := _mote_bases[i].y + sin(_time * (0.9 + i * 0.06) + phase) * 16.0
		_motes[i].position = Vector2(x, y)
		_motes[i].rotation += (0.4 + i * 0.05) * delta