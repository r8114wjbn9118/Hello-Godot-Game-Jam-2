extends Node2D

var pickup_item_scene: PackedScene = preload("uid://imf5lq5ciyvw")

var active_items: Array[Node2D] = []			# 場上有效的道具

@onready var SpawnPoint_list = %SpawnPoint		# 所有生成點位

func _ready() -> void:
	# 每 1 秒檢查一次是否需要補道具
	var check_timer := Timer.new()
	check_timer.wait_time = 1.0
	check_timer.timeout.connect(_check_and_spawn_items)
	check_timer.autostart = true
	check_timer.one_shot = false
	add_child(check_timer)

func _check_and_spawn_items() -> void:
	# 移除已經不存在的道具（例如被丟出、queue_free）
	active_items = active_items.filter(
		func(item): return is_instance_valid(item) and _is_item_still_on_point(item)
	)

	if active_items.size() <= 1:
		_spawn_random_items(2)

func _spawn_random_items(count: int) -> void:
	var available_points := SpawnPoint_list.get_children().duplicate()
	available_points.shuffle()

	for i in range(min(count, available_points.size())):
		var point: Node2D = available_points[i]
		var item: Node2D = pickup_item_scene.instantiate()
		item.global_position = point.global_position
		add_child(item)
		active_items.append(item)

# 判斷道具是否仍在生成點上（未移動代表未被玩家撿起或丟出）
func _is_item_still_on_point(item: Node2D) -> bool:
	for point in SpawnPoint_list.get_children():
		if item.global_position.distance_to(point.global_position) < 1.0:
			return true
	return false
