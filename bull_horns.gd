extends Area2D

var enable_horns = false
var damage = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup(enable_horns)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func upgrade() -> void:
	if !enable_horns:
		_setup(true)
	else:
		damage *= 1.15

func _setup(enabled: bool) -> void:
	if enabled:
		enable_horns = true
		visible = true
		set_collision_mask_value(3, true)
	else:
		enable_horns = false
		visible = false
		set_collision_mask_value(3, false)

func _on_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if is_instance_of(parent, Enemy):
		var enemy: Enemy = parent
		enemy.do_damage(damage)
