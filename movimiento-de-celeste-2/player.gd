extends CharacterBody2D

var speed = 500
var acceleration = 1500
var friction = 2500

var gravity = 2000

var jump_force = -800
var max_jumps = 2
var jumps_left = 2

var dash_speed = 700
var dash_time = 0.15
var dash_timer = 0
var can_dash = true
var dash_direction = Vector2.ZERO


var wall_slide_speed = 150
var wall_jump_force = -800
var wall_jump_push = 500

func _physics_process(delta):

	var direction = Input.get_axis("left", "right")


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

		var input_dir = Vector2(
			Input.get_axis("left", "right"),
			Input.get_axis("up", "down")
		)

		if input_dir == Vector2.ZERO:
			input_dir = Vector2.RIGHT if velocity.x >= 0 else Vector2.LEFT

		dash_direction = input_dir.normalized()
		velocity = dash_direction * dash_speed

	move_and_slide()
