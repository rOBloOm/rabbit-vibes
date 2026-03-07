extends Node2D

const CAMERA_LIMIT_LEFT := 0
const CAMERA_LIMIT_TOP := 0
const CAMERA_LIMIT_RIGHT := 3200
const CAMERA_LIMIT_BOTTOM := 900

enum GameState { TITLE, PLAYING, PAUSED, WON }

var _counter_root: Control
var _carrot_counter_label: Label
var _goal_hint_label: Label
var _title_overlay: Control
var _pause_overlay: Control
var _win_overlay: Control
var _player: Node
var _goal: Node
var _player_spawn_position := Vector2.ZERO
var _carrots_collected := 0
var _carrots_total := 0
var _game_state := GameState.TITLE

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_configure_input()
	_cache_nodes()
	_configure_camera()
	_configure_music()
	_configure_carrot_counter()
	_configure_goal()
	_show_title()
	print("jumpy Main scene ready")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu_accept"):
		if _game_state == GameState.TITLE:
			_start_game()
		elif _game_state == GameState.PAUSED:
			_resume_game()
		elif _game_state == GameState.WON:
			_restart_scene()
	elif event.is_action_pressed("pause_game") and _game_state not in [GameState.TITLE, GameState.WON]:
		if _game_state == GameState.PLAYING:
			_pause_game()
		elif _game_state == GameState.PAUSED:
			_resume_game()
	elif event.is_action_pressed("restart_level") and _game_state != GameState.PLAYING:
		_restart_scene()

func _cache_nodes() -> void:
	_player = $Player
	_goal = $GoalBurrow
	_counter_root = $Hud/CounterRoot
	_carrot_counter_label = $Hud/CounterRoot/CounterLabel
	_goal_hint_label = $Hud/CounterRoot/HintLabel
	_title_overlay = $Hud/TitleOverlay
	_pause_overlay = $Hud/PauseOverlay
	_win_overlay = $Hud/WinOverlay
	_player_spawn_position = _player.global_position
	_player.connect("defeated", Callable(self, "_on_player_defeated"))

func _configure_camera() -> void:
	var camera: Camera2D = $Player/Camera2D
	camera.limit_left = CAMERA_LIMIT_LEFT
	camera.limit_top = CAMERA_LIMIT_TOP
	camera.limit_right = CAMERA_LIMIT_RIGHT
	camera.limit_bottom = CAMERA_LIMIT_BOTTOM

func _configure_music() -> void:
	var music_player: AudioStreamPlayer = $MusicPlayer
	if music_player.stream == null:
		music_player.stream = AudioStreamWAV.load_from_file("res://assets/audio/meadow_theme.wav")
	music_player.finished.connect(func() -> void: music_player.play())
	_ensure_music_playing()

func _configure_carrot_counter() -> void:
	var carrot_nodes := get_tree().get_nodes_in_group("carrot_patches")
	_carrots_collected = 0
	_carrots_total = carrot_nodes.size()
	for node in carrot_nodes:
		node.connect("collected", Callable(self, "_on_carrot_collected"))
	_update_carrot_counter()

func _configure_goal() -> void:
	_goal.connect("reached", Callable(self, "_on_goal_reached"))
	_goal.set_unlocked(_carrots_total == 0)
	_update_goal_hint()

func _on_carrot_collected() -> void:
	_carrots_collected = mini(_carrots_collected + 1, _carrots_total)
	_update_carrot_counter()
	if _carrots_collected >= _carrots_total:
		_goal.set_unlocked(true)
	_update_goal_hint()

func _update_carrot_counter() -> void:
	_carrot_counter_label.text = "Carrots: %d/%d" % [_carrots_collected, _carrots_total]

func _update_goal_hint() -> void:
	_goal_hint_label.text = "Burrow unlocked! Reach home." if _carrots_collected >= _carrots_total else "Collect all carrots to unlock the burrow."

func _show_title() -> void:
	_player.reset_to(_player_spawn_position)
	_player.set_input_enabled(false)
	_game_state = GameState.TITLE
	get_tree().paused = true
	_update_overlay_visibility()

func _start_game() -> void:
	_player.reset_to(_player_spawn_position)
	_player.set_input_enabled(true)
	_game_state = GameState.PLAYING
	get_tree().paused = false
	_ensure_music_playing()
	_update_overlay_visibility()

func _pause_game() -> void:
	_game_state = GameState.PAUSED
	get_tree().paused = true
	_update_overlay_visibility()

func _resume_game() -> void:
	_game_state = GameState.PLAYING
	get_tree().paused = false
	_ensure_music_playing()
	_update_overlay_visibility()

func _on_player_defeated() -> void:
	if _game_state != GameState.PLAYING:
		return
	_player.reset_to(_player_spawn_position)
	_player.set_input_enabled(true)

func _on_goal_reached() -> void:
	if _game_state != GameState.PLAYING:
		return
	_player.set_input_enabled(false)
	_game_state = GameState.WON
	get_tree().paused = true
	_update_overlay_visibility()

func _update_overlay_visibility() -> void:
	_title_overlay.visible = _game_state == GameState.TITLE
	_pause_overlay.visible = _game_state == GameState.PAUSED
	_win_overlay.visible = _game_state == GameState.WON
	_counter_root.visible = _game_state != GameState.TITLE

func _restart_scene() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _ensure_music_playing() -> void:
	var music_player: AudioStreamPlayer = $MusicPlayer
	if not music_player.playing:
		music_player.play()

static func _configure_input() -> void:
	_configure_action("move_left", [KEY_A])
	_configure_action("move_right", [KEY_D])
	_configure_action("jump", [KEY_SPACE, KEY_W])
	_configure_action("interact", [KEY_E])
	_configure_action("pause_game", [KEY_ESCAPE, KEY_P])
	_configure_action("menu_accept", [KEY_ENTER, KEY_KP_ENTER])
	_configure_action("restart_level", [KEY_R])

static func _configure_action(action_name: String, keys: Array) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	InputMap.action_erase_events(action_name)
	for key in keys:
		var input_event := InputEventKey.new()
		input_event.physical_keycode = key
		InputMap.action_add_event(action_name, input_event)