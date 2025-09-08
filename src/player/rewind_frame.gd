class_name RewindFrame

var position: Vector2
var velocity: Vector2
var sprite_flip: bool

func _init(pos: Vector2, vel: Vector2, flip: bool):
	position = pos
	velocity = vel
	sprite_flip = flip
