extends Node2D
class_name Bomb

var damage: float = 20.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Explode.start()
	$CPUParticles2D.emitting = false
	$Area2D.monitorable = false
	$AnimatedSprite2D.play("waiting")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_explode_timeout() -> void:
	$CPUParticles2D.emitting = true
	$Area2D.set_deferred("monitorable", true)
	$AnimatedSprite2D.play("explosion")
	$Despawn.start()


func _on_despawn_timeout() -> void:
	queue_free()
