extends Node2D
class_name ForwardGun

var enable_gun = true
var shoot_interval: float = 0.5

var bullet_damage: float = 10.0
var bullet_speed: float = 4000
var bullet_scale: float = 3.0

var point_count = 10
var radius = 100

var bullet_scene = preload("res://bullet.tscn") as PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# setup gun
	$ShootTimer.wait_time = shoot_interval
	if enable_gun:
		$ShootTimer.start()
	else:
		$ShootTimer.stop()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func shoot():
	var bullet: Bullet = bullet_scene.instantiate()
	bullet.position = global_position
	var angle = global_rotation - PI / 2
	bullet.direction = Vector2(cos(angle), sin(angle)).normalized()
	bullet.damage = bullet_damage
	bullet.speed = bullet_speed
	bullet.scale = Vector2(bullet_scale, bullet_scale)
	get_parent().get_parent().add_child(bullet)

func _on_shoot_timer_timeout() -> void:
	shoot()
