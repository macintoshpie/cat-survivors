extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Car/Music.play()
	
	$SimpleTileMapLayer.set_cell(Vector2(1, 1), 0, Vector2i(0, 1), 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_finish_line_lap_completed(time: float) -> void:
	$LastLap.text = str(time)


func _on_car_hit_wall() -> void:
	$Car/Camera2D.apply_shake()
