extends CharacterBody2D

## 移動速度
@export var move_speed:float = 150.0

## 離開地板後仍可跳躍的時間
@export var can_jump_duration:float = 0.5
## 跳躍/掉落速度
@export var jump_speed:float = 300.0
## 跳躍持續時間
@export var jump_duration:float = 1.0
## 掉落的最大速度, 當此值為0時無限制
@export var fall_max_speed:float = 0.0



## 可以對角色進行操作的指標
var can_control:bool = true
## 輸入方向
var move_index:Vector2 = Vector2.ZERO

## 移動計時
var move_timer:float = 0.0
## -1:左		1:右
var move_direction:float = 0

## 離開地板後仍可跳躍的時間計時
var can_jump_timer:float = 0
## 跳躍計時
var jump_timer:float = 0.0
## -1:上		1:下
var jump_direction:float = 0



func _physics_process(delta: float) -> void:
	move(delta)
	jump(delta)

	if move_and_slide():
		if is_on_wall():
			move_direction = 0
		if is_on_ceiling():
			jump_direction = 0

	if move_index != Vector2.ZERO:
		printt(
			move_index, velocity,
			move_direction, move_timer,
			jump_direction, jump_timer
		)

func _unhandled_input(_event: InputEvent) -> void:
	if can_control:
		move_index = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	else:
		move_index = Vector2.ZERO

# 行走
func move(_delta):
	if move_index.x == 0.0:
		move_direction = 0
	else:
		move_direction = 1 if move_index.x > 0 else -1

	# 修改橫向移動速度
	var speed = 0
	if move_direction != 0:
		speed = move_direction * move_speed
	velocity.x = speed

# 跳躍
func jump(delta):
	# 輸入跳躍指令 而且 可以跳躍
	if move_index.y < 0 and can_jump_timer > 0.0:
		can_jump_timer = 0.0
		jump_direction = -1
		jump_timer = jump_duration

	# 跳躍
	if jump_direction == -1:
		jump_timer = max(0.0, jump_timer - delta)
		# 已經跳到最高, 轉為落下
		if jump_timer == 0.0:
			jump_direction = 1
	# 在地面
	elif is_on_floor():
		can_jump_timer = can_jump_duration
		jump_direction = 0
		jump_timer = 0.0
	# 落下
	elif jump_direction == 1:
		jump_timer += delta
	else:
		jump_direction = 1
		if can_jump_timer > 0.0:
			can_jump_timer -= delta

	# 修改高度移動速度
	var speed = 0
	if jump_direction != 0:
		speed = jump_direction * jump_timer * jump_speed
		if jump_direction == 1 and fall_max_speed > 0.0:
			speed = min(fall_max_speed, speed)
	velocity.y = speed
