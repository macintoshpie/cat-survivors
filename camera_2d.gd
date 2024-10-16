extends Camera2D

var max_shake = 30.0
var shake_decay = 10.0
var shake_strength: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shake_strength > 0.0:
		shake_strength = lerpf(shake_strength, 0.0, shake_decay*delta)
		
		offset = random_offset()

func apply_shake():
	shake_strength = max_shake

func random_offset() -> Vector2:
	return Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
