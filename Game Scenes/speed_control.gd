extends Label

const SPEED_MIN := 1.0
const SPEED_MAX := 2.0
const SPEED_STEP := 0.1

var _tween: Tween = null
var _base_position: Vector2

func _ready() -> void:
	_base_position = position
	modulate.a = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not GameManager.VSmode:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			Engine.time_scale = minf(snappedf(Engine.time_scale + SPEED_STEP, 0.1), SPEED_MAX)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			Engine.time_scale = maxf(snappedf(Engine.time_scale - SPEED_STEP, 0.1), SPEED_MIN)
		else:
			return
		text = "%.1fx Speed" % Engine.time_scale
		_show_popup()

func _show_popup() -> void:
	if _tween:
		_tween.kill()
	position = _base_position
	modulate.a = 1.0
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(self, "modulate:a", 0.0, 0.6).set_delay(0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "position:y", _base_position.y - 30.0, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
