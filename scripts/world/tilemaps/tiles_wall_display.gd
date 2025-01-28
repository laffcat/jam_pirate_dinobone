@tool
extends TileMapLayer


@export var refresh_tiles := false:
	set(b): if b:
		Tiles.refresh(self, $"../TilesWallLayout")





func get_tile(neighbors : Array[bool]) -> Array[int]:
	## returns [atlas X, atlas Y, transform byte]
	
	match neighbors: ## neighbor array layout: [7, 9, 3, 1]
		
		# midtiles
		[true, true, true, true]: return [ randi()%10, randi_range(4, 8), Tiles.FH * randi()%2 ]
		# top edges
		[false, false, true, true]: return [ randi()%8, 0, Tiles.FH * randi()%2 ]
		# bottom edges
		[true, true, false, false]: return [ randi()%8, 2, Tiles.FH * randi()%2 ]
		# side edges
		[false, true, true, false]: return [ randi()%8, 1, Tiles.T | (Tiles.FV * randi()%2) ]
		[true, false, false, true]: return [ randi()%8, 1, Tiles.T | Tiles.FH | (Tiles.FV * randi()%2) ]
		
		# top outer corners
		[false, false, true, false]: return [ randi()%2, 3, Tiles.T * randi()%2 ]
		[false, false, false, true]: return [ randi()%2, 3, Tiles.FH | (Tiles.T * randi()%2) ]
		# top inner corners
		[false, true, true, true]: return [ randi_range(2, 3), 3, 0 ]
		[true, false, true, true]: return [ randi_range(2, 3), 3, Tiles.FH ]
		# bottom outer corners
		[false, true, false, false]: return [ randi_range(4, 5), 3, 0 ]
		[true, false, false, false]: return [ randi_range(4, 5), 3, Tiles.FH ]
		# bottom inner corners
		[true, true, true, false]: return [ randi_range(6, 7), 3, 0 ]
		[true, true, false, true]: return [ randi_range(6, 7), 3, Tiles.FH ]
		# double trouble
		[true, false, true, false]: return [ randi_range(8, 9), 3, 0 ]
		[false, true, false, true]: return [ randi_range(8, 9), 3, Tiles.FH ]
	
	print("wall.get_tile() failed to match neighbor array!!!! :/ " + str(neighbors))
	return [-1, -1, -1]
	
