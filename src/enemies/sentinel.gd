extends Area2D

@export var health: int = 5
@export var stomp_bounce_force: float = -500.0 # The upward force applied to the player

@onready var stomp_area = $StompArea

func _ready():
	# Connect the area's signal to a function
	stomp_area.body_entered.connect(_on_stomp_area_body_entered)

func take_damage(source):
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

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(global_position)
