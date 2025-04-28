extends Control

@onready var pause_screen: ColorRect = $PauseScreen

var is_paused: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		is_paused = !is_paused
		pause_screen.visible = is_paused
		get_tree().paused = is_paused
