extends CharacterBody2D

signal defeated

const MAX_AIR_JUMPS := 1
const MOVE_SPEED := 300.0
const GROUND_ACCELERATION := 4200.0
const GROUND_DECELERATION := 5200.0
const AIR_ACCELERATION := 2200.0
const AIR_DECELERATION := 1600.0
const JUMP_VELOCITY := -460.0
const JUMP_CUT_VELOCITY := -150.0
const RISING_GRAVITY_MULTIPLIER := 0.95
const LOW_JUMP_GRAVITY_MULTIPLIER := 3.6
const FALLING_GRAVITY_MULTIPLIER := 2.8
const MAX_FALL_SPEED := 1450.0

@onready var _interaction_area: Area2D = $InteractionArea
@onready var _jump_player: AudioStreamPlayer2D = $JumpPlayer
@onready var _visual_root: Node2D = $BunnyVisual
@onready var _body: Node2D = $BunnyVisual/Body
@onready var _head: Node2D = $BunnyVisual/Head
@onready var _front_foot: Node2D = $BunnyVisual/FrontFoot
@onready var _back_foot: Node2D = $BunnyVisual/BackFoot
@onready var _tail: Node2D = $BunnyVisual/Tail
@onready var _ear_front: Node2D = $BunnyVisual/Head/EarFront
@onready var _ear_back: Node2D = $BunnyVisual/Head/EarBack

var _visual_base_position := Vector2.ZERO
var _body_base_scale := Vector2.ONE
var _head_base_position := Vector2.ZERO
var _front_foot_base_position := Vector2.ZERO
var _back_foot_base_position := Vector2.ZERO
var _ear_front_base_rotation := 0.0
var _ear_back_base_rotation := 0.0
var _anim_time := 0.0
var _facing := 1.0
var _nearby_patches: Array = []
var _dig_timer := 0.0
var _air_jumps_remaining := MAX_AIR_JUMPS
var _input_enabled := true

func _ready() -> void:
	add_to_group("player")
	_visual_base_position = _visual_root.position
	_body_base_scale = _body.scale
	_head_base_position = _head.position
	_front_foot_base_position = _front_foot.position
	_back_foot_base_position = _back_foot.position
	_ear_front_base_rotation = _ear_front.rotation
	_ear_back_base_rotation = _ear_back.rotation
	_jump_player.stream = AudioStreamWAV.load_from_file("res://assets/audio/rabbit_jump.wav")
	_interaction_area.area_entered.connect(_on_interaction_area_entered)
	_interaction_area.area_exited.connect(_on_interaction_area_exited)

func _physics_process(delta: float) -> void:
	var current_velocity := velocity
	var gravity := float(ProjectSettings.get_setting("physics/2d/default_gravity"))
	var holding_jump := _input_enabled and Input.is_action_pressed("jump")
	var on_floor := is_on_floor()
	if on_floor: _air_jumps_remaining = MAX_AIR_JUMPS
	if not on_floor:
		var gravity_multiplier := FALLING_GRAVITY_MULTIPLIER
		if current_velocity.y < 0.0:
			gravity_multiplier = RISING_GRAVITY_MULTIPLIER if holding_jump else LOW_JUMP_GRAVITY_MULTIPLIER
		current_velocity.y = minf(current_velocity.y + gravity * gravity_multiplier * delta, MAX_FALL_SPEED)
	elif current_velocity.y > 0.0:
		current_velocity.y = 0.0
	if _dig_timer > 0.0:
		_dig_timer = maxf(0.0, _dig_timer - delta)
		current_velocity.x = move_toward(current_velocity.x, 0.0, GROUND_DECELERATION * delta)
		velocity = current_velocity
		move_and_slide()
		_update_visuals(delta)
		return
	if _input_enabled and Input.is_action_just_pressed("jump"):
		if on_floor:
			current_velocity = _perform_jump(current_velocity, false)
		elif _air_jumps_remaining > 0:
			_air_jumps_remaining -= 1
			current_velocity = _perform_jump(current_velocity, true)
	if _input_enabled and Input.is_action_just_released("jump") and current_velocity.y < JUMP_CUT_VELOCITY:
		current_velocity.y = JUMP_CUT_VELOCITY
	if _input_enabled and Input.is_action_just_pressed("interact") and _try_interact():
		current_velocity.x = 0.0
		velocity = current_velocity
		_update_visuals(delta)
		return
	var direction := Input.get_axis("move_left", "move_right") if _input_enabled else 0.0
	var target_speed := direction * MOVE_SPEED
	var acceleration := GROUND_ACCELERATION if absf(direction) > 0.01 and on_floor else AIR_ACCELERATION if absf(direction) > 0.01 else GROUND_DECELERATION if on_floor else AIR_DECELERATION
	current_velocity.x = move_toward(current_velocity.x, target_speed, acceleration * delta)
	velocity = current_velocity
	move_and_slide()
	_update_visuals(delta)

func begin_dig(target_position: Vector2, duration: float) -> void:
	_dig_timer = duration
	velocity = Vector2.ZERO
	var facing_offset := target_position.x - global_position.x
	if absf(facing_offset) > 1.0:
		_facing = sign(facing_offset)

func set_input_enabled(enabled: bool) -> void:
	_input_enabled = enabled
	if not enabled: velocity = Vector2.ZERO

func reset_to(world_position: Vector2) -> void:
	global_position = world_position
	velocity = Vector2.ZERO
	_dig_timer = 0.0
	_air_jumps_remaining = MAX_AIR_JUMPS
	_nearby_patches.clear()
	_visual_root.position = _visual_base_position

func defeat() -> void:
	defeated.emit()

func _perform_jump(current_velocity: Vector2, is_double_jump: bool) -> Vector2:
	current_velocity.y = JUMP_VELOCITY * 0.94 if is_double_jump else JUMP_VELOCITY
	_jump_player.pitch_scale = 1.12 if is_double_jump else 1.0
	_jump_player.play()
	_anim_time += 1.1 if is_double_jump else 0.4
	return current_velocity

func _try_interact() -> bool:
	var best_patch = null
	var best_distance := INF
	var stale_patches: Array = []
	for patch in _nearby_patches:
		if not is_instance_valid(patch) or not patch.can_interact:
			stale_patches.append(patch)
			continue
		var distance := global_position.distance_squared_to(patch.global_position)
		if distance < best_distance:
			best_distance = distance
			best_patch = patch
	for stale_patch in stale_patches: _nearby_patches.erase(stale_patch)
	if best_patch == null: return false
	best_patch.interact(self)
	return true

func _on_interaction_area_entered(area: Area2D) -> void:
	if area.is_in_group("carrot_patches") and not _nearby_patches.has(area): _nearby_patches.append(area)

func _on_interaction_area_exited(area: Area2D) -> void:
	_nearby_patches.erase(area)

func _update_visuals(delta: float) -> void:
	var speed_ratio := clampf(absf(velocity.x) / MOVE_SPEED, 0.0, 1.0)
	if velocity.x > 5.0: _facing = 1.0
	elif velocity.x < -5.0: _facing = -1.0
	_visual_root.scale = Vector2(_facing, 1.0)
	_anim_time += delta * (18.0 if _dig_timer > 0.0 else lerpf(2.4, 9.0, speed_ratio))
	if _dig_timer > 0.0:
		var scratch := sin(_anim_time)
		var scoop := absf(cos(_anim_time))
		_visual_root.position = _visual_base_position + Vector2(0.0, 3.0 + scoop * 2.0)
		_body.scale = _body_base_scale + Vector2(0.1, -0.1 * scoop)
		_head.position = _head_base_position + Vector2(6.0, 6.0 + scoop * 1.5)
		_front_foot.position = _front_foot_base_position + Vector2(12.0, 6.0 + scratch * 6.0)
		_back_foot.position = _back_foot_base_position + Vector2(2.0, 3.0 + scoop * 2.0)
		_tail.rotation = -0.22 + 0.08 * scratch
		_ear_front.rotation = _ear_front_base_rotation + 0.3 + 0.1 * scoop
		_ear_back.rotation = _ear_back_base_rotation + 0.2 + 0.08 * scoop
		return
	if is_on_floor():
		var bounce := sin(_anim_time)
		var stride := cos(_anim_time)
		var bounce_abs := absf(bounce)
		var idle_bob := sin(_anim_time * 1.4) * 0.7 if speed_ratio < 0.05 else 0.0
		_visual_root.position = _visual_base_position + Vector2(0.0, idle_bob + bounce_abs * 2.4 * speed_ratio)
		_body.scale = _body_base_scale + Vector2(0.06 * speed_ratio, -0.08 * bounce_abs * speed_ratio)
		_head.position = _head_base_position + Vector2(0.8 * speed_ratio, -1.4 * bounce_abs * speed_ratio - idle_bob * 0.25)
		_front_foot.position = _front_foot_base_position + Vector2(0.0, maxf(0.0, bounce) * 4.0 * speed_ratio)
		_back_foot.position = _back_foot_base_position + Vector2(0.0, maxf(0.0, -bounce) * 4.0 * speed_ratio)
		_tail.rotation = 0.08 * stride * speed_ratio
		_ear_front.rotation = _ear_front_base_rotation + 0.12 * stride * speed_ratio - 0.03 * idle_bob
		_ear_back.rotation = _ear_back_base_rotation + 0.10 * stride * speed_ratio - 0.02 * idle_bob
		return
	var rising := velocity.y < -20.0
	_visual_root.position = _visual_base_position + Vector2(0.0, -2.0 if rising else 2.0)
	_body.scale = _body_base_scale + (Vector2(-0.04, 0.08) if rising else Vector2(0.05, -0.03))
	_head.position = _head_base_position + Vector2(1.5 if rising else -0.8, -2.2 if rising else 0.8)
	_front_foot.position = _front_foot_base_position + Vector2(6.0, -5.0 if rising else 2.0)
	_back_foot.position = _back_foot_base_position + Vector2(2.0, -2.0 if rising else 4.0)
	_tail.rotation = 0.16 if rising else -0.18
	_ear_front.rotation = _ear_front_base_rotation + (-0.22 if rising else 0.24)
	_ear_back.rotation = _ear_back_base_rotation + (-0.16 if rising else 0.18)