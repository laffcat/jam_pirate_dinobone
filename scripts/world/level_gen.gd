@tool
extends Node



@export var gen_test := false:
	set(b): if b:
		generate($"../TilesWallLayout", $"../TilesPathLayout")
		
		
@export var texture : Texture2D
@export var length := 60
@export var noise_drift := .05
@export var threshold := 10.0
@export var path_threshold := .3
@export var uv_mult_x := 1.0
@export var uv_mult_y := 1.0
@export var noise_mult := 1.0



func generate(layout_wall: TileMapLayer, layout_path: TileMapLayer):
	layout_wall.clear()
	layout_path.clear()
	
	## prepare noise texture
	var t := texture.get_image()
	var w := texture.get_width()
	var h := texture.get_height()
	
	## noise-based filling system
	# first, fill all tiles - we'll be carving subtractively to make multiple passes easier
	for y in range(1, 19): for x in range(1, length): 
		layout_wall.set_cell(Vector2i(x, y), 0, Vector2i.ZERO)
	# then, clear tiles based on proximity to paths, offset by noise
	var markers : Array[Node2D] = []; for each in get_children(): markers.append(each)
	for mark in markers:
		for tile in layout_wall.get_used_cells():
			var dist := 0.0
			if mark is Path2D:
				dist = (tile * 16).distance_to( mark.curve.sample_baked( mark.curve.get_closest_offset(tile * 16) ) )
			if mark is Shpee:
				dist = (tile * 16).distance_to(mark.global_position) * mark.mult
			var uv_x := tile.x * .05 * uv_mult_x
			var uv_y := tile.y * .05 * uv_mult_y + (uv_x * noise_drift)
			var sample := t.get_pixel(int(w * uv_x) % w, int(h * uv_y) % h).r
			var final := dist * .1 + (sample - .5) * noise_mult
			if final < threshold:
				layout_wall.set_cell(tile, 0, Vector2i(-1, -1))
				if mark is Path2D and final < threshold * path_threshold:
					layout_path.set_cell(tile, 0, Vector2i.ZERO)
			#print(str(tile) + ", " + str(dist) + ", " + str(final))
			
				
	
	
	## seal in edges
	# sides
	for tile_y in range(-2, 22):
		layout_wall.set_cell(Vector2i(0, tile_y), 0, Vector2i.ZERO)
		layout_wall.set_cell(Vector2i(-1, tile_y), 0, Vector2i.ZERO)
		layout_wall.set_cell(Vector2i(-2, tile_y), 0, Vector2i.ZERO)
		layout_wall.set_cell(Vector2i(length, tile_y), 0, Vector2i.ZERO)
		layout_wall.set_cell(Vector2i(length + 1, tile_y), 0, Vector2i.ZERO)
		layout_wall.set_cell(Vector2i(length + 2, tile_y), 0, Vector2i.ZERO)
	# top/btm
	for tile_x in range(1, length):
		layout_wall.set_cell(Vector2i(tile_x, 0), 0, Vector2i.ZERO)
		layout_wall.set_cell(Vector2i(tile_x, -1), 0, Vector2i.ZERO)
		layout_wall.set_cell(Vector2i(tile_x, -2), 0, Vector2i.ZERO)
		layout_wall.set_cell(Vector2i(tile_x, 21), 0, Vector2i.ZERO)
		layout_wall.set_cell(Vector2i(tile_x, 20), 0, Vector2i.ZERO)
		layout_wall.set_cell(Vector2i(tile_x, 19), 0, Vector2i.ZERO)
		
	
	await get_tree().process_frame
	$"../TilesPathDisplay".refresh_tiles = true
	$"../TilesWallDisplay".refresh_tiles = true
	
	
	
	
	
	
	
	
