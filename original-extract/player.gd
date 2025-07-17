extends CharacterBody2D

# --- 移動與重力變數 ---
@export var move_speed: float = 450.0				# 水平移動速度
@export var climb_speed: float = 300.0				# 爬梯速度
@export var gravity: float = 9000.0					# 重力加速度

var health: int = 5		# 玩家最大血量為 5
# --- 狀態控制 ---
var is_on_ladder: bool = false						# 是否正在碰到梯子

var has_item_on_head: bool = false	# 頭上是否已有道具
var attached_item: Node2D = null				# 頭上的道具參考


func _ready() -> void:
	add_to_group("player")	# 將玩家加入 "player" 群組

func _physics_process(delta: float) -> void:
	# --- 取得輸入 ---
	var input_dir: Vector2 = Vector2.ZERO
	input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	if has_item_on_head and Input.is_action_just_pressed("ui_accept"):
		_drop_item()
	# --- 梯子狀態 ---
	if is_on_ladder:
		# 取消重力，使用 Y 軸輸入
		velocity.y = input_dir.y * climb_speed
	else:
		# 正常重力邏輯
		velocity.y += gravity * delta

	# --- 水平移動 ---
	velocity.x = input_dir.x * move_speed

	# --- 移動角色 ---
	move_and_slide()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("ladder"):
		is_on_ladder = true
		velocity = Vector2.ZERO

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("ladder"):
		is_on_ladder = false

func _drop_item() -> void:
	if attached_item:
		attached_item.detach_from_player()		# 呼叫道具的離開函式
		attached_item = null
		has_item_on_head = false

func take_damage(amount: int) -> void:
	health -= amount
	print("Player took", amount, "damage. HP:", health)
	if health <= 0:
		_die()

func _die() -> void:
	print("Player died")
	queue_free()			# 可改成觸發死亡動畫或遊戲結束畫面
