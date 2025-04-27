extends Node

@onready var arena: Arena = $Arena
@onready var right_score_label: Label = $UI/RightScoreLabel
@onready var left_score_label: Label = $UI/LeftScoreLabel
@onready var camera_pivot: Marker3D = $CameraPivot

var right_score: int = 0
var left_score: int = 0

func _ready() -> void:
	if arena:
		arena.score_occurred.connect(_on_arena_score_occurred)
	else:
		printerr("Main could not find Arena node!")
	
	spawn_ball()

func spawn_ball() -> void:
	var ball: Ball = preload("res://game/ball/ball.tscn").instantiate()

	var spawn_location: PathFollow3D = $SpawnPath/SpawnLocation
	spawn_location.progress_ratio = randf()
	ball.setup(spawn_location.position)
	
	add_child(ball)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		for _i in range(50):
			spawn_ball()

func update_score(scoring_side: Enums.PlayerSide):
	match scoring_side:
		Enums.PlayerSide.RIGHT:
			right_score += 1
			right_score_label.text = str(right_score)
		Enums.PlayerSide.LEFT:
			left_score += 1
			left_score_label.text = str(left_score)

func _on_arena_score_occurred(player_side: Enums.PlayerSide) -> void:
	# print("Player ", Enums.PlayerSide.find_key(player_side), " scored!")
	update_score(player_side)
	spawn_ball()
