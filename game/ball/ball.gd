extends RigidBody3D
class_name Ball

signal ball_got_stuck
signal ball_returning_to_pool(ball: Ball)

@onready var stuck_timer: Timer = $StuckTimer
@onready var paddle_hit_sound: AudioStreamPlayer3D = $PaddleHitSound
@onready var wall_hit_sound: AudioStreamPlayer3D = $WallHitSound
@onready var high_velocity_hit_sound: AudioStreamPlayer3D = $HighVelocityHitSound
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var particles: GPUParticles3D = $GPUParticles3D

const STARTING_IMPULSE_VALUE: float = 5.0
const HIGH_VELOCITY_THRESHOLD: float = STARTING_IMPULSE_VALUE * 1.5
const HIGH_VELOCITY_EMISSION := Color.RED * 3.0 # Emission needs intensity > 1 to glow properly
const DYING_DURATION: float = 0.4
const BALL_GROUP := "balls"
var initial_impulse: Vector3 = Vector3.ZERO
var is_dying: bool = false
var unique_material: StandardMaterial3D
var particle_process_material: ParticleProcessMaterial

func initialize_pool_object() -> void:
	# --- Expensive Operations ---
	# Duplicate material only ONCE during initial creation
	if not unique_material:
		var original_material := mesh_instance.get_active_material(0)
		if original_material:
			unique_material = original_material.duplicate()
			mesh_instance.set_surface_override_material(0, unique_material)
			unique_material.emission_enabled = true
			unique_material.emission = Color.BLACK # Initialize emission
		else:
			printerr("Ball MeshInstance3D has no material to duplicate!")

	# Get particle material reference ONCE
	if not particle_process_material:
		particle_process_material = particles.process_material as ParticleProcessMaterial
		if not particle_process_material:
			printerr("Ball could not find ParticleProcessMaterial!")
		else:
			# Configure particle material properties that don't change
			particle_process_material.inherit_velocity_ratio = 0.0
			particle_process_material.direction = Vector3.BACK

func set_inactive_state() -> void:
	remove_from_group(BALL_GROUP)
	visible = false
	freeze = true
	if collision_shape:
		collision_shape.disabled = true
	if stuck_timer:
		stuck_timer.stop()
	if particles:
		particles.emitting = false
	if unique_material:
		unique_material.emission = Color.BLACK
		unique_material.albedo_color.a = 1.0

func set_active_state() -> void:
	add_to_group(BALL_GROUP)
	visible = true
	freeze = false
	if collision_shape:
		collision_shape.disabled = false
	if stuck_timer:
		stuck_timer.start()
	
	if initial_impulse != Vector3.ZERO:
		call_deferred("apply_central_impulse", initial_impulse)
	else:
		printerr("Attempting to activate ball with zero initial impulse!")

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

func _physics_process(_delta: float) -> void:
	if is_dying: # Don't update visuals if fading out
		return

	# Get the current speed
	var current_speed := linear_velocity.length()

	# Calculate the interpolation factor ONLY between the minimum and maximum desired speeds
	# inverse_lerp(from, to, value) returns where 'value' is between 'from' and 'to' (0.0 to 1.0)
	var emission_ratio := inverse_lerp(STARTING_IMPULSE_VALUE, HIGH_VELOCITY_THRESHOLD, current_speed)

	# Clamp the ratio:
	# - If speed is below MIN_SPEED_FOR_EMISSION, inverse_lerp gives < 0, clamp makes it 0.
	# - If speed is above MAX_VISUAL_VELOCITY, inverse_lerp gives > 1, clamp makes it 1.
	# - If speed is within the range, it gives 0-1, clamp leaves it unchanged.
	emission_ratio = clampf(emission_ratio, 0.0, 1.0)

	# Now lerp the emission using this correctly mapped and clamped ratio
	unique_material.emission = lerp(Color.BLACK, HIGH_VELOCITY_EMISSION, emission_ratio)
	
	if current_speed > 0.01: # Avoid issues with zero vector
		particle_process_material.direction = -linear_velocity.normalized()
	
	if current_speed > HIGH_VELOCITY_THRESHOLD:
		particles.emitting = true

func die() -> void:
	if is_dying:
		return
	
	is_dying = true
	freeze = true
	if collision_shape:
		collision_shape.disabled = true
	if particles:
		particles.emitting = false
	if stuck_timer:
		stuck_timer.stop()
	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(unique_material, "albedo_color:a", 0.0, DYING_DURATION)
	tween.tween_callback(_return_to_pool)

func _return_to_pool() -> void:
	is_dying = false
	emit_signal("ball_returning_to_pool", self)

func _on_body_entered(body: Node) -> void:
	if is_dying:
		return
	
	var is_high_velocity_hit := linear_velocity.length() > HIGH_VELOCITY_THRESHOLD
	
	if body is Paddle:
		if stuck_timer:
			stuck_timer.start()
		paddle_hit_sound.play()
		if is_high_velocity_hit:
			high_velocity_hit_sound.play()
	elif body is Wall:
		wall_hit_sound.play()

func _on_stuck_timer_timeout() -> void:
	if is_dying:
		return
	
	print("BALL STUCK! BALL STUCK!")
	emit_signal("ball_got_stuck")
	die()

func _exit_tree() -> void:
	if is_in_group(BALL_GROUP):
		remove_from_group(BALL_GROUP)
