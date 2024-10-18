extends Node

var straight_scene = preload("res://straight.tscn") as PackedScene
var curve_scene = preload("res://curve.tscn") as PackedScene
var obstacle_scene = preload("res://obstacle.tscn") as PackedScene
var coin_scene = preload("res://coin.tscn") as PackedScene
var gate_scene = preload("res://gate.tscn") as PackedScene

var current_lap_time: float = 0
var lap_times: Array[float] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$Car/Music.play()
	var prev_point = Vector2()  # start with an empty vector
	var p_width = 20
	
	## shift points around a bit using random offset
	#var shift_amount = 20
	#for i in range(0, $Path2D2.curve.point_count):
		#var p = $Path2D2.curve.get_point_position(i)
		#
		#var newp = p + Vector2(randf_range(-shift_amount, shift_amount), randf_range(-shift_amount, shift_amount))
		#$Path2D2.curve.set_point_position(i, newp)
	#
	## make it curvy by setting the point out
	#for i in range(1, $Path2D2.curve.point_count):
		#var p = $Path2D2.curve.get_point_position(i)
		#var pp = $Path2D2.curve.get_point_position(i - 1)
		#
		## calculate the vector and the perpendicular
		#var v1 = (p - pp).normalized()  # direction vector from prev to current point
		#var pdist = abs((p - pp).length()) / 5
		#$Path2D2.curve.set_point_out(i, v1 * pdist)

	# curve_start is the negative x,y of the first point in the path
	var curve_start = Vector2(-128, -128)
	var da_path = $Path2D
	var obstacle_frequency = 0.05
	var coin_frequency = 0.1
	# render the baked result
	for i in range(1, da_path.curve.get_baked_points().size()):  # start from 1 to skip the first invalid prev_point
		var p = da_path.curve.get_baked_points()[i]
		prev_point = da_path.curve.get_baked_points()[i - 1]

		# calculate the vector and the perpendicular
		var v1 = p - prev_point  # direction vector from prev to current point
		var perpendicular = Vector2(-v1.y, v1.x).normalized()  # correct perpendicular calculation

		# draw the block on both sides of the point
		var d1 = p + perpendicular * p_width + (curve_start)
		var d2 = p - perpendicular * p_width + (curve_start)
		$Map.set_cell(Vector2i(d1), 0, Vector2i(0, 1), 0)
		$Map.set_cell(Vector2i(d2), 0, Vector2i(0, 1), 0)
				
		prev_point = p
		
		#if randf() < obstacle_frequency:
			#var obstacle: RigidBody2D = obstacle_scene.instantiate()
			#var random_offset = Vector2(randf_range(-p_width, p_width), randf_range(-p_width, p_width))
			#obstacle.position = (p + curve_start + random_offset) * 64
			#add_child(obstacle)
		#elif randf() < coin_frequency:
			#var coin: Area2D = coin_scene.instantiate()
			#coin.position = (p + curve_start) * 64 
			#add_child(coin)
	
		if randf() < 0.1:
			var gate: Node = gate_scene.instantiate()
			#gate.position = Vector2(0, 0)
			gate.center = (p + curve_start) * 64
			gate.rotation_angle = perpendicular.angle()
			add_child(gate)
			gate.connect("activated", _on_gate_activated)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$CanvasLayer/LastLap.text = "Current: " + str(snapped(current_lap_time, 0.1))
	for i in range(lap_times.size()):
		$CanvasLayer/LastLap.text += "\nLap " + str(i + 1) + ": " + str(snapped(lap_times[i], 0.1))

func _on_finish_line_lap_completed(time: float) -> void:
	lap_times.push_back(time)


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

func _on_gate_activated():
	$FinishLine.add_time(-0.5)


# tbh this should probably just be tracked by the main game itself...
func _on_finish_line_time_passed(time: float) -> void:
	current_lap_time = time
