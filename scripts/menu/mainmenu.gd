extends Node2D




func _ready() -> void: intro()

func intro():
	await get_tree().create_timer(.9).timeout
	$Music.play()
	var t := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_parallel()
	t.tween_property($ColorRect, "color:a", 0.0, .666)
	t.tween_property($LogoJam, "modulate:a", 0.0, .9)
	t.tween_property($Leaf1, "scale", Vector2(1, 1), 1.2)
	t.tween_property($Leaf2, "scale", Vector2(1, 1), 1.2)
	t.tween_property($Bg, "scale", Vector2(1, 1), 1.2)
	t.tween_property($Leaf1, "modulate", Color.WHITE, 1.7)
	t.tween_property($Leaf2, "modulate", Color.WHITE, 1.7)
	t.tween_property($Bg, "modulate", Color.WHITE, 1.7)
	await t.finished
	await get_tree().create_timer(.25).timeout
	$AnimatedSprite2D.play("default")
	$AnimatedSprite2D.visible = true
	await get_tree().create_timer(.4).timeout
	$PressSpace.visible = true

func _input(event: InputEvent) -> void:
	if $PressSpace.visible and event.is_action_released("space"):
		await get_tree().create_timer(.25).timeout
		get_tree().change_scene_to_file("res://scenes/custscene_start.tscn")
