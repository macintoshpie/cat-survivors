extends Node

var straight_scene = preload("res://straight.tscn") as PackedScene
var curve_scene = preload("res://curve.tscn") as PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Car/Music.play()
	generate_random_map()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_finish_line_lap_completed(time: float) -> void:
	$LastLap.text = str(time)


func _on_car_hit_wall() -> void:
	$Car/Camera2D.apply_shake()

var MAP_STRAIGHT = 0
var MAP_CURVE_LEFT = 1
var MAP_CURVE_RIGHT = 2
var MAP_SECTIONS = [MAP_STRAIGHT, MAP_CURVE_LEFT, MAP_CURVE_RIGHT]

func generate_random_map() -> void:
	var next_pos = Vector2(0, 0)
	var next_rot = 0.0
	for section_type in [MAP_STRAIGHT, MAP_CURVE_LEFT, MAP_STRAIGHT]: #range(10):
		#var section_type = MAP_SECTIONS.pick_random()
		#var updates = render_map_section(section_type, next_pos, next_rot)
		#next_pos = updates[0]
		#next_rot = updates[1]
		var updates = render_type(section_type, next_pos, next_rot)
		next_pos = updates[0]
		next_rot = updates[1]

func render_type(section_type: int, pos: Vector2, rot: float) -> Array:
	var section_width = 20
	var tile_width = 64
	var section: TileMapLayer
	var forward_vector = Vector2(sin(rot), cos(rot)).normalized()

	if section_type == MAP_STRAIGHT:
		# instantiate straight section
		section = straight_scene.instantiate()
		section.position = pos
		add_child(section)

		# calculate new position by moving forward along the forward vector
		var end_pos = pos + forward_vector * section_width * tile_width
		return [end_pos, rot]
	
	elif section_type == MAP_CURVE_RIGHT:
		# instantiate curve section
		section = curve_scene.instantiate()
		section.position = pos
		add_child(section)

		# flip the section to the right by scaling
		section.apply_scale(Vector2(-1, 1))
		
		# calculate the end position after the curve (right turn)
		var end_pos = pos + forward_vector * section_width * tile_width
		
		# rotate by -90 degrees for the right turn
		var new_rot = rot - PI / 2
		return [end_pos, new_rot]
	
	elif section_type == MAP_CURVE_LEFT:
		# instantiate curve section
		section = curve_scene.instantiate()
		section.position = pos
		add_child(section)

		# for the left turn, keep normal scaling
		# calculate the end position after the curve (left turn)
		var end_pos = pos + forward_vector * section_width * tile_width
		
		# rotate by +90 degrees for the left turn
		var new_rot = rot + PI / 2
		return [end_pos, new_rot]
	
	return [pos, rot]  # fallback in case no section matches

var track_width = 50
func render_map_section(section_type: int, pos: Vector2, rot: float):
	var blocks_in_section = 100
	match section_type:
		MAP_STRAIGHT:
			var forward_vector = Vector2(sin(rot), cos(rot)).normalized()
			for i in range(blocks_in_section):
				# calculate the position along the rotated forward vector
				var this_pos = pos + forward_vector * i
				$Map.set_cell(this_pos, 0, Vector2i(0, 1), 0)
			
			# return the final position after placing the straight section
			var end_pos = pos + forward_vector * blocks_in_section
			return [end_pos, rot]
		MAP_CURVE_LEFT:
			# we want to build a quarter-circle, so we rotate incrementally
			var curve_radius = 50  # adjust this to control the curve's size
			var angle_per_block = PI / 2 / blocks_in_section  # quarter circle divided into sections

			for i in range(blocks_in_section):
				# gradually rotate the forward vector for each block
				var angle = rot + angle_per_block * i
				var forward_vector = Vector2(sin(angle), cos(angle)).normalized()

				# calculate position along the curved path
				var this_pos = pos + forward_vector * curve_radius
				$Map.set_cell(this_pos, 0, Vector2i(0, 1), 0)

			# return the final position after placing the curve section
			var final_angle = rot + PI / 2  # quarter-circle rotation
			var end_pos = pos + Vector2(sin(final_angle), cos(final_angle)).normalized() * curve_radius
			return [end_pos, final_angle]
