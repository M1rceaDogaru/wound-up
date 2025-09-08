extends CharacterBody2D

# Movement Properties
@export var max_speed: float = 240.0
@export var acceleration: float = 1800.0
@export var friction: float = 2400.0
@export var jump_velocity: float = -480.0

# Quality of Life Properties
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1

# Spring Tension Properties
@export var max_spring_tension: float = 100.0
@export var spring_depletion_rate: float = 5.0 # Tension lost per second
@export var sprint_depletion_multiplier: float = 2.5
@export var damage_depletion_amount: float = 25.0

# Get the gravity from the project settings so you can sync with rigid body nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# State Variables
var spring_tension: float
var is_sprinting: bool = false
var is_overwound: bool = false
var was_on_floor: bool = false

# Quality of Life Variables
var can_coyote_jump: bool = false
var has_jump_buffer: bool = false

# Node References
@onready var coyote_timer = $CoyoteTimer
@onready var jump_buffer_timer = $JumpBufferTimer

func _ready():
	spring_tension = max_spring_tension
	coyote_timer.connect("timeout", _on_coyote_timer_timeout)
	coyote_timer.wait_time = coyote_time
	jump_buffer_timer.connect("timeout", _on_jump_buffer_timer_timeout)
	jump_buffer_timer.wait_time = jump_buffer_time

func _physics_process(delta):
	# --- SPRING TENSION MANAGEMENT ---
	# Calculate base depletion rate
	var current_depletion_rate = spring_depletion_rate
	if is_sprinting:
		current_depletion_rate *= sprint_depletion_multiplier
	if is_overwound:
		current_depletion_rate *= 5.0 # Example multiplier for overwound state
	
	# Deplete the spring
	spring_tension -= current_depletion_rate * delta
	spring_tension = clamp(spring_tension, 0.0, max_spring_tension)
	
	# Check for game over
	if spring_tension <= 0.0:
		game_over("Spring Unwound!")
		return
	
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
	
	# Apply jump if we have a buffered jump and are now able to jump
	if has_jump_buffer and (is_on_floor() or can_coyote_jump):
		perform_jump()
	
	was_on_floor = is_on_floor()
	move_and_slide()
	
	# --- DEBUG / UI UPDATE ---
	# This will be replaced by a proper UI signal later
	#print("Spring Tension: ", spring_tension)

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
	is_sprinting = Input.is_action_pressed("sprint")
	
	if horizontal_input != 0:
		# Apply acceleration, respecting the sprint input
		var target_speed = horizontal_input * max_speed
		if is_sprinting and spring_tension > 0:
			target_speed *= 1.6 # Sprint speed multiplier
		
		velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)
		
		# Flip sprite to face direction of movement
		if horizontal_input > 0:
			$Sprite2D.flip_h = false
		elif horizontal_input < 0:
			$Sprite2D.flip_h = true
	else:
		# Apply friction when no input
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func perform_jump():
	velocity.y = jump_velocity
	can_coyote_jump = false
	has_jump_buffer = false
	coyote_timer.stop()
	jump_buffer_timer.stop()
	# Play jump sound effect here later

func take_damage():
	spring_tension -= damage_depletion_amount
	# Add knockback, invulnerability frames, etc. here later

func rewind_at_station():
	spring_tension = max_spring_tension
	is_overwound = false # Reset overwound state when safely rewound
	# Play sound effect, maybe particles

func game_over(reason: String):
	print("Game Over: ", reason)
	# This will be replaced by a game over screen restart
	get_tree().reload_current_scene()

# --- TIMER SIGNAL CALLBACKS ---
func _on_coyote_timer_timeout():
	can_coyote_jump = false

func _on_jump_buffer_timer_timeout():
	has_jump_buffer = false
