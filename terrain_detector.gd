extends Area2D

enum TerrainType {
	Road = 1,
	Sand = 2
}

# dumb implementation to avoid case where you enter and exit at same time (resulting in clobbered forces)
var tile_collisions_sand: int = 0

signal friction_changed(f)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	_process_tile_map_collision(body, body_rid, "entered")

func _process_tile_map_collision(body: Node2D, body_rid: RID, entered_or_exited: String):
	if !is_instance_of(body, TileMapLayer):
		return
	
	var layer: TileMapLayer = body
	var coords = layer.get_coords_for_body_rid(body_rid)
	var tile_data = layer.get_cell_tile_data(coords)

	var terrain_type = tile_data.get_custom_data("terrain_type")
	if terrain_type is int:
		_process_terrain_type(terrain_type, entered_or_exited)

func _process_terrain_type(terrain_type: int, entered_or_exited: String):	
	match terrain_type:
		TerrainType.Road:
			pass
		TerrainType.Sand:
			tile_collisions_sand += 1 if entered_or_exited == "entered" else -1
	
	if tile_collisions_sand > 0:
		friction_changed.emit(0.25)
	else:
		friction_changed.emit(1.0)

func _on_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	_process_tile_map_collision(body, body_rid, "exited")
