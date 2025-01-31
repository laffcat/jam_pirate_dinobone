extends Sprite2D


func _input(event: InputEvent) -> void:
	if !visible: return
	if event.is_action_pressed("esc"):
		get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
	if event.is_action_pressed("space"):
		get_tree().change_scene_to_file("res://scenes/custscene_start.tscn")
