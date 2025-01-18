class_name PlayerWeapon
extends CharacterBody2D

@export var host : PlayerHost
@export var host_tether_dist := 30.0
var hosted := true

@export var speed_max_hosted := 200.0
@export var speed_max_floating := 100.0
@export var accel := .5
@export var decel := .4


		

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "up", "down").normalized()
	if input_dir:
		var speed := speed_max_hosted if hosted else speed_max_floating
		velocity = lerp(velocity, input_dir * speed, accel * delta)
	else:
		velocity = lerp(velocity, Vector2.ZERO, decel * delta)
	
	rotation = global_position.direction_to($"../Camera2D/Cursor".global_position).angle()
	
	move_and_slide()
	
	var host_distance : float = min(host_tether_dist, global_position.distance_to(host.global_position))
	var host_direction : Vector2 = global_position.direction_to(host.global_position)
	var host_target : Vector2 = global_position + host_distance * host_direction
	host.global_position = round(host_target) ## TODO: you're not supposed to set physics body position every frame, this is hack
	#host.velocity = host.global_position.distance_to(host_target) * host.global_position.direction_to(host_target)
	host.move_and_slide()
