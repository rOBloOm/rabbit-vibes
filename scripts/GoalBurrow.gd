extends Area2D

signal reached

@onready var _glow: Polygon2D = $Glow
@onready var _lock_icon: Polygon2D = $LockIcon
@onready var _sign: Polygon2D = $Sign

var _unlocked := false
var _time := 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_apply_visual_state()

func _process(delta: float) -> void:
	_time += delta
	if not _unlocked:
		return
	var pulse := 0.82 + 0.18 * sin(_time * 2.4)
	_glow.scale = Vector2(pulse, pulse)
	_glow.modulate = Color(1, 1, 1, 0.45 + 0.15 * sin(_time * 2.0))

func set_unlocked(unlocked: bool) -> void:
	_unlocked = unlocked
	_apply_visual_state()

func _apply_visual_state() -> void:
	_glow.visible = _unlocked
	_lock_icon.visible = not _unlocked
	_sign.color = Color(0.976471, 0.831373, 0.45098, 1.0) if _unlocked else Color(0.568627, 0.411765, 0.25098, 1.0)

func _on_body_entered(body: Node2D) -> void:
	if not _unlocked or not body.is_in_group("player"):
		return
	reached.emit()