extends Area2D

@export var speed: float = 250.0
@export var life_time: float = 3.0	# 投射物壽命（秒）

func _ready() -> void:
	connect("body_entered", _on_body_entered)
	_auto_destroy()

func _process(delta: float) -> void:
	position.x -= speed * delta		# 向左飛行

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(1)
		queue_free()

func _auto_destroy() -> void:
	await get_tree().create_timer(life_time).timeout
	if is_instance_valid(self):
		queue_free()
