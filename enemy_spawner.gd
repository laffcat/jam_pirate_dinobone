class_name EnemySpawner
extends Node2D

@export var enemy : PackedScene = preload("res://scenes/enemy_caveman.tscn")

signal done

@export var amt_base := 3

var spawnpoints : Array[Vector2] = []

func check_tile(pos: Vector2, tilemap: TileMapLayer) -> bool:
	return tilemap.get_cell_atlas_coords(Vector2i(round(pos / 16)) + Vector2i(-8, -2)) == Vector2i(-1, -1)

func populate_spawnpoints(tilemap: TileMapLayer):
	var i := 0
	while i < amt_base + Global.nme_extra:
		var test : Vector2 = round(
			( global_position + randi_range(16, 60) * Vector2.UP.rotated(deg_to_rad((randi() % 360))) ) \
			/ 16 
			) * 16 + Vector2(8, 8)
		if check_tile(test, tilemap):
			i += 1
			spawnpoints.append(test)
		
		await get_tree().process_frame # to avoid freezes
	done.emit()
	$Area2D.set_deferred("monitorable", true)

func spawn():
	for each in spawnpoints:
		var nme = enemy.instantiate()
		Global.main.add_child(nme)
		nme.global_position = each
	await get_tree().process_frame
	call_deferred("queue_free")
