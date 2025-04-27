extends Node3D
class_name Arena

signal score_occurred(player_side: Enums.PlayerSide)

@onready var right_score_zone: ScoreZone = $RightScoreZone
@onready var left_score_zone: ScoreZone = $LeftScoreZone

func _ready() -> void:
	if right_score_zone:
		right_score_zone.player_scored.connect(_on_score_zone_player_scored)
	else:
		printerr("Arena could not find RightScoreZone node!")

	if left_score_zone:
		left_score_zone.player_scored.connect(_on_score_zone_player_scored)
	else:
		printerr("Arena could not find LeftScoreZone node!")

func _on_score_zone_player_scored(player_side: Enums.PlayerSide) -> void:
	emit_signal("score_occurred", player_side)
