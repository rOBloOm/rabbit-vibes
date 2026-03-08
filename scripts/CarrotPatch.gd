extends Area2D

signal collected

const DIG_DURATION := 0.55
const REVEAL_DURATION := 0.35
const MUNCH_SOUND := preload("res://assets/audio/carrot_munch.wav")

@onready var _soil: Node2D = $Soil
@onready var _soil_outline: Polygon2D = $SoilOutline
@onready var _leaves: Node2D = $Leaves
@onready var _leaf_outline_left: Polygon2D = $Leaves/LeafOutlineLeft
@onready var _leaf_outline_center: Polygon2D = $Leaves/LeafOutlineCenter
@onready var _leaf_outline_right: Polygon2D = $Leaves/LeafOutlineRight
@onready var _hole: Polygon2D = $Hole
@onready var _carrot: Polygon2D = $CarrotBody
@onready var _munch_player: AudioStreamPlayer2D = $MunchPlayer

var _outline_nodes: Array[Polygon2D] = []
var _outline_base_colors: Array[Color] = []
var _carrot_base_position := Vector2.ZERO
var _anim_time := 0.0
var _dig_timer := 0.0
var _reveal_timer := 0.0
var _digging := false
var _collected := false
var _player_nearby := false

var can_interact: bool:
	get: return not _digging and not _collected

func _ready() -> void:
	add_to_group("carrot_patches")
	_munch_player.stream = MUNCH_SOUND
	_outline_nodes = [_soil_outline, _leaf_outline_left, _leaf_outline_center, _leaf_outline_right]
	for outline in _outline_nodes:
		_outline_base_colors.append(outline.color)
		outline.visible = false
	_carrot_base_position = _carrot.position
	_hole.visible = false
	_carrot.visible = false

func _process(delta: float) -> void:
	_anim_time += delta
	_update_outline_visual()
	if _digging:
		_dig_timer -= delta
		var shake := sin(_anim_time * 24.0)
		_leaves.rotation = 0.12 * shake
		_soil.scale = Vector2(1.0 + 0.05 * absf(shake), 1.0 - 0.03 * absf(shake))
		if _dig_timer <= 0.0:
			_digging = false
			_collected = true
			_hole.visible = true
			_reveal_timer = REVEAL_DURATION
			_carrot.visible = true
			_player_nearby = false
			_munch_player.pitch_scale = randf_range(0.94, 1.06)
			_munch_player.play()
			collected.emit()
		return
	if _reveal_timer > 0.0:
		_reveal_timer -= delta
		var t := 1.0 - clampf(_reveal_timer / REVEAL_DURATION, 0.0, 1.0)
		_carrot.position = _carrot_base_position + Vector2(0.0, -34.0 * t)
		_carrot.rotation = -0.18 * t
		_carrot.scale = Vector2.ONE * (1.0 + 0.15 * t)
		_carrot.modulate = Color(1, 1, 1, 1.0 - clampf((t - 0.72) / 0.28, 0.0, 1.0))
		if _reveal_timer <= 0.0:
			_carrot.visible = false
			_leaves.visible = false
			_soil.scale = Vector2.ONE
		return
	_leaves.rotation = sin(_anim_time * 1.8) * 0.04
	_soil.scale = Vector2.ONE

func interact(player: Node) -> void:
	if not can_interact:
		return
	_digging = true
	_dig_timer = DIG_DURATION
	_player_nearby = false
	player.begin_dig(global_position, DIG_DURATION)

func set_player_nearby(is_nearby: bool) -> void:
	_player_nearby = is_nearby and can_interact

func _update_outline_visual() -> void:
	var should_show := _player_nearby and can_interact
	var shimmer := 0.55 + 0.45 * sin(_anim_time * 6.6)
	for i in range(_outline_nodes.size()):
		var outline := _outline_nodes[i]
		outline.visible = should_show
		if not should_show:
			continue
		var color := _outline_base_colors[i]
		color.a = color.a * shimmer
		outline.color = color