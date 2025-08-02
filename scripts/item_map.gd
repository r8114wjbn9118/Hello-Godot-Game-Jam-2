extends TileMapLayer

var item_scene = preload("uid://bcve3hepu83ix")

func _ready() -> void:
	create_item()

func create_item():
	for cell in get_used_cells():
		var spwan_pos = map_to_local(cell)
		var item_type_pos = get_cell_atlas_coords(cell)
		
		set_cell(cell)

		var node = item_scene.instantiate()
		node.init(spwan_pos, item_type_pos)
		%Items.add_child(node)
