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
var next_level_score: int = 15

var current_lap_time: float = 0
var lap_times: Array[float] = []

var width = null
var height = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music.play()
	level_up_screen.hide()
	
	var size = get_viewport().size
	width = size[0]
	height = size[1]
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
	$CanvasLayer/LastLap.text = "Health: " + str(car.health)
	$CanvasLayer/LastLap.text += "\nScore: " + str(score)
	$CanvasLayer/LastLap.text += "\nCurrent: " + str(snapped(current_lap_time, 0.1))
	for i in range(lap_times.size()):
		$CanvasLayer/LastLap.text += "\nLap " + str(i + 1) + ": " + str(snapped(lap_times[i], 0.1))
		
	var zoom = car.get_current_speed_frac()
	var min_zoom = 0.1
	var max_zoom =  0.2
	zoom = car.map_value(zoom, 1.0, 0.0, min_zoom, max_zoom)
	camera.zoom = Vector2(zoom, zoom)

func _on_finish_line_lap_completed(time: float) -> void:
	lap_times.push_back(time)

func _on_car_hit_wall() -> void:
	camera.apply_shake()

func _on_gate_activated():
	$FinishLine.add_time(-0.5)

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
	gate.connect("activated", _on_gate_activated)

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
	var radius = max(width, height)
	var angle = randf() * PI * 2
	var x = cos(angle) * radius
	var y = sin(angle) * radius
	return Vector2(x, y) + car.position # spawn relative to car's position


func increase_score(amt: int):
	score += amt
	if score >= next_level_score:
		# grant a power up
		state = &"level_up"
		next_level_score *= 2
		level_up_screen.show()
		get_tree().paused = true

func _on_power_up_button_pressed() -> void:
	level_up_screen.hide()
	car.upgrade(0.85, 1.05, 1.05)
	get_tree().paused = false


func _on_car_dead() -> void:
	get_tree().reload_current_scene()


func _on_health_button_pressed() -> void:
	level_up_screen.hide()
	car.add_health(30)
	get_tree().paused = false


func _on_difficulty_timer_timeout() -> void:
	$SpawnEnemy.timeout = $SpawnEnemy.timeout * 0.85

func _on_super_enemy_died(enemy: Enemy) -> Callable:
	return func() -> void:
		# TODO: do other super enemy stuff
		# But maybe this stuff should live in the enemy class. not sure
		_on_enemy_died(enemy).call()

func _on_spawn_super_enemy_timeout() -> void:
	var pos = random_enemy_pos()
	var enemy = instantiate_enemy(pos, 50)
	enemy.score_value = 100
	enemy.modulate = Color(1, 0, 0)
	link_enemy_died_callback(enemy, _on_super_enemy_died(enemy))
	add_enemy_to_scene(enemy)

func link_enemy_died_callback(enemy, callback: Callable):
	enemy.connect("died", callback)
