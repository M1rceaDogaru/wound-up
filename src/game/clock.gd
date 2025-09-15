extends Area2D

var is_collected = false

func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return

	if body.is_in_group("player"):
		is_collected = true
		body.has_rewind_ability = true
		$Label.visible = true
		$Sprite2D.visible = false
		await get_tree().create_timer(5).timeout
		queue_free()
