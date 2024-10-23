extends RigidBody2D
class_name Enemy

var speed = 20
var health = 30
var damage = 10
var score_value = 5
var target: Car = null

var initial_attack_prob = 0.5
var crit_prob = 0.1

signal died

@onready var player = $"../Car"

static func is_enemy(area: Area2D) -> bool:
	return is_instance_of(area, Enemy)

func _physics_process(delta: float) -> void:
	var velocity = Vector2.ZERO
	if player:
		velocity = position.direction_to(player.position) * speed

	move_and_collide(velocity)
	#position += velocity
	
	if abs(velocity[0]) > abs(velocity[1]):
		if velocity[0] < 0:
			$AnimatedSprite2D.play("left")
		else:
			$AnimatedSprite2D.play("right")
	else:
		if velocity[1] < 0:
			$AnimatedSprite2D.play("up")
		else:
			$AnimatedSprite2D.play("down")

func _on_area_entered(area: Area2D) -> void:
	print("Area entered enemy")
	var parent = area.get_parent()
	if is_instance_of(parent, Bullet):
		var bullet: Bullet = parent
		do_damage(bullet.damage)
		bullet.queue_free()
	if is_instance_of(parent, Bomb):
		var bomb: Bomb = parent
		do_damage(bomb.damage)

func do_damage(damage: float) -> void:
	health -= damage
	if health <= 0:
		died.emit()
		queue_free()

func attack(car: Car) -> void:
	target = car
	if randf() < initial_attack_prob:
		apply_damage_to_target()

	$AttackTimer.start()

func stop_attack() -> void:
	target = null
	$AttackTimer.stop()

func _on_attack_timer_timeout() -> void:
	apply_damage_to_target()

func apply_damage_to_target():
	if target == null:
		return

	var damage_done = damage
	if randf() < crit_prob:
		damage_done = damage * 1.5

	target.do_damage(damage_done)


func _on_hit_and_attack_area_entered(area: Area2D) -> void:
	print("hitandattack entered enemy")
	var parent = area.get_parent()
	if is_instance_of(parent, Bullet):
		var bullet: Bullet = parent
		do_damage(bullet.damage)
		bullet.queue_free()
	if is_instance_of(parent, Bomb):
		var bomb: Bomb = parent
		do_damage(bomb.damage)
