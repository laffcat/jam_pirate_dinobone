extends Sprite2D


var lifespan := .7

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	lifespan -= delta
	if lifespan <= 0: call_deferred("queue_free"); return
	position.y -= 10 * delta
