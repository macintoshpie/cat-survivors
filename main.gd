extends Node

var straight_scene = preload("res://straight.tscn") as PackedScene
var curve_scene = preload("res://curve.tscn") as PackedScene
var obstacle_scene = preload("res://obstacle.tscn") as PackedScene
var coin_scene = preload("res://coin.tscn") as PackedScene
var gate_scene = preload("res://gate.tscn") as PackedScene
var enemy_scene = preload("res://enemy.tscn") as PackedScene

@onready var car: Car = $Car
@onready var music = $Car/Music
@onready var camera = $Car/Camera2D
@onready var level_up_screen = $LevelUpScreen

var state = &"driving"
var score: int = 0
var next_level_score: int = 30

var current_gate_time: int = 0
var gate_time_start_value: int = 100
var current_lap_time: float = 0
var lap_times: Array[float] = []

var width = null
var height = null
var screen_upper_left = Vector2.ZERO
var screen_bottom_right = Vector2.ZERO

var current_gate_idx = 0
var all_gates: Array[Gate] = []

var _disable_enemies = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music.play()
	level_up_screen.hide()
	
	var size = get_viewport().size
	width = size[0]
	height = size[1]
	
	var all_children = $Gates.get_children()
	for child in all_children:
		if is_instance_of(child, Gate):
			all_gates.append(child)
			
	all_gates.shuffle()
	all_gates[current_gate_idx].show_gate()
	current_gate_time = gate_time_start_value
	$GateTimeTick.start()

	if _disable_enemies:
		$SpawnEnemy.stop()
		$SpawnSuperEnemy.stop()

	show_level_up_screen(3)

	#
	#var tile_map_layer: TileMapLayer = $TileMapLayer
	#var texture_image: Image = Image.load_from_file("res://art/roadTextures_tilesheet.png")
	#var cell_width = 64
	#var sub_cell_width = 8
	#for cell_pos in tile_map_layer.get_used_cells():
		#var cell_atlas_coords = tile_map_layer.get_cell_atlas_coords(cell_pos)
		#var texture_coords = cell_atlas_coords * cell_width
		#for x in range(cell_width):
			#for y in range(cell_width):
				#var pixel = texture_image.get_pixel(texture_coords[0] + x, texture_coords[1] + y)
				#print(pixel)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Hide the arrow if the gate is on screen
	var scale = 1 / camera.zoom[0] # use zoom to determine how much we need to "scale" the screen
	screen_upper_left = car.global_position - Vector2(width / 2, height / 2) * scale
	screen_bottom_right = car.global_position + Vector2(width / 2, height / 2) * scale

	#$CanvasLayer/LastLap.text = "Health: " + str(car.health)
	#$CanvasLayer/HealthBar.scale = Vector2(car.health / 100, 1)
	$CanvasLayer/LastLap.text = "Level Up: " + str(score) + "/" + str(next_level_score)
	$CanvasLayer/LastLap.text += "\nGate Points Remaining: " + str(current_gate_time)

	var zoom = car.get_current_speed_frac()
	var min_zoom = 0.25
	var max_zoom =  0.3
	zoom = car.map_value(zoom, 1.0, 0.0, min_zoom, max_zoom)
	camera.zoom = Vector2(zoom, zoom)
	
	update_gate_arrow()

func update_gate_arrow() -> void:
	var current_gate = all_gates[current_gate_idx]

	if screen_upper_left[0] < current_gate.position[0] && current_gate.position[0] < screen_bottom_right[0] \
		&& screen_upper_left[1] < current_gate.position[1] && current_gate.position[1] < screen_bottom_right[1]:
			if $GateHint/Arrow.visible:
				$GateHint/Arrow.visible = false
			return
	else:
		if !$GateHint/Arrow.visible:
			$GateHint/Arrow.visible = true

	var _from = car.global_position
	var _to = current_gate.position
	camera.get_viewport_rect()
	var current_gate_dir_vec = _from.direction_to(_to)
	var current_gate_dir = current_gate_dir_vec.angle() + PI / 2 # rotate 90 deg b/c sprite points up
	# pos of arrow is based on upper left screen being statically 0, 0
	var padding = 200
	var arbitrary_large_number = 1000 # use this to project beyond screen, we then clamp it down.
	var new_pos = Vector2(width / 2, height / 2) + (current_gate_dir_vec * arbitrary_large_number)
	new_pos = new_pos.clamp(Vector2(padding, padding), Vector2(width - padding, height - padding))
	$GateHint/Arrow.position = new_pos
	$GateHint/Arrow.rotation = current_gate_dir

func _on_finish_line_lap_completed(time: float) -> void:
	lap_times.push_back(time)

func _on_car_hit_wall() -> void:
	camera.apply_shake()	

# tbh this should probably just be tracked by the main game itself...
func _on_finish_line_time_passed(time: float) -> void:
	current_lap_time = time

func add_obstacle(pos) -> void:
	var obstacle: RigidBody2D = obstacle_scene.instantiate()
	obstacle.position = pos
	add_child(obstacle)

func add_coin(pos: Vector2) -> void:
	var coin: Area2D = coin_scene.instantiate()
	coin.position = pos
	add_child(coin)

func add_gate(pos: Vector2, rot: float) -> void:
	var gate: Node = gate_scene.instantiate()
	gate.center = pos
	gate.rotation_angle = rot
	add_child(gate)
	#gate.connect("activated", _on_gate_activated)

func instantiate_enemy(pos: Vector2, health: float = 20.0) -> Enemy:
	var enemy: Enemy = enemy_scene.instantiate()
	enemy.position = pos
	enemy.health = health

	return enemy

func add_enemy_to_scene(enemy: Enemy):
	add_child(enemy)

func _on_enemy_died(enemy: Enemy):
	return func() -> void:
		increase_score(enemy.score_value)

func _on_spawn_enemy_timeout() -> void:
	var pos = random_enemy_pos()
	var enemy = instantiate_enemy(pos)
	link_enemy_died_callback(enemy, _on_enemy_died(enemy))
	add_enemy_to_scene(enemy)

func random_enemy_pos():
	# random position at "edge" of screen
	var padding = 200
	var scale = 1 / camera.zoom[0]
	var radius = max(width / 2 * scale, height / 2 * scale) + padding
	var angle = randf() * PI * 2
	var x = cos(angle) * radius
	var y = sin(angle) * radius
	return Vector2(x, y) + car.position # spawn relative to car


func increase_score(amt: int):
	score += amt
	if score >= next_level_score:
		# grant a power up
		state = &"level_up"
		next_level_score *= 2
		show_level_up_screen(1)

func show_level_up_screen(max_equip: int) -> void:
	var upgrades = get_upgrade_options(max_equip)
	$LevelUpScreen.set_upgrades(upgrades)
	$LevelUpScreen.visibility(true)
	get_tree().paused = true

func _on_car_dead() -> void:
	get_tree().reload_current_scene()



func _on_difficulty_timer_timeout() -> void:
	$SpawnEnemy.timeout = $SpawnEnemy.timeout * 0.7
	$SpawnSuperEnemy.timeout = $SpawnSuperEnemy.timeout * 0.7

func _on_super_enemy_died(enemy: Enemy) -> Callable:
	return func() -> void:
		# TODO: do other super enemy stuff
		# But maybe this stuff should live in the enemy class. not sure
		_on_enemy_died(enemy).call()

func _on_spawn_super_enemy_timeout() -> void:
	var pos = random_enemy_pos()
	var enemy = instantiate_enemy(pos, 50)
	enemy.scale *= 1.5
	enemy.damage *= 1.5
	enemy.speed *= 1.5
	enemy.score_value = 100
	enemy.modulate = Color(1, 0, 0)
	link_enemy_died_callback(enemy, _on_super_enemy_died(enemy))
	add_enemy_to_scene(enemy)

func link_enemy_died_callback(enemy, callback: Callable):
	enemy.connect("died", callback)

func get_upgrade_options(max_equip: int):
	var max_upgrade_options = 3
	var options = []
	var num_unequipped = len(car.unequipped_weapons)
	if  num_unequipped > 0:
		print("NUM GETTING", min(max_equip, max_upgrade_options))
		var rand_weapons = pick_random(car.unequipped_weapons, min(max_equip, max_upgrade_options))
		print("NUM GOT", len(rand_weapons))
		for weapon in rand_weapons:
			var option = {
				"name": Car.WeaponDetails[weapon].name,
				"weapon": weapon,
				"action": "Equip"
			}
			options.append(option)

	var rand_upgrades = pick_random(car.equipped_weapons, max_upgrade_options - len(options))
	for weapon in rand_upgrades: 
		var option = {
			"name": Car.WeaponDetails[weapon].name,
			"weapon": weapon,
			"action": "Upgrade"
		}
		options.append(option)

	return options

func _on_level_up_screen_upgrade_selected(upgrade) -> void:
	car.upgrade(upgrade.weapon)
	$LevelUpScreen.visibility(false)
	get_tree().paused = false

func pick_random(options: Array, num: int) -> Array:
	var result = []
	var options_dupe = options.duplicate()
	options_dupe.shuffle()
	var num_to_pick = min(len(options_dupe), num)
	for i in range(0, num_to_pick):
		var option = options_dupe[i]
		result.append(option)
	
	return result


func _on_car_hit_gate(gate: Gate) -> void:
	increase_score(current_gate_time)
	current_gate_time = gate_time_start_value
	all_gates[current_gate_idx].hide_gate()

	current_gate_idx += 1
	if current_gate_idx >= len(all_gates):
		current_gate_idx = 0
		all_gates.shuffle()

	all_gates[current_gate_idx].show_gate()

	$FinishLine.add_time(-0.5)


func _on_gate_time_tick_timeout() -> void:
	current_gate_time = clampi(current_gate_time - 1, 10, 1000)
