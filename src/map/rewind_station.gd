extends Area2D

@export var map_name = ""

var player: Node2D

func _process(delta: float) -> void:
	if !player:
		return
		
	if Input.is_action_just_pressed("spring_rewind"):
		player.spring_rewind(map_name, global_position, false)
	elif Input.is_action_just_pressed("overwind"):
		player.spring_rewind(map_name, global_position, true)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$Hint.visible = true
		player = body

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		$Hint.visible = false
		player = null
