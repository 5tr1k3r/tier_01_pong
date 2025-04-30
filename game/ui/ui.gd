extends Control

@onready var right_score_label: Label = $RightScoreLabel
@onready var left_score_label: Label = $LeftScoreLabel
@onready var pause_screen: ColorRect = $PauseScreen
@onready var help_timer: Timer = $HelpTimer
@onready var help_container: PanelContainer = $HelpContainer

const SCORE_LABEL_GROWTH_FACTOR: float = 2.5
const SCORE_LABEL_TWEEN_DURATION: float = 0.15
var is_paused: bool = false

func update_score_labels(scoring_side: Enums.PlayerSide, right_score: int, left_score: int) -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	
	match scoring_side:
		Enums.PlayerSide.RIGHT:
			right_score_label.text = str(right_score)
			right_score_label.scale = Vector2.ONE * SCORE_LABEL_GROWTH_FACTOR
			tween.tween_property(right_score_label, "scale", Vector2.ONE, SCORE_LABEL_TWEEN_DURATION)
		Enums.PlayerSide.LEFT:
			left_score_label.text = str(left_score)
			left_score_label.scale = Vector2.ONE * SCORE_LABEL_GROWTH_FACTOR
			tween.tween_property(left_score_label, "scale", Vector2.ONE, SCORE_LABEL_TWEEN_DURATION)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		is_paused = !is_paused
		pause_screen.visible = is_paused
		get_tree().paused = is_paused
	
	if event.is_action_pressed("show_help"):
		help_container.visible = true
		help_timer.start()


func _on_help_timer_timeout() -> void:
	help_container.visible = false
