extends Area2D

# --- 狀態變數 ---
var player_in_range: Node2D = null
var is_attached: bool = false
var attached_player: Node2D = null
var is_thrown: bool = false
var throw_speed: float = 600.0
var lifetime_timer: Timer

func _ready() -> void:
	lifetime_timer = Timer.new()
	lifetime_timer.wait_time = 3.0
	lifetime_timer.one_shot = true
	lifetime_timer.timeout.connect(_on_lifetime_timeout)
	add_child(lifetime_timer)

	# --- 連接碰撞 ---
	connect("body_entered", _on_body_entered)

func _process(delta: float) -> void:
	if is_attached and attached_player:
		global_position = attached_player.global_position + Vector2(0, -32)

	elif is_thrown:
		position.x += throw_speed * delta

	elif not is_attached and player_in_range:
		if Input.is_action_just_pressed("ui_accept") and not player_in_range.has_item_on_head:
			_attach_to_player()

func _on_body_entered(body: Node2D) -> void:
	if is_thrown:
		# 命中敵人時造成傷害
		if body.is_in_group("Enemy") and body.has_method("take_damage"):
			body.take_damage(1)		# 命中敵人扣 1 點血
			queue_free()
			return

	# 玩家進入範圍（不影響飛行）
	if body.is_in_group("player"):
		player_in_range = body

func _on_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null

func _attach_to_player() -> void:
	is_attached = true
	attached_player = player_in_range
	attached_player.has_item_on_head = true
	attached_player.attached_item = self

func detach_from_player() -> void:
	is_attached = false
	is_thrown = true
	player_in_range = null
	attached_player = null
	lifetime_timer.start()

func _on_lifetime_timeout() -> void:
	queue_free()
