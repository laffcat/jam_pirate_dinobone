class_name PlayerWeapon
extends CharacterBody2D

@export var hp_max : int
@export var nrg_max : int

@export var host : PlayerHost
@export var host_tether_dist := 60.0

signal host_start
signal host_end
var hosted := true:
	set(b):
		hosted = b
		if b: host.possession()
		else: host.exorcism()

@export var speed_max_hosted := 160.0
@export var speed_max_floating := 90.0
@export var speed_projectile := 290.0
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

var state : String:
	set(new_state): 
		state = new_state
		match new_state:
			"free": sprite_reset()
			
	
	
func _ready():
	state = "free"
	$Hurtbox.monitoring = true
	#$Hurtbox.body_entered.connect(hurt)


func _process(delta: float) -> void:
	match state:
		"projectile":
			$SpriteRoot.rotate(deg_to_rad(-920 * side * delta))

func _physics_process(delta: float) -> void:
	match state:
		
		"free":
			melee(delta)
			throw_self()
			
			var input_dir := Input.get_vector("left", "right", "up", "down").normalized()
			if input_dir:
				var speed := speed_max_hosted if hosted else speed_max_floating
				vel = lerp(vel, input_dir * speed, accel * delta)
			else:
				vel = lerp(vel, Vector2.ZERO, decel * delta)
				
			if !is_meleeing: 
				var rot_new = global_position.direction_to($"../Camera2D/Cursor".global_position).angle()
				rotation = lerp_angle(rotation, rot_new, rot_speed * delta)
		
		"projectile":
			melee(delta)
		
	velocity = vel + vel_add
			
			
			
	move_and_slide()
	if vel_add != Vector2.ZERO:
		#print(str(vel_add))
		var speed_new := Global.s2z(vel_add.length(), vel_add_decay * delta)
		vel_add = vel_add.limit_length(speed_new)
		
	if hosted: ## TODO: set up caveman animations here!
		var host_distance : float = min(host_tether_dist, global_position.distance_to(host.global_position))
		var host_direction : Vector2 = global_position.direction_to(host.global_position)
		var host_target : Vector2 = global_position + host_distance * host_direction
		var host_vel := host.global_position.distance_to(host_target) * host.global_position.direction_to(host_target)
		if host_vel:
			host.anim("held_move")
			host.velocity = host_vel * (1.0 / delta)
			var hvx_sign : int = sign(host_vel.x)
			if hvx_sign != 0: host.sprite.scale.x = hvx_sign
		else:
			host.anim("held_idle")
			host.velocity = host.global_position.distance_to(global_position) * host.global_position.direction_to(global_position)
		
		host.move_and_slide()
		if velocity.length() < vel.length(): vel = velocity
	
		
func sprite_reset():
	side_flip()
	$SpriteRoot/Bone.frame = 0
	$SpriteRoot.rotation = deg_to_rad(120 * side)

func melee(delta : float):
	if clk_melee: clk_melee = Global.s2z(clk_melee, delta); return
	if !Input.is_action_pressed("space"): return
	if is_meleeing: return
	
	if state != "free": 
		state = "free"
		vel *= .4
	is_meleeing = true
	rotation = global_position.direction_to($"../Camera2D/Cursor".global_position).angle()
	vel_add = scooch_melee * Vector2(1.0, 0).rotated(rotation)
	velocity += vel_add * .4
	$HitboxMelee.monitoring = true
	$SpriteRoot.rotation = deg_to_rad(-70 * side)
	$SpriteRoot/Bone.frame = 1
	await get_tree().create_timer(.1).timeout
	$HitboxMelee.monitoring = false
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
	
func throw_self():
	if clk_melee: return
	if !Input.is_action_pressed("mouse1"): return
	if is_meleeing: return
	
	state = "projectile"
	if hosted: hosted = false
	$SpriteRoot/Bone.frame = 2
	vel = speed_projectile * global_position.direction_to($"../Camera2D/Cursor".global_position)
	global_position += vel * .03
	clk_melee = .3
	



		
func hurt(body: Node2D):
	#print("ding!")
	match state:
		"projectile":
			if body is TileMapLayer:
				blowback(.2)
				state = "free"
		"free":
			if !hosted and (body is PlayerHost):
				hosted = true



func blowback(amt: float):
	vel = vel.rotated(deg_to_rad(randi_range(160, 200)))
	vel *= amt
	vel_add = vel












#
