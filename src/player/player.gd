extends CharacterBody2D

@export_group("Movement")
# Movement Properties
@export var max_speed: float = 240.0
@export var acceleration: float = 1800.0
@export var friction: float = 2400.0
@export var jump_velocity: float = -480.0

# Quality of Life Properties
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1

@export var gravity_multiplier: float = 3
@export var overwound_speed_multiplier = 2.0

@export_group("Damage and health")
# Spring Tension Properties
@export var max_spring_tension: float = 100.0
@export var spring_depletion_rate: float = 5.0 # Tension lost per second
@export var damage_depletion_amount: float = 25.0
@export var overwound_depletion_multiplier: float = 1.5
@export var knockback_force: float = 1500

# Rewind system Properties
@export var rewind_cooldown := 2.0
var can_rewind := true
var rewind_timer := 0.0
var rewind_frames: Array[RewindFrame] = []
var current_rewind_index := 0

# Get the gravity from the project settings so you can sync with rigid body nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# State Variables
var spring_tension: float
@export var is_overwound: bool = false
var was_on_floor: bool = false

# Quality of Life Variables
var can_coyote_jump: bool = false
var has_jump_buffer: bool = false

var invulnerability_tween: Tween
var is_invulnerable := false
var is_dead := false

# Node References
@onready var coyote_timer = $CoyoteTimer
@onready var jump_buffer_timer = $JumpBufferTimer
@onready var sprite = $Sprite2D
@onready var animation = $AnimationPlayer

@onready var dust = preload("res://particles/dust.tscn")

var camera: Camera2D

func _ready():
	spring_tension = max_spring_tension
	coyote_timer.connect("timeout", _on_coyote_timer_timeout)
	coyote_timer.wait_time = coyote_time
	jump_buffer_timer.connect("timeout", _on_jump_buffer_timer_timeout)
	jump_buffer_timer.wait_time = jump_buffer_time
	
	camera = get_viewport().get_camera_2d()
	
	RewindSystem.rewind_started.connect(_on_rewind_started)
	RewindSystem.rewind_ended.connect(_on_rewind_ended)

func _physics_process(delta):
	if is_dead:
		return
		
	if RewindSystem.is_rewinding:
		handle_rewind(delta)
	else:
		handle_normal_movement(delta)
		store_rewind_frame()
		update_rewind_cooldown(delta)
	
func handle_normal_movement(delta):
	# --- MOVEMENT & INPUT HANDLING ---
	handle_jump_input()
	var horizontal_input = Input.get_axis("move_left", "move_right")
	handle_movement(horizontal_input, delta)
	apply_gravity(delta)
	
	# --- COYOTE TIME LOGIC ---
	# Check if we just left the ground this frame
	if was_on_floor and not is_on_floor():
		can_coyote_jump = true
		coyote_timer.start()
	
	# Check if we just landed this frame
	if not was_on_floor and is_on_floor():
		can_coyote_jump = false
		coyote_timer.stop()
	
	var must_jump = has_jump_buffer and (is_on_floor() or can_coyote_jump)
	# Apply jump if we have a buffered jump and are now able to jump
	if must_jump:
		perform_jump()
		
	deplete_spring_tension(delta, horizontal_input, must_jump)
	
	was_on_floor = is_on_floor()
	move_and_slide()
	
	# Handle rewind input
	if Input.is_action_just_pressed("rewind") and can_rewind:
		start_rewind()
		
	if (Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right")) and is_on_floor():
		var dust_instance: CPUParticles2D = dust.instantiate()
		dust_instance.direction.x = 1 if horizontal_input < 0 else -1
		add_child(dust_instance)
		
func deplete_spring_tension(delta, move_input, has_jumped):
	if has_jumped:
		spring_tension -= 1
	
	if move_input != 0:
		# --- SPRING TENSION MANAGEMENT ---
		# Calculate base depletion rate. Only deplete when there is movement input
		var current_depletion_rate = spring_depletion_rate
		if is_overwound:
			current_depletion_rate *= overwound_depletion_multiplier # multiplier for overwound state
		
		# Deplete the spring
		spring_tension -= current_depletion_rate * delta
		spring_tension = clamp(spring_tension, 0.0, max_spring_tension)
	
	# Check for game over
	if spring_tension <= 0.0:
		game_over("Spring Unwound!")
		return

func handle_jump_input():
	# Jump Buffer: If the player presses jump, start the buffer timer
	if Input.is_action_just_pressed("jump"):
		has_jump_buffer = true
		jump_buffer_timer.start()
	
	# Cancel jump buffer if the jump is successfully executed
	if has_jump_buffer and Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = 0 # Variable height jump
		has_jump_buffer = false
		jump_buffer_timer.stop()

func handle_movement(horizontal_input, delta):
	if horizontal_input != 0:
		# Apply acceleration
		var target_speed = horizontal_input * max_speed
		if is_overwound:
			target_speed *= overwound_speed_multiplier
		
		velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)
		
		# Flip sprite to face direction of movement
		if horizontal_input > 0:
			sprite.flip_h = false
		elif horizontal_input < 0:
			sprite.flip_h = true
			
		animation.play("move")
	else:
		# Apply friction when no input
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		animation.stop()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * gravity_multiplier * delta
		
# Add this function to handle the stomp bounce
func bounce_from_stomp(bounce_force: float):
	# Immediately set vertical velocity to the bounce force
	velocity.y = bounce_force * gravity_multiplier

func perform_jump():
	velocity.y = jump_velocity
	can_coyote_jump = false
	has_jump_buffer = false
	coyote_timer.stop()
	jump_buffer_timer.stop()
	# Play jump sound effect here later

func take_damage(from_position: Vector2):
	if is_invulnerable:
		return
	
	spring_tension -= damage_depletion_amount
	var knockback_direction = (global_position - from_position).normalized()
	# Apply the knockback force vector
	velocity = Vector2(knockback_direction * knockback_force)
	start_invulnerability()

@onready var explosion = preload("res://particles/explosion.tscn")
func game_over(reason: String):
	print("Game Over: ", reason)
	is_dead = true
	for i in range(10):
		create_explosion($CollisionShape2D)
		await get_tree().create_timer(0.3).timeout
	await get_tree().create_timer(0.5).timeout
	reset_player()
	get_tree().current_scene.move_to(last_rewind_station_map, "", last_rewind_station_position)

func create_explosion(source):
	var new_explosion = explosion.instantiate()
	new_explosion.global_position = source.global_position
	get_tree().current_scene.add_child(new_explosion)

func reset_player():
	get_tree().current_scene.reset_music()
	camera.set_new_parent(self, 0.5)
	velocity = Vector2.ZERO
	rewind_frames.clear()
	spring_tension = max_spring_tension
	is_overwound = false
	is_dead = false
	
# --- TIME REWIND LOGIC ---
func store_rewind_frame():
	var frame = RewindFrame.new(
		global_position,
		velocity,
		sprite.flip_h,
		spring_tension
	)
	
	rewind_frames.push_front(frame)
	
	# Limit the number of stored frames
	if rewind_frames.size() > RewindSystem.max_records:
		rewind_frames.pop_back()

func handle_rewind(delta):
	if Input.is_action_just_released("rewind"):
		stop_rewind()
		return

	if rewind_frames.size() > 0:
		# Only rewind if user presses left
		if not Input.is_action_pressed("move_left"):
			return
		# Get the next frame in rewind sequence
		var rewind_frame = rewind_frames[0]
		
		# Apply rewind data
		global_position = rewind_frame.position
		velocity = rewind_frame.velocity
		sprite.flip_h = rewind_frame.sprite_flip
		spring_tension = rewind_frame.spring_tension
		
		# Remove this frame from the rewind buffer
		rewind_frames.pop_front()
	else:
		# No more frames to rewind, stop rewinding
		stop_rewind()
		
func start_rewind():
	if can_rewind and rewind_frames.size() > 0:
		get_tree().current_scene.time_rewinding(true)
		RewindSystem.start_rewind()
		can_rewind = false
		rewind_timer = rewind_cooldown

func stop_rewind():
	get_tree().current_scene.time_rewinding(false)
	RewindSystem.stop_rewind()

func update_rewind_cooldown(delta):
	if not can_rewind:
		rewind_timer -= delta
		if rewind_timer <= 0:
			can_rewind = true

func _on_rewind_started():
	# Optional: Add visual/audio effects
	modulate = Color(0.5, 0.8, 1.0)  # Blue tint during rewind
	Engine.time_scale = 0.5  # Slow motion effect during rewind

func _on_rewind_ended():
	# Restore normal appearance
	modulate = Color.WHITE
	Engine.time_scale = 1.0
	
func transition_to(new_position: Vector2):
	rewind_frames.clear()
	global_position = new_position
	camera.global_position = new_position
	camera.reset_smoothing()

var last_rewind_station_map := "start"
var last_rewind_station_position := Vector2(640, 0)

func spring_rewind(location: String, station_position: Vector2, overwind: bool):
	spring_tension = max_spring_tension
	is_overwound = overwind
	last_rewind_station_map = location
	last_rewind_station_position = station_position
	get_tree().current_scene.set_music_speed(2.0 if overwind else 1.0)

# Clean up when character is removed
func _exit_tree():
	if RewindSystem.is_rewinding:
		RewindSystem.stop_rewind()

# --- Invulnerability ---
func start_invulnerability():
	is_invulnerable = true
	$InvulnerabilityTimer.start()
	
	# Create a blinking effect by modulating the sprite's alpha
	invulnerability_tween = create_tween()
	invulnerability_tween.set_loops() # Loop until manually killed
	invulnerability_tween.tween_property(sprite, "modulate:a", 0.3, 0.1) # Fade out
	invulnerability_tween.tween_property(sprite, "modulate:a", 1.0, 0.1) # Fade in
	# This tween will loop until we kill it in _on_invulnerability_timer_timeout

# --- TIMER SIGNAL CALLBACKS ---
func _on_coyote_timer_timeout():
	can_coyote_jump = false

func _on_jump_buffer_timer_timeout():
	has_jump_buffer = false

func _on_invulnerability_timer_timeout() -> void:
	if invulnerability_tween:
		$Sprite2D.modulate.a = 1.0
		invulnerability_tween.kill()
		invulnerability_tween = null
		is_invulnerable = false

func play_hit():
	$HitSound.pitch_scale = randf_range(0.8, 1.2)
	$HitSound.play()
