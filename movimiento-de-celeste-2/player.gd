extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var dust_effect = $Dust
@onready var dash_smoke = $DashSmoke
@onready var land = $Land


var speed = 200
var acceleration = 700
var friction = 1000

var gravity = 1500

var jump_force = -500
var max_jumps = 2
var jumps_left = 2

var dash_speed = 500
var dash_time = 0.15
var dash_timer = 0
var can_dash = true
var dash_direction = Vector2.ZERO

var wall_slide_speed = 150
var wall_jump_force = -500
var wall_jump_push = 500

var was_on_floor = false

var did_double_jump = false


func _physics_process(delta):
	$Label.text = str(velocity.length())

	var direction = Input.get_axis("left", "right")
	var prev_on_floor = was_on_floor
	var prev_velocity_y = velocity.y

	dust()

	if direction != 0:
		animated_sprite.flip_h = direction < 0

	update_animations()

	if dash_timer > 0:
		dash_timer -= delta
		velocity = dash_direction * dash_speed
	else:
		if not is_on_floor():
			if velocity.y > 0:
				velocity.y += gravity * 1.5 * delta
			else:
				velocity.y += gravity * delta
		else:
			jumps_left = max_jumps
			can_dash = true

		if not is_on_floor() and is_on_wall() and direction != 0:
			if velocity.y > wall_slide_speed:
				velocity.y = wall_slide_speed

		if direction != 0:
			if is_on_floor():
				velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
			else:
				velocity.x = move_toward(velocity.x, direction * speed, acceleration * 0.6 * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)

	if Input.is_action_just_pressed("jump") and jumps_left > 0:
		velocity.y = jump_force


		if jumps_left == 1:
			did_double_jump = true

		jumps_left -= 1

	if Input.is_action_just_pressed("jump") and is_on_wall() and not is_on_floor():
		velocity.y = wall_jump_force
		
		if direction != 0:
			velocity.x = -direction * wall_jump_push

	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5

	if Input.is_action_just_pressed("dash") and can_dash:
		can_dash = false
		dash_timer = dash_time

		var input_dir = Input.get_vector("left", "right", "up", "down")

		if input_dir == Vector2.ZERO:
			input_dir = Vector2.LEFT if animated_sprite.flip_h else Vector2.RIGHT

		dash_direction = input_dir.normalized()
		velocity = dash_direction * dash_speed

		if dash_direction.x != 0:
			animated_sprite.flip_h = dash_direction.x > 0

		trigger_dash_smoke()

	move_and_slide()

	if is_on_floor() and not prev_on_floor:
		if did_double_jump and prev_velocity_y > 50:
			trigger_land()

		did_double_jump = false

	was_on_floor = is_on_floor()


func trigger_land():
	land.emitting = false
	land.emitting = true


func trigger_dash_smoke():
	dash_smoke.position = Vector2.ZERO

	if dash_direction.x > 0:
		dash_smoke.direction = Vector2(-1, 0)
		dash_smoke.position.x = -10
	elif dash_direction.x < 0:
		dash_smoke.direction = Vector2(1, 0)
		dash_smoke.position.x = 10

	dash_smoke.emitting = false
	dash_smoke.emitting = true


func update_animations():
	if dash_timer > 0:
		animated_sprite.play("dash")
		return

	if not is_on_floor():
		if velocity.y < 0:
			if jumps_left < max_jumps - 1:
				animated_sprite.play("double jump")
			else:
				animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
		return

	if velocity.x != 0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")


func dust():
	if velocity.length() > 100 and is_on_floor(): 
		dust_effect.emitting = true
	else:
		dust_effect.emitting = false
