extends Node2D
class_name Pedestrian

var speed: int = 10
var direction: Vector2 = Vector2(1, 0).normalized()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if randf() < 0.01:
		var x = randi_range(-1, 1)
		var y = randi_range(-1, 1)
		direction = Vector2(x, y).normalized()
		
		if abs(direction[0]) > abs(direction[1]):
			if direction[0] < 0:
				$AnimatedSprite2D.play("walk_left")
			else:
				$AnimatedSprite2D.play("walk_right")
		else:
			if direction[1] < 0:
				$AnimatedSprite2D.play("walk_up")
			else:
				$AnimatedSprite2D.play("walk_down")

	position += direction * speed
	
	
