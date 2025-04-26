extends RigidBody3D

class_name Ball

var starting_impulse_value: float = 5.0
var initial_impulse: Vector3 = Vector3.ZERO

func setup(start_position: Vector3):
	position = start_position
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	# From -45 to 45 deg
	var random_angle = randf_range(-PI / 4, PI / 4)
	var x_direction = [-1.0, 1.0].pick_random()
	var base_direction = Vector3(x_direction, 0.0, 0.0)
	var rotated_direction = base_direction.rotated(Vector3.UP, random_angle)
	initial_impulse = rotated_direction.normalized() * starting_impulse_value

func _ready() -> void:
	if initial_impulse != Vector3.ZERO:
		apply_central_impulse(initial_impulse)
	else:
		printerr("Ball added to tree, but initial impulse was not calculated!")

#func _physics_process(_delta: float) -> void:
	## Force angular velocity to zero every physics frame
	#angular_velocity = Vector3.ZERO
