extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	$TilesPathLayout.visible = 0
	$TilesWallLayout.visible = 0
