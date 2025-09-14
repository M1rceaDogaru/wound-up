extends Camera2D

var shake_amount: float = 0.0
var shake_decay: float = 2.0

var max_camera_offset = 4.0

var offset_scale = 1.0

func _process(delta):
	if shake_amount > 0:
		var offset_x = randf_range(-shake_amount, shake_amount)
		var offset_y = randf_range(-shake_amount, shake_amount)
		offset = Vector2(offset_x, offset_y)

		shake_amount = lerp(shake_amount, 0.0, shake_decay * delta)
	else:
		offset = Vector2.ZERO

func trigger_shake(amount: float):
	shake_amount = max(shake_amount, amount)
