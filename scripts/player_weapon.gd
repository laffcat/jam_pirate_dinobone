class_name PlayerWeapon
extends CharacterBody2D

@export var host : PlayerHost
@export var host_tether_dist := 60.0
var hosted := true

@export var speed_max_hosted := 160.0
@export var speed_max_floating := 110.0
@export var accel := .5
@export var decel := .4
var rot_speed := 5.0

var vel := Vector2.ZERO
var vel_add := Vector2.ZERO
var vel_add_decay := 200.0

@export var scooch_melee := 60.0
@export var cd_melee := .4
var cd_melee_mult := 1.0
var clk_melee := 0.0
var is_meleeing := false

enum S { L = -1, R = 1 }
var side := S.R
func side_flip(): side *= -1; $SpriteRoot/Bone.scale.y = side


#func _process(delta: float) -> void:
	#z_index = global_position.y

func _physics_process(delta: float) -> void:
	
	melee(delta)
	
			
	var input_dir := Input.get_vector("left", "right", "up", "down").normalized()
	if input_dir:
		var speed := speed_max_hosted if hosted else speed_max_floating
		vel = lerp(vel, input_dir * speed, accel * delta)
	else:
		vel = lerp(vel, Vector2.ZERO, decel * delta)
	
	if !is_meleeing: 
		var rot_new = global_position.direction_to($"../Camera2D/Cursor".global_position).angle()
		rotation = lerp_angle(rotation, rot_new, rot_speed * delta)
	
	velocity = vel + vel_add
	move_and_slide()
	if vel_add != Vector2.ZERO:
		#print(str(vel_add))
		var speed_new := Global.s2z(vel_add.length(), vel_add_decay * delta)
		vel_add = vel_add.limit_length(speed_new)
		
	if hosted:
		var host_distance : float = min(host_tether_dist, global_position.distance_to(host.global_position))
		var host_direction : Vector2 = global_position.direction_to(host.global_position)
		var host_target : Vector2 = global_position + host_distance * host_direction
		var host_vel := host.global_position.distance_to(host_target) * host.global_position.direction_to(host_target) * (1.0 / delta)
		if host_vel:
			host.velocity = host_vel
			var hvx_sign : int = sign(host_vel.x)
			if hvx_sign != 0: host.sprite.scale.x = hvx_sign
		
		host.move_and_slide()
	
		

func melee(delta : float):
	if clk_melee: clk_melee = Global.s2z(clk_melee, delta); return
	if !Input.is_action_pressed("space"): return
	if is_meleeing: return
	
	is_meleeing = true
	vel_add = scooch_melee * Vector2(1.0, 0).rotated(rotation)
	velocity += vel_add * .4
	$Hitbox.monitoring = true
	$SpriteRoot.rotation = deg_to_rad(-70 * side)
	$SpriteRoot/Bone.frame = 1
	await get_tree().create_timer(.1).timeout
	$Hitbox.monitoring = false
	$SpriteRoot.rotation = deg_to_rad(-100 * side)
	$SpriteRoot/Bone.frame = 0
	await get_tree().create_timer(.03).timeout
	$SpriteRoot.rotation = deg_to_rad(-115 * side)
	await get_tree().create_timer(.03).timeout
	$SpriteRoot.rotation = deg_to_rad(-120 * side)
	is_meleeing = false
	clk_melee = cd_melee * cd_melee_mult
	await get_tree().create_timer(clk_melee * .5).timeout
	side_flip()
	
	
















#
