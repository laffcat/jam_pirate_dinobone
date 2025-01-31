class_name PlayerHost
extends CharacterBody2D

@export var weapon : PlayerWeapon
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var speed_walk := 30.0
@export var accel := 1.0
@export var decel := 1.0
var vel := Vector2.ZERO
var bounce_timer_x := 0.0
var bounce_timer_y := 0.0


var fucking_dead := false

var state := "":
	set(s):
		if state == "stun":
			weapon.check_host()
		if s == "roll":
			$Roll.play()
			$HitboxRoll.set_deferred("monitoring", true)
			invuln = true
		else: 
			$Roll.stop()
			$HitboxRoll.set_deferred("monitoring", false)
			invuln = false
		if s != "stun":
			sprite.material.set_shader_parameter("colors", base_colors)
			
		state = s
		
var state_time := 0.0

var possessed := true
var anim_locked := 0.0
@export var speed_projectile := 160.0
@export var gravitate_force := 90.0
var gravitated := false

var invuln = false

@export var owie_colors : Array[Color]
var base_colors : Array
#
#func _process(delta: float) -> void:
	#z_index = global_position.y

func _ready():
	Global.player_host = self
	base_colors = sprite.material.get_shader_parameter("colors") as Array
	

func _process(delta: float):
	if fucking_dead: return
	if anim_locked: 
		anim_locked = Global.s2z(anim_locked, delta)
		return
	if state_time:
		state_time = Global.s2z(state_time, delta)
		return
	## state change! actual state behavior in phys process
	match state:
		"", "idle":
			state = "walk"
			vel = (Vector2.RIGHT if randi()%2 else Vector2.LEFT).rotated(deg_to_rad(randi_range(-30, 30))) * speed_walk
			state_time = randf_range(2.6, 4.5)
		"walk", "stun":
			
			state = "idle"
			state_time = randf_range(2, 4)
	

func _physics_process(delta: float) -> void:
	if possessed: return
	if fucking_dead: return
	else:
		match state:
			"", "idle":
				anim("free_idle")
				if !gravitated: vel = velocity.lerp(Vector2.ZERO, decel * delta)
			"walk":
				anim("free_move")
				if bounce_timer_x: bounce_timer_x = Global.s2z(bounce_timer_x, delta)
				elif is_on_wall(): 
					vel.x *= -1
					bounce_timer_x = .2
				if bounce_timer_y: bounce_timer_y = Global.s2z(bounce_timer_y, delta)
				elif is_on_floor() or is_on_ceiling(): 
					vel.y *= -1
					bounce_timer_y = .2
		
				var hvx : int = sign(vel.x)
				if hvx: sprite.scale.x = hvx
			"roll":
				anim("roll")
				if is_on_wall() or is_on_floor() or is_on_ceiling():
					vel *= -.6
					state = "stun"
					state_time = 1.4
					$HitboxRoll.set_deferred("monitoring", false)
			"stun":
				$HitboxRoll.set_deferred("monitoring", false)
				anim("stun")
				vel = velocity.lerp(Vector2.ZERO, decel * delta)
				
		velocity = vel
		move_and_slide()
	
	
func possession():
	if fucking_dead: return
	possessed = true
	anim_stun(.5)
	state = ""

func exorcism():
	if fucking_dead: return
	possessed = false
	if state != "roll" and invuln == false:
		anim_stun(.75)
		state = "idle"
		state_time = randf_range(2.5, 4)
	else:
		$HitboxRoll.set_deferred("monitoring", true)
	

func anim(a : String):
	if fucking_dead: return
	if !anim_locked and (!sprite.animation == a): sprite.animation = a
	
func anim_stun(len : float):
	anim_locked += len
	sprite.animation = "twitch"
	


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if fucking_dead: return
	var shpee := area.get_parent()
	if shpee is EnemyHuman:
		match area.name:
			"DetectionRadius":
				shpee.curious = true
			"Hitbox":
				shpee.state = "swing"
				owie(shpee)




func owie(assailant: Node2D):
	if fucking_dead: return
	if invuln: return
	
	$Hit.play()
	velocity = Global.player_dir(assailant, 80)
	invuln = true
	weapon.hosted = false
	weapon.hp -= 15
	# this color shit is so jank LMAO
	sprite.material.set_shader_parameter("colors", owie_colors)
	state = "stun"
	state_time = 2.0 if weapon.hp > 0 else 999.0
	await get_tree().create_timer(.6).timeout
	if !fucking_dead: sprite.material.set_shader_parameter("colors", base_colors)
	await get_tree().create_timer(.4).timeout
	if weapon.hp > 0: invuln = false
	



func _on_hitbox_roll_body_entered(body: Node2D) -> void:
	if fucking_dead: return
	if body is EnemyHuman:
		$Knock.play()
		body.hp -= 1
		body.vel = Global.player_dir(body, -300)
		body.state = "hurt"
		await get_tree().process_frame
		body.state_time = 1.4



func cleanup():
	sprite.material.set_shader_parameter("colors", base_colors)


func gameover():
	if weapon.hp <= 0: fucking_dead = true
	if possessed: $Sprite.play("stun")
	var dead_colors := base_colors.duplicate()
	dead_colors[0].a = 0.0
	sprite.material.set_shader_parameter("colors", dead_colors)







##
