extends Area2D
class_name Enemy

var speed = 30
var health = 30
var damage = 10

signal died

@onready var player = $"../Car"

func _physics_process(delta: float) -> void:
	var velocity = Vector2.ZERO
	if player:
		velocity = position.direction_to(player.position) * speed

	position += velocity

func _on_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if is_instance_of(parent, Bullet):
		var bullet: Bullet = parent
		do_damage(bullet.damage)
		bullet.queue_free()

func do_damage(damage: float) -> void:
	health -= damage
	if health <= 0:
		died.emit()
		queue_free()
