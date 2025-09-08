class_name RewindFrame

var position: Vector2
var velocity: Vector2
var sprite_flip: bool
var spring_tension: float

func _init(pos: Vector2, vel: Vector2, flip: bool, tension: float):
	position = pos
	velocity = vel
	sprite_flip = flip
	spring_tension = tension
