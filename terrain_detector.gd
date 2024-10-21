extends Area2D

enum TerrainType {
	Road = 1,
	Sand = 2
}

signal friction_changed(f)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	print("ENTERED BODY SHAPE")
	print(body)
	_process_tile_map_collision(body, body_rid)

func _process_tile_map_collision(body: Node2D, body_rid: RID):
	if !is_instance_of(body, TileMapLayer):
		return
	
	var layer: TileMapLayer = body
	var coords = layer.get_coords_for_body_rid(body_rid)
	var tile_data = layer.get_cell_tile_data(coords)

	var terrain_type = tile_data.get_custom_data("terrain_type")
	if terrain_type is int:
		_process_terrain_type(terrain_type)

func _process_terrain_type(terrain_type: int):
	var friction = 1.0
	match terrain_type:
		TerrainType.Road:
			friction = 1.0
		TerrainType.Sand:
			friction = 0.25
	
	friction_changed.emit(friction)
