extends CharacterBody2D

@export var speed : float = 200.0
@export var jump_velocity : float = -250.0
@export var double_jump_velocity : float = -150.0

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var has_double_jump : bool = false
var animation_locked : bool = false
var direction : Vector2 = Vector2.ZERO
var was_in_air : bool = false

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		was_in_air = true
	else:
		if was_in_air:
			land()
		was_in_air = false

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump()
		elif has_double_jump:
			double_jump()

	direction = Input.get_vector("left", "right", "up", "down")
	if direction.x != 0 && animated_sprite.animation != "jump_end":
		velocity.x = direction.x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
	update_animation()
	update_facing_direction()

func update_animation():
	if not animation_locked:
		if is_on_floor():
			if direction.x == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("jump_loop")

func update_facing_direction():
	if (direction.x != 0):
		animated_sprite.flip_h = direction.x < 0

func jump():
	velocity.y = jump_velocity
	animated_sprite.play("jump_start")
	has_double_jump = true
	animation_locked = true
	
func double_jump():
	velocity.y = double_jump_velocity
	animated_sprite.play("jump_double")
	has_double_jump = false
	animation_locked = true

func land():
	animated_sprite.play("jump_end")
	animation_locked = true

func _on_animated_sprite_2d_animation_finished():
	if ["jump_start", "jump_double", "jump_end"].has(animated_sprite.animation):
		animation_locked = false
