extends Area2D
class_name Gate

@export var width: int = 1500
@export var rotation_angle: float = 0 # in radians

signal activated

var broken: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_gate()
	var p1 = Vector2(-width/2, 0)
	var p2 = Vector2(width/2, 0)

	# Rotate points around the center
	p1 = p1.rotated(rotation_angle)
	p2 = p2.rotated(rotation_angle)

	var center = $Center.position
	$Obstacle1.position = center + p1
	$Obstacle2.position = center + p2
	
	$Line2D.add_point(center + p1)
	$Line2D.add_point(center + p2)
	
	$CollisionShape2D.shape.size = Vector2(width, 30)
	$CollisionShape2D.position = center
	$CollisionShape2D.rotation = rotation_angle


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Car":
		broken = true
		$Line2D.hide()
		emit_signal("activated")

func hide_gate():
	set_deferred("monitorable", false)
	$Obstacle1.set_collision_layer_value(1, false)
	$Obstacle2.set_collision_layer_value(1, false)
	$Obstacle1.set_collision_mask_value(1, false)
	$Obstacle2.set_collision_mask_value(1, false)
	hide()

func show_gate():
	set_deferred("monitorable", true)
	$Obstacle1.set_collision_layer_value(1, true)
	$Obstacle2.set_collision_layer_value(1, true)
	$Obstacle1.set_collision_mask_value(1, false)
	$Obstacle2.set_collision_mask_value(1, false)
	show()
