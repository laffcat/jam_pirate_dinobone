extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var d : float = $"../PlayerWeapon".global_position.x - position.x
	if d > 240:
		position.x += d - 240
