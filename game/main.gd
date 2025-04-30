extends Node

@onready var arena: Arena = $Arena
@onready var ball_spawn_timer: Timer = $BallSpawnTimer
@onready var ball_got_stuck_sound: AudioStreamPlayer3D = $BallGotStuckSound
@onready var score_occurred_sound: AudioStreamPlayer3D = $ScoreOccurredSound
@onready var topdown_camera: Camera3D = $TopdownCamera.get_node("%Camera3D")
@onready var third_person_camera: Camera3D = $RightPaddle/ThirdPersonCamera.get_node("%Camera3D")
@onready var ui: Control = $UI

@export var right_player_score_sound: AudioStream
@export var left_player_score_sound: AudioStream
@export var is_third_person_camera: bool = false
@export var ball_scene: PackedScene
@export var ball_pool_size: int = 2

var _ball_pool: Array[Ball] = []
var right_score: int = 0
var left_score: int = 0

func _ready() -> void:
	_initialize_ball_pool()
	
	if not _ball_pool.is_empty():
		_warmup_particles(_ball_pool[0])
	else:
		printerr("Pool empty, skipping particle warm-up.")

	if arena:
		arena.score_occurred.connect(_on_arena_score_occurred)
	else:
		printerr("Main could not find Arena node!")
	
	ball_spawn_timer.start()

func _initialize_ball_pool() -> void:
	if not ball_scene:
		printerr("Ball Scene not assigned in the Main inspector!")
		return
	
	for i in range(ball_pool_size):
		var ball: Ball = ball_scene.instantiate()
		add_child(ball)
		ball.initialize_pool_object()
		ball.set_inactive_state()
		remove_child(ball)
		_ball_pool.append(ball)

func _warmup_particles(ball_instance: Ball) -> void:
	if not is_instance_valid(ball_instance):
		printerr("Warm-up failed: Invalid ball instance.")
		return

	add_child(ball_instance)

	var particles_node := ball_instance.particles
	if particles_node:
		print("Warming up particles...")
		ball_instance.visible = true
		particles_node.visible = true

		var original_one_shot := particles_node.one_shot
		var original_amount := particles_node.amount
		var original_lifetime := particles_node.lifetime

		particles_node.one_shot = true
		particles_node.amount = 10
		particles_node.lifetime = 0.1

		particles_node.emitting = true

		await get_tree().process_frame
		await get_tree().process_frame

		particles_node.one_shot = original_one_shot
		particles_node.amount = original_amount
		particles_node.lifetime = original_lifetime

		particles_node.emitting = false

		print("Particle warm-up emission complete, settings restored.")
	else:
		printerr("Could not find particles node on ball for warm-up.")

	ball_instance.visible = false
	remove_child(ball_instance)

func spawn_ball() -> void:
	if _ball_pool.is_empty():
		printerr("Ball pool empty!")
		return
	
	var ball: Ball = _ball_pool.pop_front()

	var spawn_location: PathFollow3D = $SpawnPath/SpawnLocation
	spawn_location.progress_ratio = randf()
	ball.setup(spawn_location.position)
	add_child(ball)
	ball.set_active_state()
	
	if not ball.ball_got_stuck.is_connected(_on_ball_got_stuck):
		ball.ball_got_stuck.connect(_on_ball_got_stuck)
	
	if not ball.ball_returning_to_pool.is_connected(_on_ball_returning_to_pool):
		ball.ball_returning_to_pool.connect(_on_ball_returning_to_pool)

func update_score(scoring_side: Enums.PlayerSide) -> void:
	match scoring_side:
		Enums.PlayerSide.RIGHT:
			right_score += 1
		Enums.PlayerSide.LEFT:
			left_score += 1

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
			third_person_camera.make_current()
		else:
			topdown_camera.make_current()

func _on_arena_score_occurred(player_side: Enums.PlayerSide) -> void:
	play_score_sound(player_side)
	update_score(player_side)
	ball_spawn_timer.start()
	ui.update_score_labels(player_side, right_score, left_score)

func _on_ball_spawn_timer_timeout() -> void:
	spawn_ball()

func _on_ball_got_stuck() -> void:
	ball_got_stuck_sound.play()
	ball_spawn_timer.start()

func _on_ball_returning_to_pool(ball: Ball) -> void:
	if is_instance_valid(ball):
		if ball.get_parent() == self:
			remove_child(ball)
		
		ball.set_inactive_state()
		
		# Avoid adding duplicates if something went wrong
		if not _ball_pool.has(ball):
			_ball_pool.push_back(ball)
