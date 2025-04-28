extends AnimatableBody3D
class_name Paddle

@export var player_type: Enums.PlayerType
@export var speed: float = 6.0
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

func _physics_process(delta: float) -> void:
	direction = 0.0
	
	match player_type:
		Enums.PlayerType.ONE:
			direction = Input.get_axis("p1_move_up", "p1_move_down")
		Enums.PlayerType.TWO:
			direction = Input.get_axis("p2_move_up", "p2_move_down")
		_:
			pass
	
	if direction:
		if direction > 0:
			animation_player.play("move_down")
		else:
			animation_player.play("move_up")
	
		position.z = clampf(position.z + direction * speed * delta, -PADDLE_BOUNDARY_Z, PADDLE_BOUNDARY_Z)
	else:
		animation_player.play("RESET", 0.1)
	
