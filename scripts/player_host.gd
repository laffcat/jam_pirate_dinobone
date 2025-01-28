class_name PlayerHost
extends CharacterBody2D

@export var weapon : PlayerWeapon
@onready var sprite: Sprite2D = $Sprite

var possessed := true

#
#func _process(delta: float) -> void:
	#z_index = global_position.y

func _physics_process(delta: float) -> void:
	if possessed: return
	
	
