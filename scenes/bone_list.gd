extends TileMapLayer





func update():
	clear()
	var x := 0
	var y := 0
	for each in Global.bonez:
		set_cell(Vector2i(x, y), 0, Vector2i(each, 0))
		x += 1
		if x > 13:
			x = 0
			y += 1
		

func _ready() -> void:
	update()
	Global.bonez_updated.connect(update)
