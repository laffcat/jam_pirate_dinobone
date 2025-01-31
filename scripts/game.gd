extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.nmes_left = 0
	Global.main = self
	randomize()
	$TilesPathLayout.visible = 0
	$TilesWallLayout.visible = 0
	
	## generate levels!!!
	var genny : LevelGenerator = load(Global.pop_layout()).instantiate()
	add_child(genny)
	genny.generate($TilesWallLayout, $TilesPathLayout, $TilesGrass)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"): get_tree().reload_current_scene()
