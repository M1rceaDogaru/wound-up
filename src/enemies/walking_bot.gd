extends Area2D

@export var health: int = 1
@export var stomp_bounce_force: float = -300.0 # The upward force applied to the player

@onready var stomp_area = $StompArea
@onready var sprite = $Sprite2D
@onready var explosion = preload("res://particles/explosion.tscn")

var invulnerability_tween: Tween
var is_invulnerable = false
var last_position := Vector2.ZERO

func _ready():
	# Connect the area's signal to a function
	stomp_area.body_entered.connect(_on_stomp_area_body_entered)
	if $AnimationPlayer:
		$AnimationPlayer.play("move")
	
func _physics_process(delta: float) -> void:
	sprite.flip_h = last_position.x - global_position.x < 0
	last_position = global_position

func take_damage(source):
	if is_invulnerable:
		return
	
	create_explosion(source)
	start_invulnerability()
	health -= 1
	if health <= 0:
		die()

func die():
	# Play death animation, sound, spawn particles, then queue_free
	queue_free()

func _on_stomp_area_body_entered(body):
	# Check if the body that entered the area is the player
	if body.is_in_group("player"):
		# Check if the player is falling onto the enemy (velocity.y > 0)
		# This prevents bouncing if the player hits from the side or below
		if body.velocity.y > 0:
			# Tell the player to bounce!
			body.bounce_from_stomp(stomp_bounce_force)
			# Damage the enemy
			take_damage(body)
			body.play_hit()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(global_position)

func start_invulnerability():
	is_invulnerable = true
	$InvulnerabilityTimer.start()
	
	# Create a blinking effect by modulating the sprite's alpha
	invulnerability_tween = create_tween()
	invulnerability_tween.set_loops() # Loop until manually killed
	invulnerability_tween.tween_property(sprite, "modulate:a", 0.3, 0.1) # Fade out
	invulnerability_tween.tween_property(sprite, "modulate:a", 1.0, 0.1) # Fade in
	# This tween will loop until we kill it in _on_invulnerability_timer_timeout

func _on_invulnerability_timer_timeout() -> void:
	if invulnerability_tween:
		sprite.modulate.a = 1.0
		invulnerability_tween.kill()
		invulnerability_tween = null
		is_invulnerable = false
		
func create_explosion(source):
	var new_explosion = explosion.instantiate()
	new_explosion.global_position = source.global_position
	get_tree().current_scene.add_child(new_explosion)
