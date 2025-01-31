extends Camera2D

@export var tracking_speed := 2.0
@export_range(.5, 1.0, .05) var tracking_threshold := .6
@export_range(0.0, 0.5, .05) var backtracking_threshold := .3
func player_xpos_suv() -> float: return ( 
	($"../PlayerWeapon".global_position.x + $Cursor.global_position.x) * .5 - position.x 
	) / Global.SCR.x
# returns player's relative xpos as if it were a screen UV - 0.0 to 1.0 


func _ready():
	await get_tree().create_timer(.3).timeout
	var t := get_tree().create_tween()
	t.tween_property($ColorRect3, "position:y", 480, .6)
	$"../PlayerWeapon".dead.connect(
		func():
			$Cursor.disabled = true
			$Cursor.visible = false
			await get_tree().create_timer(2).timeout
			$Hud/GameOver.visible = true
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var follow := player_xpos_suv()
	if follow > tracking_threshold:
		position.x = round( lerp(
			position.x, 
			float( position.x + (follow - tracking_threshold) * Global.SCR.x ),
			tracking_speed * delta
		) )
		
	elif follow < backtracking_threshold:
		position.x = round( lerp(
			position.x, 
			float( max( 0, position.x + (follow - tracking_threshold) * Global.SCR.x ) ),
			tracking_speed * delta
		) )


func trigger_spawner(area: Area2D) -> void:
	area.get_parent().spawn()
