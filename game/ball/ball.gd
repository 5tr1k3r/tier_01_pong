extends RigidBody3D
class_name Ball

signal ball_got_stuck

@onready var stuck_timer: Timer = $StuckTimer
@onready var paddle_hit_sound: AudioStreamPlayer3D = $PaddleHitSound
@onready var wall_hit_sound: AudioStreamPlayer3D = $WallHitSound
@onready var high_velocity_hit_sound: AudioStreamPlayer3D = $HighVelocityHitSound
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

const STARTING_IMPULSE_VALUE: float = 5.0
const HIGH_VELOCITY_THRESHOLD: float = 1.5
const DYING_DURATION: float = 0.4
var initial_impulse: Vector3 = Vector3.ZERO
var is_dying: bool = false
var unique_material: StandardMaterial3D

func setup(start_position: Vector3) -> void:
	position = start_position
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	# From -45 to 45 deg
	var random_angle := randf_range(-PI / 4, PI / 4)
	var x_direction: float = [-1.0, 1.0].pick_random()
	var base_direction := Vector3(x_direction, 0.0, 0.0)
	var rotated_direction := base_direction.rotated(Vector3.UP, random_angle)
	initial_impulse = rotated_direction.normalized() * STARTING_IMPULSE_VALUE

func _ready() -> void:
	# Make the material unique so we can manipulate it and not affect other balls
	unique_material = mesh_instance.get_active_material(0).duplicate()
	mesh_instance.set_surface_override_material(0, unique_material)
	
	stuck_timer.start()
	
	if initial_impulse != Vector3.ZERO:
		apply_central_impulse(initial_impulse)
	else:
		printerr("Ball added to tree, but initial impulse was not calculated!")

func die() -> void:
	if is_dying:
		return
	
	is_dying = true
	freeze = true
	collision_shape.disabled = true
	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(unique_material, "albedo_color:a", 0.0, DYING_DURATION)
	tween.tween_callback(queue_free)

func _on_body_entered(body: Node) -> void:
	var is_high_velocity_hit := linear_velocity.length() / STARTING_IMPULSE_VALUE > HIGH_VELOCITY_THRESHOLD
	
	if body is Paddle:
		stuck_timer.start()
		paddle_hit_sound.play()
		if is_high_velocity_hit:
			high_velocity_hit_sound.play()
	elif body is Wall:
		wall_hit_sound.play()

func _on_stuck_timer_timeout() -> void:
	print("BALL STUCK! BALL STUCK!")
	emit_signal("ball_got_stuck")
	die()
