class_name Bonez
extends Node2D

@onready var sprite: Sprite2D = $Sprite2D


@export var final := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.frame = Global.pop_bonetype()
