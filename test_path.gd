extends Path2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var voo = curve.get_baked_points()
	
	for x in voo:
		prints(voo)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
