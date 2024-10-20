extends Node2D
class_name Bullet

var speed = 2000
var direction = Vector2(1, 0) # default direction
var damage = 10

func _ready():
	# ensure the bullet moves in the correct direction
	#direction = get_global_transform().x.normalized()
	$Despawn.start()

func _process(delta):
	position += direction * speed * delta


func _on_despawn_timeout() -> void:
	queue_free()
