extends Area3D
class_name ScoreZone

signal player_scored(player_side: Enums.PlayerSide)

@export var scoring_player_side: Enums.PlayerSide

func _on_body_entered(body: Node3D) -> void:
	if body is Ball:
		emit_signal("player_scored", scoring_player_side)
		body.die()
