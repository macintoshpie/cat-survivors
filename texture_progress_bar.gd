extends TextureProgressBar

@export var car: Car

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	car.health_changed.connect(update)
	update()

func update():
	value = car.health / car.max_health * 100
