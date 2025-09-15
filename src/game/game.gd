extends Node2D

class_name Game

@onready var player = $Player

func _ready() -> void:
	pass

func move_to(target: String, transition_name: String):
	var current_map = find_child("Map", false, false)
	current_map.free()
	var target_scene = load("res://maps/%s.tscn" % target)
	var new_map = target_scene.instantiate()
	add_child(new_map)
	
	var target_transition: Transition = new_map.find_child("Transitions").find_child(transition_name)
	var camera = get_viewport().get_camera_2d()
	var top_left_limit: Node2D = new_map.find_child("TopLeft", true, false)
	var bottom_right_limit: Node2D = new_map.find_child("BottomRight", true, false)
	camera.limit_left = top_left_limit.global_position.x
	camera.limit_top = top_left_limit.global_position.y
	camera.limit_bottom = bottom_right_limit.global_position.y
	camera.limit_right = bottom_right_limit.global_position.x
	player.transition_to(target_transition.entry_point.global_position)
	
