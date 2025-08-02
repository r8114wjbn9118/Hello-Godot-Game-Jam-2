class_name Player
extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0

var current_direction = true
var pickup_item = null

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
		current_direction = true
	elif direction < 0:
		animated_sprite.flip_h = true
		current_direction = false
	
	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_pressed("accept") \
	and pickup_item:
		throw()

func pickup(item:Item) -> bool:
	printt("pickup", item)
	if not pickup_item and not item.in_throw:
		pickup_item = item
		item.reparent(%PickupMarker)
		item.position = Vector2.ZERO
		return true
	return false

func throw():
	printt("throw", pickup_item)
	pickup_item.reparent($ThrowMarker)
	pickup_item.position = Vector2.ZERO
	
	var vec = Vector2.RIGHT if current_direction else Vector2.LEFT
	pickup_item.throw(vec * SPEED)
	pickup_item = null
