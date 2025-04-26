extends AnimatableBody3D

enum PlayerType {
	PLAYER_ONE,
	PLAYER_TWO,
	PLAYER_AI
}

@export var player_type: PlayerType
@export var speed: float = 6.0
var max_z: float = 2.15

func _ready() -> void:
	var original_material: StandardMaterial3D = $MeshInstance3D.get_active_material(0)
	var new_material: StandardMaterial3D = original_material.duplicate()
	$MeshInstance3D.set_surface_override_material(0, new_material)
	
	match player_type:
		PlayerType.PLAYER_ONE:
			new_material.albedo_color = Color.CHARTREUSE
		PlayerType.PLAYER_TWO:
			new_material.albedo_color = Color.RED
		PlayerType.PLAYER_AI:
			new_material.albedo_color = Color.PURPLE


func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO
	
	match player_type:
		PlayerType.PLAYER_ONE:
			if Input.is_action_pressed("p1_move_up"):
				direction.z -= 1.0
			if Input.is_action_pressed("p1_move_down"):
				direction.z += 1.0
		PlayerType.PLAYER_TWO:
			if Input.is_action_pressed("p2_move_up"):
				direction.z -= 1.0
			if Input.is_action_pressed("p2_move_down"):
				direction.z += 1.0
		_:
			pass
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
	
	position.z = clampf(position.z + direction.z * speed * delta, -max_z, max_z)
