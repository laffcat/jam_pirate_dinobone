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

var state := ""
var state_time := 0.0

var possessed := true
var anim_locked := 0.0
@export var speed_projectile := 160.0
@export var gravitate_force := 90.0
var gravitated := false

#
#func _process(delta: float) -> void:
	#z_index = global_position.y

func _process(delta: float):
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
			"stun":
				anim("stun")
				vel = velocity.lerp(Vector2.ZERO, decel * delta)
				
		velocity = vel
		move_and_slide()
	
	
func possession():
	possessed = true
	anim_stun(.5)
	state = ""

func exorcism():
	possessed = false
	if state != "roll":
		anim_stun(.75)
		state = "idle"
		state_time = randf_range(2.5, 4)
	

func anim(a : String):
	if !anim_locked and (!sprite.animation == a): sprite.animation = a
	
func anim_stun(len : float):
	anim_locked += len
	sprite.animation = "twitch"
	
