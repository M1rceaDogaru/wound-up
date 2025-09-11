extends Area2D

class_name Transition

enum EntryDirection { Left, Right }

@export var target_location: String
@export var entry: EntryDirection

@onready var entry_point := $LeftEntry if entry == EntryDirection.Left else $RightEntry

func _on_transition_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var game = get_tree().current_scene
		game.call_deferred("move_to", target_location, name)
