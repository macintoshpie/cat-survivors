extends Node2D
class_name Fire

var damage = 20.0
var duration_secs: float = 2

var min_scale = 0.0
var max_scale = 8.0
var _scale_range = max_scale - min_scale
var frames = duration_secs * 60 # 60 physics frames per second

# calculate how much scale should change per frame
var scale_per_physics_frame = _scale_range / frames

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Despawn.wait_time = duration_secs
	$Despawn.start()

	scale = Vector2(max_scale, max_scale)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if scale[0] > min_scale:
		scale = scale - Vector2(scale_per_physics_frame, scale_per_physics_frame)
	else:
		scale = Vector2.ZERO

#func _on_area_2d_area_entered(area: Area2D) -> void:
	#if Enemy.is_enemy(area):
		#var enemy: Enemy = area
		#enemy.do_damage(damage)


func _on_despawn_timeout() -> void:
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_instance_of(body, Enemy):
		var enemy: Enemy = body
		enemy.do_damage(damage)
