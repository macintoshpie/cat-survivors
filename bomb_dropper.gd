extends Node2D
class_name BombDropper

var enable_gun = false
var shoot_interval: float = 2.0

var bomb_damage: float = 20.0
var bomb_scale: float = 1.0

var bomb_scene = preload("res://bomb.tscn") as PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if enable_gun:
		$ShootTimer.wait_time = shoot_interval
		$ShootTimer.start()

func upgrade():
	if !enable_gun:
		enable_gun = true
		$ShootTimer.wait_time = shoot_interval
		$ShootTimer.start()
	else:
		$ShootTimer.wait_time *= 0.85

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func shoot():
	var bomb: Bomb = bomb_scene.instantiate()
	bomb.position = global_position
	bomb.damage = bomb_damage
	bomb.scale = Vector2(bomb_scale, bomb_scale)
	get_parent().get_parent().add_child(bomb)


func _on_shoot_timer_timeout() -> void:
	shoot()
