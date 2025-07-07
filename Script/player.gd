extends CharacterBody2D

## 移動速度曲線
@export var move_curve:Curve

## 離開地板後仍可跳躍的時間
@export var can_jump_max_duration:float = 0.33
## 跳躍高度曲線
@export var jump_curve:Curve


## 可以對角色進行操作的指標
var can_control:bool = true
## 輸入方向
var move_index:Vector2 = Vector2.ZERO

## 移動計時
var move_timer:float = 0.0
## -1:左		1:右
var move_direction:float = 0:
	set(value):
		if move_direction != value:
			move_timer = 0.0
		move_direction = value

## 離開地板後仍可跳躍的時間計時
var can_jump_timer:float = 0
## 跳躍計時
var jump_timer:float = 0.0
## -1:上		1:下
var jump_direction:float = 0:
	set(value):
		if jump_direction != value:
			jump_timer = 0.0
		jump_direction = value



func _physics_process(delta: float) -> void:
	move(delta)
	jump(delta)
	
	if move_direction == 0:
		velocity.x = 0
	else:
		velocity.x = move_direction * move_curve.sample(move_timer)
	if jump_direction == 0:
		velocity.y = 0
	else:
		velocity.y = jump_direction * jump_curve.sample(jump_timer)
	
	if move_and_slide():
		if is_on_wall():
			move_direction = 0
		if is_on_ceiling():
			jump_direction = 0

	printt(
		move_index, velocity,
		move_direction, move_timer,
		jump_direction, jump_timer
	)

func _unhandled_input(event: InputEvent) -> void:
	if can_control:
		move_index = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	else:
		move_index = Vector2.ZERO

# 行走
func move(delta):
	if move_index.x != 0.0:
		var input_direction:int = 1 if move_index.x > 0 else -1
		
		# 若反方向移動, 把計時逐漸降低至0
		# 否則把計時逐漸增加至move_curve的最大值
		#
		# ps. move_timer計時是move_curve(移動速度)的指標
		if move_direction != input_direction:
			if move_timer > 0.0:
				move_timer = max(0.0, move_timer - delta * 2)
			if move_timer == 0.0:
				move_direction = input_direction
		elif move_timer < move_curve.max_domain:
			move_timer = min(move_curve.max_domain, move_timer + delta)

	else:
		if move_direction != 0:
			move_timer = max(0.0, move_timer - delta)
			if move_timer == 0.0:
				move_direction = 0

# 跳躍
func jump(delta):
	# 正在跳躍中 或 (輸入跳躍指令 而且 可以跳躍)
	if jump_direction == -1 \
	or move_index.y < 0 and can_jump_timer > 0.0:
		can_jump_timer = 0.0
		jump_direction = -1

		jump_timer = min(jump_curve.max_domain, jump_timer + delta)
		# 已經跳到最高, 轉為落下
		if jump_timer == jump_curve.max_domain:
			jump_direction = 1
	
	# 在地面
	elif is_on_floor():
		jump_direction = 0
		can_jump_timer = can_jump_max_duration

	# 落下
	elif jump_direction == 1:
		if jump_timer < jump_curve.max_domain:
			jump_timer = min(jump_curve.max_domain, jump_timer + delta / 2)

	else:
		jump_direction = 1
		if can_jump_timer > 0.0:
			can_jump_timer -= delta
