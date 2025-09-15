extends Node2D

func _on_clock_door_opener_1_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$ClockDoor1/AnimationPlayer.play("open")
		$ClockDoor2/AnimationPlayer.play("open", -1.0, -1.0, true)


func _on_clock_door_opener_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$ClockDoor2/AnimationPlayer.play("open")
		$ClockDoor1/AnimationPlayer.play("open", -1.0, -1.0, true)
