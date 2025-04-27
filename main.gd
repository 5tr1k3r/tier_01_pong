extends Node

@onready var ball_velocity_label: Label = $UI/DebugLabel
@onready var arena: Arena = $Arena
@onready var right_score_label: Label = $UI/RightScoreLabel
@onready var left_score_label: Label = $UI/LeftScoreLabel

var last_ball: Ball
var last_ball_material: StandardMaterial3D = preload("res://last_ball_material.tres")
var right_score: int = 0
var left_score: int = 0

func _ready() -> void:
	if arena:
		arena.score_occurred.connect(_on_arena_score_occurred)
	else:
		printerr("Main could not find Arena node!")
	
	spawn_ball()

func spawn_ball() -> void:
	var ball: Ball = preload("res://ball.tscn").instantiate()

	var spawn_location: PathFollow3D = $SpawnPath/SpawnLocation
	spawn_location.progress_ratio = randf()
	ball.setup(spawn_location.position)
	
	add_child(ball)
	
	var ball_mesh: MeshInstance3D = ball.get_node("MeshInstance3D")
	ball_mesh.set_surface_override_material(0, last_ball_material)

	if last_ball:
		var last_ball_mesh: MeshInstance3D = last_ball.get_node("MeshInstance3D")
		last_ball_mesh.set_surface_override_material(0, null)
	
	last_ball = ball

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		for _i in range(50):
			spawn_ball()

func _process(_delta: float) -> void:
	update_ball_velocity_label()

func update_ball_velocity_label() -> void:
	if last_ball:
		var ball_velocity = last_ball.linear_velocity.length()
		var ball_angular_velocity = last_ball.angular_velocity.length()
		ball_velocity_label.text = "last ball\nvelocity: %.2f\nangular velocity: %.2f" % [ball_velocity, ball_angular_velocity]

func update_score_labels(scoring_side: Enums.PlayerSide):
	match scoring_side:
		Enums.PlayerSide.RIGHT:
			right_score += 1
			right_score_label.text = str(right_score)
		Enums.PlayerSide.LEFT:
			left_score += 1
			left_score_label.text = str(left_score)

func _on_arena_score_occurred(player_side: Enums.PlayerSide) -> void:
	# print("Player ", Enums.PlayerSide.find_key(player_side), " scored!")
	update_score_labels(player_side)
	spawn_ball()
