extends Node2D
class_name Gun

var enable_gun = false
var shoot_interval: float = 1.0
var bullet_damage: float = 10.0

var enemies: Array[Enemy] = []

var bullet_scene = preload("res://bullet.tscn") as PackedScene
var homing_bullet_scene = preload("res://homing_bullet.tscn") as PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

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

func shoot_at_enemy(enemy: Enemy):
	var bullet: HomingBullet = homing_bullet_scene.instantiate()
	bullet.target = enemy
	bullet.position = global_position
	bullet.direction = global_position.direction_to(enemy.position)
	bullet.scale = Vector2(2, 2)
	bullet.modulate = Color(1, 1, 0)
	bullet.damage = bullet_damage

	get_parent().get_parent().add_child(bullet)

func _on_shoot_range_area_entered(area: Area2D) -> void:
	if is_instance_of(area, Enemy):
		enemies.append(area)


func _on_shoot_range_area_exited(area: Area2D) -> void:
	enemies = enemies.filter(func(enemy: Enemy):
		return enemy.get_instance_id() != area.get_instance_id()
	)


func _on_shoot_timer_timeout() -> void:
	var closest_enemy = null
	var dist = INF
	for enemy in enemies:
		var enemy_dist = enemy.position.distance_to(position)
		if enemy_dist < dist:
			closest_enemy = enemy
			dist = enemy_dist
	
	if closest_enemy:
		shoot_at_enemy(closest_enemy)
