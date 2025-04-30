extends Control

@onready var pause_screen: ColorRect = $PauseScreen
@onready var help_timer: Timer = $HelpTimer
@onready var help_container: PanelContainer = $HelpContainer

var is_paused: bool = false

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
