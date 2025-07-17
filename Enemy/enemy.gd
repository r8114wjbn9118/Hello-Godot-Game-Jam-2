extends CharacterBody2D

@export var move_range: float = 100.0
@export var move_speed: float = 50.0
@export var attack_interval: float = 1.5
@export var projectile_scene:PackedScene = preload("uid://b10toam7kox7r")

var direction: int = 1
var origin_y: float = 0.0
var health: int = 10
var max_health: int = 10

func _ready() -> void:
	origin_y = global_position.y
	add_to_group("Enemy")	# 加入 Enemy 群組

	# 初始化血條（TextureProgressBar）
	if has_node("HealthBar"):
		$HealthBar.max_value = max_health
		$HealthBar.value = health

	_fire_loop()	# 啟動攻擊迴圈

func _physics_process(delta: float) -> void:
	velocity.y = move_speed * direction
	move_and_slide()

	if abs(global_position.y - origin_y) > move_range:
		direction *= -1

func _fire_loop() -> void:
	while health > 0:
		await get_tree().create_timer(attack_interval).timeout
		_fire_projectile()

func _fire_projectile() -> void:
	if projectile_scene:
		var p = projectile_scene.instantiate()
		p.global_position = $AttackSpawnPoint.global_position
		get_tree().current_scene.add_child(p)

func take_damage(amount: int) -> void:
	health -= amount
	if has_node("HealthBar"):
		$HealthBar.value = health

	print("Enemy took", amount, "damage. HP:", health)
	if health <= 0:
		_die()

func _die() -> void:
	print("Enemy died")
	queue_free()
