class_name EnemyHuman
extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var bounce_timer_x := 0.0
var bounce_timer_y := 0.0

var final := false

var vel := Vector2.ZERO

var hp := 4

const HEIGHT := 19
const TURN_SPEED := 2.5

var invuln = false
var state_time := 0.0
var curious := false:
	set(b):
		if b and !curious and !aggro:
			Global.shock(self, HEIGHT, true)
			$Audio/Speak.play()
		curious = b
var aggro := false:
	set(b):
		if b and !aggro:
			Global.shock(self, HEIGHT)
			$Audio/Speak.play()
			vel = Global.player_dir(self, 1.0)
			state = "twitch"
			#if state == "idle": 
				#state = "walk"
				#state_time = randf_range(1.5, 3)
				#vel = Global.player_dir(self, 1.0)
		aggro = b

var speed_walk := 60.0
var pursuit_accel := 30.0

var lastvel := Vector2.ZERO

var state : String:
	set(s):
		match state: 
			"windup": 
				speed_walk = 60.0
				$Hitbox.set_deferred("monitorable", false)
			"hurt": invuln = false
				
		state = s
		sprite.play(s)
		match s:
			"idle": state_time = randf_range(2, 4)
			"walk": 
				if !aggro: 
					state_time = randf_range(3, 5)
					vel = (Vector2.RIGHT if randi()%2 else Vector2.LEFT) \
						.rotated(deg_to_rad(randi_range(-70, 70))) * speed_walk
				else:
					state_time = randf_range(1.5, 3)
					vel = Global.player_dir(self, 1.0)
			"windup": 
				state_time = randf_range(2, 3)
				$Hitbox.set_deferred("monitorable", true)
				vel = Global.player_dir(self, 1.0)
			"swing": 
				state_time = 1.2
				vel *= .3
			"twitch": state_time = .8
			"hurt": 
				$Audio/Speak.stop()
				$Audio/Hit.play()
				state_time = .4
				invuln = true
			"die": 
				$Audio/Speak.stop()
				$Audio/Hit.stop()
				$Audio/Die.play()
				invuln = true
				state_time = 999.0
				await sprite.animation_finished
				if final: Global.nmes_left -= 1
				call_deferred("queue_free")

func _ready():
	state = "idle"
	
	var my_pitch = randf_range(.8, 1.3)
	for each in $Audio.get_children():
		#each.stream.resource_local_to_scene = true
		each.pitch_scale = my_pitch

func _physics_process(delta: float) -> void:
	
	match state:
		"idle":
			decel(delta)
			state_wait(delta)
		"walk": 
			if bounce_timer_x: bounce_timer_x = Global.s2z(bounce_timer_x, delta)
			elif is_on_wall(): 
				vel.x *= -1
				bounce_timer_x = .2
			if bounce_timer_y: bounce_timer_y = Global.s2z(bounce_timer_y, delta)
			elif is_on_floor() or is_on_ceiling(): 
				vel.y *= -1
				bounce_timer_y = .2
		
			if aggro:
				vel = lerp( 
					vel.normalized(), 
					Global.player_dir(self, 1), 
					TURN_SPEED * delta 
					).normalized() * speed_walk
				sprite_flip_to_player()
				if Global.player_dist(self) < 30:
					state = "windup"
			else: 
				sprite_flip_to_vel()
			
			state_wait(delta)
				
			
		"windup": 
			speed_walk += pursuit_accel * delta
			vel = lerp( 
				vel.normalized(), 
				Global.player_dir(self, 1), 
				TURN_SPEED * delta * 2
				).normalized() * speed_walk
			sprite_flip_to_player()
			state_wait(delta)
		"swing": 
			decel(delta)
			state_wait(delta)
		"twitch": 
			decel(delta)
			state_wait(delta)
		"hurt": 
			decel(delta)
			state_wait(delta)
		"die": pass

	velocity  = vel
	move_and_slide()
	


func state_wait(delta : float):
	if state_time: state_time = Global.s2z(state_time, delta); return
	
	match state:
		"idle": state = "walk"
		"walk": 
			if !aggro:  state = "idle"
			else: state = "windup"
		"windup": 
			state = "swing"
		"swing": 
			state = "walk" if aggro else "idle"
		"twitch": 
			state = ("windup" if !randi()%3 else "walk") if aggro else "idle"
		"hurt": 
			invuln = false
			state = "die" if hp <= 0 else "twitch"
		"die": pass
			
func decel(delta : float):
	vel = vel.lerp(Vector2.ZERO, 3 * delta)



func sprite_flip_to_vel():
	var hvx : int = sign(vel.x)
	if hvx: sprite.scale.x = hvx

func sprite_flip_to_player():
	var shpee : int = sign(Global.player_dir(self, 1.0).x)
	if shpee: sprite.scale.x = shpee












##
