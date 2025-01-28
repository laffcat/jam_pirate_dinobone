@tool
extends Node


const FH := TileSetAtlasSource.TRANSFORM_FLIP_H
const FV := TileSetAtlasSource.TRANSFORM_FLIP_V
const T := TileSetAtlasSource.TRANSFORM_TRANSPOSE

enum R { NW, NE, SE, SW, # corners
	N, E, S, W } # edges
	
const ROT : Array[Array] = [
	[ 0, T ]			,
	[ FH, FH|T ]		,
	[ FH|FV, FH|FV|T ]	,
	[ FV, FV|T ]		,
	
	[ 0, FH ]			,
	[ T|FH, T|FH|FV ]	,
	[ FV, FH|FV ]		,
	[ T, T|FV ]			]

func trans_random() -> int:
	var byte := 0
	if randi()%2: byte |= FH
	if randi()%2: byte |= FV
	if randi()%2: byte |= T
	return byte

func tile_exists(lay : TileMapLayer, cord : Vector2i) -> bool:
		return true if lay.get_cell_atlas_coords(cord) != Vector2i(-1, -1) else false
func get_neighbors(layer : TileMapLayer, coords : Vector2i) -> Array[bool]:
	return [
		tile_exists(layer, coords)					,
		tile_exists(layer, coords + Vector2i(1, 0))	,
		tile_exists(layer, coords + Vector2i(1, 1))	,
		tile_exists(layer, coords + Vector2i(0, 1))	]

const OFFSETS : Array[Vector2i] = [ Vector2i(0, 0), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(-1, -1) ]
func refresh(display : TileMapLayer, layout : TileMapLayer):
	display.clear()
	var already_set : Array[Vector2i]
	for coord in layout.get_used_cells():
		for off in OFFSETS:
			var at := coord + off
			if at in already_set: continue
			already_set.append(at)
			var tile_data = display.get_tile(get_neighbors(layout, at))
			display.set_cell(at, 0, Vector2i(tile_data[0], tile_data[1]), tile_data[2])
		




















###
