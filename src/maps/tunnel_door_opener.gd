extends Area2D

@export var door_animator: AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		door_animator.play("open")
		get_tree().current_scene.tunnel_door_open = true
