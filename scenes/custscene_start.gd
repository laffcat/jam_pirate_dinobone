extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	match randi()%3:
		0:
			$LevelGenerator/Sphath2.call_deferred("queue_free")
			$LevelGenerator/Sphath3.call_deferred("queue_free")
		1:
			$LevelGenerator/Sphath.call_deferred("queue_free")
			$LevelGenerator/Sphath3.call_deferred("queue_free")
		2:
			$LevelGenerator/Sphath.call_deferred("queue_free")
			$LevelGenerator/Sphath2.call_deferred("queue_free")
			
	await get_tree().process_frame
	
	$Bone.rotate(deg_to_rad(randi()%21))
	$caveman.play("free_move")
	var coinflip = 1 if randi()%2 else -1
	$caveman.position.x = $Center.position.x - randi_range(80, 150) * coinflip
	$caveman.scale.x = coinflip
	$LevelGenerator.gen_test = true
	await get_tree().process_frame
	var t := get_tree().create_tween().set_ease(Tween.EASE_OUT)
	t.tween_property($ColorRect3, "position:y", 480, 1.4)
	await t.finished
	$AudioStreamPlayer.play()
	t = get_tree().create_tween()
	t.tween_property($caveman, "position", Vector2(
		$Center.position.x - 10 * coinflip,
		$Center.position.y
		), 2.0)
	await t.finished
	# $caveman.material.set_shader_parameter("colors:0:a", 1.0)
	var awry := $caveman.material.get_shader_parameter("colors") as Array
	awry[0].a = 1.0
	$caveman.material.set_shader_parameter("colors", awry)
	$caveman.play("twitch")
	await get_tree().create_timer(1.2)
	t = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	t.tween_property($ColorRect3, "position:y", 0, 1.8)
	await t.finished
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	
