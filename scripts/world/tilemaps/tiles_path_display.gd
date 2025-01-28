@tool
extends TileMapLayer

@export var refresh_tiles := false:
	set(b): if b:
		Tiles.refresh(self, $"../TilesPathLayout")

const EDGE = { ## neighbor array layout: [7, 9, 3, 1]
	# edges
	[false, false, true, true] : [5, Tiles.R.N]		,
	[true, false, false, true] : [5, Tiles.R.E]		,
	[true, true, false, false] : [5, Tiles.R.S]		,
	[false, true, true, false] : [5, Tiles.R.W]		,
	# outer corners
	[false, false, true, false] : [2, Tiles.R.NW]	,
	[false, false, false, true] : [2, Tiles.R.NE]	,
	[true, false, false, false] : [2, Tiles.R.SE]	,
	[false, true, false, false] : [2, Tiles.R.SW]	,
	# inner corners
	[false, true, true, true] : [3, Tiles.R.NW]		,
	[true, false, true, true] : [3, Tiles.R.NE]		,
	[true, true, false, true] : [3, Tiles.R.SE]		,
	[true, true, true, false] : [3, Tiles.R.SW]		,
	# double corners
	[true, false, true, false] : [4, Tiles.R.NW, Tiles.R.SE]	,
	[false, true, false, true] : [4, Tiles.R.NE, Tiles.R.SW]	,
}

func get_tile(neighbors : Array[bool]) -> Array[int]:
	## returns [atlas X, atlas Y, transform byte]
	if neighbors == [true, true, true, true]: return [randi()%8, randi()%2, Tiles.trans_random()]
	var atlas_x := randi()%6
	var shpee := 0
	if len(EDGE[neighbors]) > 2: shpee = randi()%2
	return [ 
		atlas_x, 
		EDGE[neighbors][0], 
		Tiles.ROT [EDGE[neighbors][1 + shpee]] [randi()%2] 
	]























###
