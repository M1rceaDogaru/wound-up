# RewindSystem.gd (Autoload)
extends Node

signal rewind_started()
signal rewind_ended()

var is_rewinding := false
var rewind_duration := 5.0  # Seconds to rewind
var max_records := 300  # Max frames to store (60fps × 5s = 300)

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS  # Work even when paused

func start_rewind():
	Stats.rewinds += 1
	is_rewinding = true
	rewind_started.emit()

func stop_rewind():
	is_rewinding = false
	rewind_ended.emit()
