extends Area2D

func _ready() -> void:
	if not is_in_group("ladder"):
		add_to_group("ladder")  # 加入 "ladder" 群組
