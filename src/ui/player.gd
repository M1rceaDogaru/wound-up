extends Control

var player

@onready var spring_tension = $SpringTension

func _ready() -> void:
	player = get_tree().get_nodes_in_group("player")[0]

func _process(delta: float) -> void:
	spring_tension.value = player.spring_tension
