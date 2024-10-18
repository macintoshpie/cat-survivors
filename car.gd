extends RigidBody2D

@export var speed: int = 80000
@export var turn_speed: int = 40
@export var turn_speed_2: int = 1000000

var skid_mark_scene = preload("res://skid_mark.tscn") as PackedScene
var screen_size: Vector2 = Vector2.ZERO
var drift_angle: float = PI / 12
var drift_count: int = 0
var drift_count_max: int = 60 * 3 # 3 seconds?
var drift_count_min_for_boost: int = 60 * 0.5 # half a second?
var drift_boost_max: float = 10.0
var drift_boost_decay: float = 10.0
var drift_boost_amount: float = 0.0

signal hit_wall
signal collected_coin

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	prints("Hello world!!")
	linear_damp = 1.0
	#angular_damp = 0.3


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var is_handbraking = Input.is_action_pressed("handbrake")

	var velocity = linear_velocity
	var forward_vector = Vector2(cos(rotation - PI / 2), sin(rotation - PI / 2))
	var sideways_vector = forward_vector.rotated(PI / 2)  # perpendicular to forward direction

	# project velocity onto forward and sideways vectors
	var forward_speed = velocity.dot(forward_vector)
	var lateral_speed = velocity.dot(sideways_vector)
	
	var acceleration_force = 40000  # forward acceleration force
	var reverse_acceleration_factor = 0.5 # reverse acceleration factor to forwards
	var steering_speed = 2.0       # base steering amount (tuned below)
	var lateral_friction = 5.0 if is_handbraking else 20.0    # friction to apply to sideways movement

	# apply lateral friction to reduce sideways sliding
	var lateral_force = -sideways_vector * lateral_speed * lateral_friction
	apply_central_force(lateral_force)

	# forward movement (acceleration)
	if Input.is_action_pressed("forward"):
		var forward_force = forward_vector * acceleration_force
		apply_central_force(forward_force)
	if Input.is_action_pressed("reverse"):
		var forward_force = forward_vector * -acceleration_force * reverse_acceleration_factor
		apply_central_force(forward_force)

	# calculate steering multiplier based on speed
	var speed_factor = clamp(abs(forward_speed) / 100.0, 0.0, 1.0)  # adjust the divisor for tuning
	var turn_rate = steering_speed * speed_factor  # make turn rate dependent on speed

	# steering left/right (only if car is moving)
	if forward_speed != 0:
		if Input.is_action_pressed("left"):
			rotation -= turn_rate * delta  # turn left based on speed
		if Input.is_action_pressed("right"):
			rotation += turn_rate * delta  # turn right based on speed

	# check if the car is sliding enough to leave skid marks

	var skid_threshold = 400
	var is_skid = abs(lateral_speed) > skid_threshold
	if is_skid:
		leave_skid_mark()
		
	#if is_skid and is_handbraking:
	if is_handbraking:
		if is_skid:
			drift_count = clampi(drift_count + 1, 0, drift_count_max)
	elif drift_count > 0:
		if drift_count > drift_count_min_for_boost:
			drift_boost_amount = clampf(drift_count, 0.0, drift_boost_max)
		drift_count = 0
	
	var drift_boost_speed = acceleration_force / 2
	if drift_boost_amount > 0.0:
		apply_central_force(forward_vector * drift_boost_speed * drift_boost_amount)
		drift_boost_amount = lerpf(drift_boost_amount, 0.0, delta*drift_boost_decay)

func _on_body_entered(body: Node2D) -> void:
	var damage = body.get_meta("damage")
	prints("Collision...")
	if damage != null:
		prints("damage!")

	hit_wall.emit()
	leave_skid_mark()

func leave_skid_mark() -> void:
	# instantiate the skid mark scene
	var skid_mark: Sprite2D = skid_mark_scene.instantiate()
	
	# calculate the back of the car by moving along the car's negative forward vector
	var offset_distance = 40  # adjust this value to match the length of your car
	var back_position = position - Vector2(cos(rotation), sin(rotation)) * offset_distance

	# set the skid mark at the back of the car
	skid_mark.position = back_position
	skid_mark.rotation = rotation + PI / 2  # ensure the skid mark is rotated correctly
	skid_mark.z_index = 0
	
	skid_mark.self_modulate = Color(0, 0, 0, float(drift_count) / float(drift_count_max))
	# add the skid mark to the scene tree
	get_parent().add_child(skid_mark)


func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	prints("Body shape entered")
