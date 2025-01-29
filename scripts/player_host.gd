class_name PlayerHost
extends CharacterBody2D

@export var weapon : PlayerWeapon
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var possessed := true
var anim_locked := 0.0

#
#func _process(delta: float) -> void:
	#z_index = global_position.y

func _process(delta: float):
	if anim_locked: 
		anim_locked -= delta
		return

func _physics_process(delta: float) -> void:
	if possessed: return
	
	
func possession():
	possessed = true
	anim_stun(.2)

func exorcism():
	possessed = false
	anim_stun(.35)
	


func anim_stun(len : float):
	anim_locked += len
	sprite.animation = "twitch"
	
