extends Marker3D

@onready var camera: Camera3D = %Camera3D
@export var vertical_orientation: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_orientation"):
		if !camera.current:
			return
		
		vertical_orientation = !vertical_orientation
		if vertical_orientation:
			rotation_degrees.y = 90
		else:
			rotation_degrees.y = 0
