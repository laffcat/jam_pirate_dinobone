extends Node

const SHOCK = preload("res://scenes/shock.tscn")

var main : Node2D
var player_host : PlayerHost
var player_wep : PlayerWeapon
var nme_extra := 0

const SCR = Vector2(480, 320)
const HALF_SCR = Vector2(240, 160)

const LAYOUTS : Array[String] = [
		"res://scenes/levelgen/layouts/game1.tscn",
		"res://scenes/levelgen/layouts/game2.tscn",
		"res://scenes/levelgen/layouts/game3.tscn",
	]
var level_pool = LAYOUTS.duplicate()
func pop_layout() -> String:
	if level_pool == []: level_pool = LAYOUTS.duplicate()
	return level_pool.pop_at(randi() % len(level_pool))

const BONETYPES : Array[int] = [0,1,2,3,4,5,6]
var bonetype_pool = BONETYPES.duplicate()
func pop_bonetype() -> int:
	if bonetype_pool == []: bonetype_pool = BONETYPES.duplicate()
	return bonetype_pool.pop_at(randi() % len(bonetype_pool))






signal bonez_updated
var bonez : Array[int] = []
		
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("AAAAA"):
		#bonez.append(randi()%7)
		#bonez_updated.emit()

func shock(from: Node2D, height: int, question := false):
	var dude := SHOCK.instantiate()
	main.add_child(dude)
	dude.global_position = from.global_position
	dude.global_position.y -= height
	if question: dude.frame = 1

func player_dir(from: Node2D, length : float, wep := false) -> Vector2:
	return from.global_position.direction_to(
		(player_host if !wep else player_wep).global_position
	) * length
func player_dist(from: Node2D, wep := false) -> float:
	return from.global_position.distance_to(
		(player_host if !wep else player_wep).global_position
	)



func s2z(input : float, sub : float) -> float: return max(0.0, input - sub)
# subtract to zero




## maybe someday...
#const SKINCLR : Array[Color] = [
	#Color("732c40"), Color("ac4c3f"), Color("ffae71"),
	#Color("362429"), Color("4d3632"), Color("7a4735")
#]
#func blended_skincolors(ratio: float) -> Array[Color]:
	#return [
		#SKINCLR[0].lerp(SKINCLR[3], ratio),
		#SKINCLR[1].lerp(SKINCLR[4], ratio),
		#SKINCLR[2].lerp(SKINCLR[5], ratio),
	#]
