extends AnimatableBody3D

@export var speed = 6

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("move_up"):
		direction.z -= 1
	if Input.is_action_pressed("move_down"):
		direction.z += 1

	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
	
	position.z += direction.z * speed * delta
