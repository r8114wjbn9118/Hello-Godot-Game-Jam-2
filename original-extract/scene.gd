extends Node2D

var pickup_item_scene: PackedScene = preload("res://pickup_item.tscn")

var spawn_points: Array[Node2D] = []			# 所有生成點位
var active_items: Array[Node2D] = []			# 場上有效的道具

func _ready() -> void:
	# 收集所有 spawn points（名稱以 SpawnPoint 開頭）
	for child in get_children():
		if child.name.begins_with("SpawnPoint"):
			spawn_points.append(child)

	# 每 1 秒檢查一次是否需要補道具
	var check_timer := Timer.new()
	check_timer.wait_time = 1.0
	check_timer.timeout.connect(_check_and_spawn_items)
	check_timer.autostart = true
	check_timer.one_shot = false
	add_child(check_timer)

func _check_and_spawn_items() -> void:
	# 移除已經不存在的道具（例如被丟出、queue_free）
	active_items = active_items.filter(func(item): return is_instance_valid(item) and _is_item_still_on_point(item))

	if active_items.size() <= 1:
		_spawn_random_items(2)

func _spawn_random_items(count: int) -> void:
	var available_points := spawn_points.duplicate()
	available_points.shuffle()

	for i in range(min(count, available_points.size())):
		var point: Node2D = available_points[i]
		var item: Node2D = pickup_item_scene.instantiate()
		item.global_position = point.global_position
		add_child(item)
		active_items.append(item)

# 判斷道具是否仍在生成點上（未移動代表未被玩家撿起或丟出）
func _is_item_still_on_point(item: Node2D) -> bool:
	for point in spawn_points:
		if item.global_position.distance_to(point.global_position) < 1.0:
			return true
	return false
