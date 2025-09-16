extends Node

@export var jumps := 0
@export var rewinds := 0
@export var deaths := 0
@export var time_taken := 0.0

var start_time

func start():
	jumps = 0
	rewinds = 0
	deaths = 0
	time_taken = 0.0
	start_time = Time.get_unix_time_from_system()
	
func end_game():
	var now = Time.get_unix_time_from_system()
	time_taken = now - start_time
	
