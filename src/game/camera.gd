extends Camera2D

var shake_amount: float = 0.0
var shake_decay: float = 2.0

var max_camera_offset = 4.0

var offset_scale = 1.0

var default_zoom := 0.5

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
	
func set_new_parent(parent: Node2D, new_zoom: float):
	reparent(parent)
	var tween = create_tween()
	tween.tween_property(self, "zoom", Vector2(new_zoom, new_zoom), 1.0)
