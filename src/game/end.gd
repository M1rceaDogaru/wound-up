extends Node2D

func _ready() -> void:
	$Jumps.text = "You jumped %s times" % str(Stats.jumps)
	$Deaths.text = "You died %s times" % str(Stats.deaths)
	$Rewinds.text = "You turned back time %s times" % str(Stats.rewinds)
	$TimeTaken.text = "It took you %s seconds to complete the game" % str(int(Stats.time_taken))

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://game/game.tscn")
