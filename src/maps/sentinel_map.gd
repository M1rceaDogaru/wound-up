extends Node2D

@export var attack_cooldown := 2.0

var sentinel_is_left := true

func attack_finished():
	sentinel_is_left = !sentinel_is_left
	$SentinelWait.start(attack_cooldown)
	
func _on_sentinel_wait_timeout() -> void:
	var attack_type = randi_range(0, 1)
	var animation_name = ""
	if attack_type == 0:
		animation_name = "charge_from_left" if sentinel_is_left else "charge_from_right"
	else:
		animation_name = "jump_from_left" if sentinel_is_left else "jump_from_right"
	
	$SentinelMoves.play(animation_name)

func lock_doors():
	print("Doors locked")
	
func shake_camera():
	get_viewport().get_camera_2d().trigger_shake(8.0)

func _on_sentinel_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$SentinelMoves.play("initiate")
		$SentinelTrigger.queue_free()
		
