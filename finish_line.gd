extends Area2D

signal time_passed(time: float)
signal lap_completed(time: float)
var time_since_last_lap: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_since_last_lap += delta
	time_passed.emit(time_since_last_lap)

func add_time(t: float) -> void:
	time_since_last_lap += t

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Car":
		lap_completed.emit(time_since_last_lap)
		time_since_last_lap = 0


func _on_car_collected_coin() -> void:
	lap_completed.emit(-1)
