extends Sprite2D

var disabled := false

func _input(event):
	if !disabled and event is InputEventMouseMotion:
		position = event.position #- Global.HALF_SCR
