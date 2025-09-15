extends Control

@export var shake_offset = 5
@export var overwind_theme: Theme
@export var standard_theme: Theme

var player

@onready var spring_tension = $SpringTension
@onready var original_position = $SpringTension.position

func _ready() -> void:
	player = get_tree().get_nodes_in_group("player")[0]

func _physics_process(delta: float) -> void:
	spring_tension.value = player.spring_tension
	if player.is_overwound:
		spring_tension.position = Vector2(original_position.x + randi_range(-shake_offset, shake_offset), original_position.y + randi_range(-shake_offset, shake_offset))
		spring_tension.theme = overwind_theme
	else:
		spring_tension.position = original_position
		spring_tension.theme = standard_theme
