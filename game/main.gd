extends Node

@onready var arena: Arena = $Arena
@onready var right_score_label: Label = $UI/RightScoreLabel
@onready var left_score_label: Label = $UI/LeftScoreLabel
@onready var ball_spawn_timer: Timer = $BallSpawnTimer
@onready var ball_got_stuck_sound: AudioStreamPlayer3D = $BallGotStuckSound
@onready var score_occurred_sound: AudioStreamPlayer3D = $ScoreOccurredSound
@onready var topdown_camera: Marker3D = $TopdownCamera
@onready var third_person_camera: Node3D = $RightPaddle/ThirdPersonCamera

@export var right_player_score_sound: AudioStream
@export var left_player_score_sound: AudioStream
@export var is_third_person_camera: bool = false

var right_score: int = 0
var left_score: int = 0

func _ready() -> void:
	if arena:
		arena.score_occurred.connect(_on_arena_score_occurred)
	else:
		printerr("Main could not find Arena node!")
	
	ball_spawn_timer.start()

func spawn_ball() -> void:
	var ball: Ball = preload("res://game/ball/ball.tscn").instantiate()

	var spawn_location: PathFollow3D = $SpawnPath/SpawnLocation
	spawn_location.progress_ratio = randf()
	ball.setup(spawn_location.position)
	
	add_child(ball)
	
	ball.ball_got_stuck.connect(_on_ball_got_stuck)

func update_score(scoring_side: Enums.PlayerSide) -> void:
	match scoring_side:
		Enums.PlayerSide.RIGHT:
			right_score += 1
			right_score_label.text = str(right_score)
		Enums.PlayerSide.LEFT:
			left_score += 1
			left_score_label.text = str(left_score)

func play_score_sound(scoring_side: Enums.PlayerSide) -> void:
	var sound_to_play : AudioStream = null

	match scoring_side:
		Enums.PlayerSide.RIGHT:
			if right_player_score_sound:
				sound_to_play = right_player_score_sound
			else:
				printerr("Right player score sound not assigned in the Inspector!")
		Enums.PlayerSide.LEFT:
			if left_player_score_sound:
				sound_to_play = left_player_score_sound
			else:
				printerr("Left player score sound not assigned in the Inspector!")

	if sound_to_play:
		score_occurred_sound.stream = sound_to_play
		score_occurred_sound.play()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_camera"):
		is_third_person_camera = !is_third_person_camera
		if is_third_person_camera:
			third_person_camera.get_node("%Camera3D").current = true
		else:
			topdown_camera.get_node("%Camera3D").current = true

func _on_arena_score_occurred(player_side: Enums.PlayerSide) -> void:
	play_score_sound(player_side)
	update_score(player_side)
	ball_spawn_timer.start()

func _on_ball_spawn_timer_timeout() -> void:
	spawn_ball()

func _on_ball_got_stuck() -> void:
	ball_got_stuck_sound.play()
	ball_spawn_timer.start()
