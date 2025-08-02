class_name Item
extends CharacterBody2D

var player = null
var in_throw = false

var item_node:Node2D


func init(
	new_pos:Vector2,
	image_type:Vector2i = Vector2i.ZERO,
):
	printt(new_pos, image_type)
	position = new_pos
	%Image.frame_coords = image_type



func _ready() -> void:
	item_node = get_parent()

func _process(delta: float) -> void:
	if in_throw and move_and_slide():
		var collision = get_last_slide_collision()
		var collider = collision.get_collider()
		print(collider, collider is TileMap)
		if collider is TileMap:
			queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_pressed("accept") \
	and player:
		var result = player.pickup(self)
		if result:
			get_viewport().set_input_as_handled()



func throw(vec):
	reparent(item_node)
	rotation_degrees = 90
	velocity = vec
	set_collision_layer_value(2, true)
	in_throw = true



func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null
