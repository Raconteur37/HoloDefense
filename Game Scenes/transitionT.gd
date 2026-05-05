extends ColorRect

@export var off_duration: float  = 0.15   # how long the collapse takes
@export var on_duration:  float  = 0.35   # turn-on is slower for drama
@export var hold_black:   float  = 0.06   # pause at fully dark

var _mat: ShaderMaterial

func _ready() -> void:
	_mat = material as ShaderMaterial
	visible = false


func play(on_midpoint: Callable = Callable()) -> void:
	visible = true
	_mat.set_shader_parameter("turning_on", false)
	_mat.set_shader_parameter("phase", 0.0)
	_mat.set_shader_parameter("progress", 0.0)

	var tw := create_tween()

	# ── Phase 1: collapse (turn off) ──────────────────────────────────────────
	tw.tween_method(
		func(v: float):
			_mat.set_shader_parameter("progress", v)
			_mat.set_shader_parameter("phase", 0.0),
		0.0, 1.0, off_duration
	).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)

	# ── Midpoint: screen fully collapsed ─────────────────────────────────────
	tw.tween_callback(func():
		if on_midpoint.is_valid():
			on_midpoint.call()
	)

	tw.tween_interval(hold_black)

	# ── Phase 2: expand (turn on) ─────────────────────────────────────────────
	tw.tween_callback(func():
		_mat.set_shader_parameter("turning_on", true)
		_mat.set_shader_parameter("progress", 0.0)
		_mat.set_shader_parameter("phase", 1.0)
	)

	# Fast initial burst then slow settle — two-step easing
	tw.tween_method(
		func(v: float): _mat.set_shader_parameter("progress", v),
		0.0, 0.15, on_duration * 0.12   # snap open to a sliver fast
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	tw.tween_method(
		func(v: float): _mat.set_shader_parameter("progress", v),
		0.15, 1.0, on_duration * 0.88   # then slowly bloom to full
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tw.tween_callback(func(): visible = false)
