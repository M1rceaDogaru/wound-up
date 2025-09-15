extends Area2D

var player: Node2D

func _process(delta: float) -> void:
	if !player:
		return
		
	if Input.is_action_just_pressed("spring_rewind"):
		player.spring_rewind(false)
	elif Input.is_action_just_pressed("overwind"):
		player.spring_rewind(true)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$Hint.visible = true
		player = body


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		$Hint.visible = false
		player = null
