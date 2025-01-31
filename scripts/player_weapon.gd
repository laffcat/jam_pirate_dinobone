class_name PlayerWeapon
extends CharacterBody2D

signal dead

var already_hit : Array[CharacterBody2D] = []

@export var hp_max := 150
@onready var meter_hp: ColorRect = $"../Camera2D/Hud/HpBar/Meter"
var hp : int:
	set(i):
		hp = max(0, min(hp_max, i))
		var ratio := float(hp) / float(hp_max)
		meter_hp.material.set_shader_parameter("threshold", ratio)
		if hp == 0:
			host.gameover()
		
@export var nrg_max := 150.0
@onready var meter_nrg: ColorRect = $"../Camera2D/Hud/NrgBar/Meter"
var nrg : float:
	set(i):
		nrg = max(0, min(nrg_max, i))
		var ratio := nrg / nrg_max
		meter_nrg.material.set_shader_parameter("threshold", ratio)
		if nrg == 0:
			state = "free"
			host.gameover()
			die()


@export var host : PlayerHost
@export var host_tether_dist := 10.0
var host_disconnect_dist := 75.0

signal host_start
signal host_end
var hosted := true:
	set(b):
		hosted = b
		if b: 
			host.possession()
			$Audio2D/Possession.play(1.8)
		else: 
			host.exorcism()

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
func side_flip(): 
	if nrg == 0: return
	side *= -1; $SpriteRoot/Bone.scale.y = side

var state : String:
	set(new_state): 
		state = new_state
		match new_state:
			"free": 
				sprite_reset()
				already_hit = []
				$HitboxProjectile.set_deferred("monitoring", false)
				$HitboxMelee.set_deferred("monitoring", false)
			"projectile":
				$HitboxProjectile.set_deferred("monitoring", false)
				$HitboxMelee.set_deferred("monitoring", false)
			
	
	
func _ready():
	Global.player_wep = self
	state = "free"
	$Hurtbox.set_deferred("monitoring", true)
	hp = hp_max
	nrg = nrg_max
	#$Hurtbox.body_entered.connect(hurt)


func _process(delta: float) -> void:
	match state:
		"projectile":
			$SpriteRoot.rotate(deg_to_rad(-920 * side * delta))
	if $"../Audio/Music1".playing and global_position.x > 1550:
		$"../Audio/Music1".stop()
		$"../Audio/Music2".play()

func _physics_process(delta: float) -> void:
	match state:
		
		"free":
			if nrg > 0:
				melee(delta)
				throw_self()
				throw_host()
				gravitate_host(delta)
			
			
			var input_dir := Input.get_vector("left", "right", "up", "down").normalized()
			if input_dir and nrg > 0:
				var speed := speed_max_hosted if hosted else speed_max_floating
				vel = lerp(vel, input_dir * speed, accel * delta)
			else:
				vel = lerp(vel, Vector2.ZERO, decel * delta)
				
			if !is_meleeing and nrg > 0: 
				var rot_new = global_position.direction_to($"../Camera2D/Cursor".global_position).angle()
				rotation = lerp_angle(rotation, rot_new, rot_speed * delta)
		
		"projectile":
			melee(delta)
			if is_on_wall() or is_on_floor() or is_on_ceiling():
				blowback(.2)
				state = "free"
				clk_melee = .3
		
	velocity = vel + vel_add
			
	move_and_slide()
	
	if vel_add != Vector2.ZERO:
		#print(str(vel_add))
		var speed_new := Global.s2z(vel_add.length(), vel_add_decay * delta)
		vel_add = vel_add.limit_length(speed_new)
		
	if hosted: 
		var host_distance : float = min(host_tether_dist, global_position.distance_to(host.global_position))
		if host_distance >= host_disconnect_dist:
			hosted = false
		else:	
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
			
			nrg += 45 * delta
	else:
		nrg -= (4 if hp > 0 else 50) * delta
	
	
	
		
func sprite_reset():
	side_flip()
	$SpriteRoot/Bone.frame = 0
	$SpriteRoot.rotation = deg_to_rad(120 * side)

func melee(delta : float):
	if clk_melee: clk_melee = Global.s2z(clk_melee, delta); return
	if !Input.is_action_pressed("space"): return
	if is_meleeing: return
	
	$Audio2D/Woosh1.play()
	if !hosted: nrg -= 6
	if state != "free": 
		state = "free"
		vel *= .4
	is_meleeing = true
	rotation = global_position.direction_to($"../Camera2D/Cursor".global_position).angle()
	vel_add = scooch_melee * Vector2(1.0, 0).rotated(rotation)
	velocity += vel_add * .4
	$HitboxMelee.set_deferred("monitoring", true)
	$SpriteRoot.rotation = deg_to_rad(-70 * side)
	$SpriteRoot/Bone.frame = 1
	await get_tree().create_timer(.1).timeout
	$HitboxMelee.set_deferred("monitoring", false)
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
	if hosted: 
		hosted = false
	else:
		nrg -= 10
	$HitboxProjectile.set_deferred("monitoring", true)
	$SpriteRoot/Bone.frame = 2
	vel = speed_projectile * global_position.direction_to($"../Camera2D/Cursor".global_position)
	vel_add += vel * .03
	clk_melee = .3
	
func throw_host():
	if clk_melee: return
	if !Input.is_action_pressed("mouse2"): return
	if is_meleeing: return
	if !hosted: return
	if host.anim_locked: return
	
	nrg -= 20
	host.state = "roll"
	hosted = false
	host.vel = host.speed_projectile * host.global_position.direction_to($"../Camera2D/Cursor".global_position)
	var hvx : int = sign(host.vel.x)
	if hvx: host.sprite.scale.x = hvx

func gravitate_host(delta : float):
	host.gravitated = false
	if !Input.is_action_pressed("mouse2"): 
		if $Audio2D/Wawawa.playing: $Audio2D/Wawawa.stop()
		return
	if hosted: return
	if host.state == "roll": return
	if host.state == "stun": return
	
	if !$Audio2D/Wawawa.playing: $Audio2D/Wawawa.play()
	nrg -= 11 * delta
	host.gravitated = true
	host.vel += host.global_position.direction_to(global_position) * host.gravitate_force * delta

		
func hurt(body: Node2D):
	#print("ding!")
	match state:
		"projectile":
			pass
			#if body is TileMapLayer:
				#blowback(.2)
				#state = "free"
		"free":
			if !hosted and (body is PlayerHost) and body.state != "roll" and body.state != "stun" \
			and hp > 0 and nrg > 0:
				hosted = true

func check_host():
	for body in $Hurtbox.get_overlapping_bodies():
		match state:
			"free":
				if !hosted and (body is PlayerHost) and body.state != "roll" \
				and hp > 0 and nrg > 0:
					hosted = true
		

func hurt_area(area: Area2D) -> void:
	var shpee := area.get_parent()
	if shpee is EnemyHuman:
		shpee.aggro = true
	if (shpee is Bonez) and hosted:
		Global.bonez.append(shpee.sprite.frame)
		Global.bonez_updated.emit() 
		if shpee.final: victory()
		shpee.call_deferred("queue_free")
		
func victory():
	failsafe()
	if Global.nmes_left > 0: 
		await Global.nmes_cleared
	await get_tree().create_timer(4.0).timeout
	if hp > 0 and nrg > 0:
		host.cleanup()
		get_tree().reload_current_scene()

func failsafe():
	await get_tree().create_timer(9.0).timeout
	Global.nmes_cleared.emit()


func _on_hitbox_melee_body_entered(body: Node2D) -> void:
	if body is EnemyHuman and !body.invuln:
		$Audio2D/Hit.play()
		print("melee hit")
		body.hp -= 1
		body.vel = 180 * global_position.direction_to($"../Camera2D/Cursor".global_position)
		body.state = "hurt"
		
func _on_hitbox_projectile_body_entered(body: Node2D) -> void:
	if body is EnemyHuman and !body.invuln: #and !(body in already_hit):
		$Audio2D/Hit.play()
		print("proj hit")
		body.hp -= 1
		$HitboxProjectile.set_deferred("monitoring", false)
		body.vel = Global.player_dir(body, -120, true)
		body.state = "hurt"
		state = "free"
		blowback(.1)
		clk_melee = .4
		#already_hit.append(body)
		
	

func blowback(amt: float):
	vel = vel.rotated(deg_to_rad(randi_range(160, 200)))
	vel *= amt
	vel_add = vel



func die():
	dead.emit()
	$MeshInstance2D.visible = false
	$SpriteRoot/Bone.modulate = Color.WEB_GRAY








#
