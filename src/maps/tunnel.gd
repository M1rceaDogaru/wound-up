extends Node2D

func _ready() -> void:
	if get_tree().current_scene.tunnel_door_open:
		$TunnelDoor.queue_free()
		$TunnelDoorOpener.queue_free()
