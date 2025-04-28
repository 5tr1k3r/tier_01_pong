extends AnimatableBody3D
class_name Paddle

@export var player_type: Enums.PlayerType
@export var speed: float = 6.0

@export var ai_reaction_threshold: float = 0.05 # Smaller threshold needed with lerp
@export var ai_reaction_time_min: float = 0.1 # Minimum time between reactions
@export var ai_reaction_time_max: float = 0.3 # Maximum time between reactions

var ai_target_z: float = 0.0 # Where the AI thinks the ball is
var ai_time_since_last_reaction: float = 0.0
var ai_current_reaction_cooldown: float = 0.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
const PADDLE_BOUNDARY_Z: float = 2.15
var direction: float = 0.0

func _ready() -> void:
	var original_material: StandardMaterial3D = $MeshInstance3D.get_active_material(0)
	var new_material: StandardMaterial3D = original_material.duplicate()
	$MeshInstance3D.set_surface_override_material(0, new_material)
	
	match player_type:
		Enums.PlayerType.ONE:
			new_material.albedo_color = Color.CHARTREUSE
		Enums.PlayerType.TWO:
			new_material.albedo_color = Color.RED
		Enums.PlayerType.AI:
			new_material.albedo_color = Color.PURPLE
			_set_new_ai_reaction_cooldown()
			# Set initial target to current position to avoid weird start
			ai_target_z = global_position.z

func _physics_process(delta: float) -> void:
	direction = 0.0
	
	match player_type:
		Enums.PlayerType.ONE:
			direction = Input.get_axis("p1_move_up", "p1_move_down")
		Enums.PlayerType.TWO:
			direction = Input.get_axis("p2_move_up", "p2_move_down")
		Enums.PlayerType.AI:
			ai_time_since_last_reaction += delta
			if ai_time_since_last_reaction >= ai_current_reaction_cooldown:
				# Time to react! Find the ball and update target
				_update_ai_target_z()
				_set_new_ai_reaction_cooldown() # Set time for *next* reaction
				ai_time_since_last_reaction = 0.0

			# AI always moves towards its *last known* target Z
			direction = _get_ai_direction_based_on_target()
	
	if direction:
		if direction > 0:
			animation_player.play("move_down")
		else:
			animation_player.play("move_up")
	
		position.z = clampf(position.z + direction * speed * delta, -PADDLE_BOUNDARY_Z, PADDLE_BOUNDARY_Z)
	else:
		animation_player.play("RESET", 0.1)

func _set_new_ai_reaction_cooldown() -> void:
	ai_current_reaction_cooldown = randf_range(ai_reaction_time_min, ai_reaction_time_max)

func _update_ai_target_z() -> void:
	# Find the ball (same logic as before)
	var balls_in_tree := get_tree().get_nodes_in_group(Ball.BALL_GROUP)
	if balls_in_tree.is_empty():
		# Maybe move towards center if no ball?
		ai_target_z = 0.0
		return

	var target_ball := balls_in_tree[0] as Ball
	if not is_instance_valid(target_ball):
		ai_target_z = 0.0 # Or keep last known target?
		return

	# Update the target Z
	ai_target_z = target_ball.global_position.z
	# --- > Add other imperfections here! (like inaccuracy) <---

func _get_ai_direction_based_on_target() -> float:
	# Move towards the stored ai_target_z
	var paddle_z := global_position.z
	if abs(ai_target_z - paddle_z) < ai_reaction_threshold:
		return 0.0
	elif ai_target_z > paddle_z:
		return 1.0 # Target is below, move down
	else:
		return -1.0 # Target is above, move up
