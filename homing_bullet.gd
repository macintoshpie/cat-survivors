extends Bullet
class_name HomingBullet

var target: Node2D = null
var homing_strength = 100

func _ready():
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target != null:
		# calculate direction towards target
		var target_direction = (target.global_position - global_position).normalized()
		# smoothly rotate towards the target direction
		direction = direction.lerp(target_direction, homing_strength * delta).normalized()
	
	super._move(delta)
