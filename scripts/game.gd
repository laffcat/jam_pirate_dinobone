extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	$TilesPathLayout.visible = 0
	$TilesWallLayout.visible = 0
	for each in $LevelGen.get_children(): each.visible = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"): get_tree().reload_current_scene()
