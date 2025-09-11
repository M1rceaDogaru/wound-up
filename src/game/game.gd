extends Node2D

class_name Game

@onready var player = $Player

func move_to(target: String, transition_name: String):
	var current_map = find_child("Map", false, false)
	current_map.free()
	var target_scene = load("res://maps/%s.tscn" % target)
	var new_map = target_scene.instantiate()
	add_child(new_map)
	
	var target_transition: Transition = new_map.find_child("Transitions").find_child(transition_name)
	player.transition_to(target_transition.entry_point.global_position)
