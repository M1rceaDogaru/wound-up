extends Node2D

class_name Game

@onready var player = $Player
@onready var exploration_music = $ExplorationMusic
@onready var boss_music = $BossMusic

var music_tween: Tween

var original_pitch: float

# game state variables
var tunnel_door_open := false

func _ready() -> void:
	move_to("start")

func move_to(target: String, transition_name: String = "", new_position: Vector2 = Vector2.ZERO):
	var current_map = find_child("Map", false, false)
	current_map.free()
	var target_scene = load("res://maps/%s.tscn" % target)
	var new_map = target_scene.instantiate()
	add_child(new_map)
	
	var spawn_point = new_position
	if transition_name:
		var target_transition: Transition = new_map.find_child("Transitions").find_child(transition_name)
		spawn_point = target_transition.entry_point.global_position

	var camera = get_viewport().get_camera_2d()
	var top_left_limit: Node2D = new_map.find_child("TopLeft", true, false)
	var bottom_right_limit: Node2D = new_map.find_child("BottomRight", true, false)
	
	camera.limit_left = top_left_limit.global_position.x
	camera.limit_top = top_left_limit.global_position.y
	camera.limit_bottom = bottom_right_limit.global_position.y
	camera.limit_right = bottom_right_limit.global_position.x
	
	player.transition_to(spawn_point)

func set_music_speed(value):
	if music_tween:
		music_tween.kill()
	
	music_tween = create_tween()
	music_tween.tween_property(exploration_music, "pitch_scale", value, 1.0)

func switch_to_boss():
	var transition_tween = create_tween()
	boss_music.volume_db = -80
	boss_music.play()
	transition_tween.parallel().tween_property(boss_music, "volume_db", 0.0, 1.0)
	transition_tween.parallel().tween_property(exploration_music, "volume_db", -80.0, 1.0)
	transition_tween.tween_callback(exploration_music.stop)
	
func reset_music():
	boss_music.volume_db = 0.0
	exploration_music.volume_db = 0.0
	exploration_music.pitch_scale = 1.0
	boss_music.stop()
	exploration_music.play()
	
func time_rewinding(value):
	exploration_music.pitch_scale = 0.5 if value else 1.0
	boss_music.pitch_scale = 0.5 if value else 1.0
