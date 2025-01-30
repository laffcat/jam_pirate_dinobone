@tool
extends TileMapLayer

@export var threshold_a := 5.0
@export var threshold_b := 10.0

func is_on_quad(input: Vector2i) -> bool:
	if input.x%2: return false 
	if input.y%2: return false 
	return true

func generate(tile: Vector2i, dist: float):
	if !is_on_quad(tile): return
	var atlas : Vector2i
	
	if dist > threshold_b:
		atlas = Vector2i(randi_range(3, 4), randi_range(0, 2))
	elif dist > threshold_a:
		atlas = Vector2i(randi_range(0, 2), randi_range(0, 2))
	else: atlas = Vector2i.ZERO
	
	set_cell(tile/2, 0, atlas)
