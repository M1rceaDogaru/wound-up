extends Node2D


func _on_sentinel_door_opener_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$SentinelDoor/AnimationPlayer.play("open")


func _on_sentinel_door_opener_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		$SentinelDoor/AnimationPlayer.play("open", -1.0, -1.0, true)
