extends Node2D
class_name RadialGun

var enable_gun = false
var shoot_interval: float = 1.0
var bullet_damage: float = 10.0

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
	var angle_step = TAU / point_count
	for i in range(point_count):
		var angle = i * angle_step
		var point = Vector2(
			global_position[0] + radius * cos(angle),
			global_position[1] + radius * sin(angle)
		)
		
		var bullet: Bullet = bullet_scene.instantiate()
		bullet.position = global_position
		bullet.direction = global_position.direction_to(point)
		bullet.damage = bullet_damage

		get_parent().get_parent().add_child(bullet)

func _on_shoot_timer_timeout() -> void:
	shoot()
