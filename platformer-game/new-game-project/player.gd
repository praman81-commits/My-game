extends CharacterBody2D


@export var speed = 300.0
@export var  jump_velocity = -400.0
@export var acceleration: float = 15.0
@export var jump = 1

enum state {IDLE,RUNNING,JUMPUP,JUMPDOWN,DEAD,JUMPATTACK,JUMPTHROW,SLIDE,THROW}

var anim_state = state.IDLE

@onready var animator = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer

# Get the gravity from the project setting to be synced with RegidBody  nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func update_state():
	if anim_state == state.DEAD:
		return
	if is_on_floor():
		if velocity == Vector2.ZERO:
			anim_state = state.IDLE
		elif velocity.x != 0:
			anim_state = state.RUNNING
	else:
		if velocity.y < 0:
			anim_state = state.JUMPUP
		else:
			anim_state = state.JUMPDOWN
			
func update_animation(direction):
	if direction > 0:
		animator.flip_h = false
	elif direction < 0:
		animator.flip_h = true


	if Input.is_action_just_pressed("throw"):
		if is_on_floor():
			anim_state = state.THROW
		else:
			anim_state = state.JUMPTHROW
		return

	if Input.is_action_just_pressed("jumpattack") and not is_on_floor():
		anim_state = state.JUMPATTACK
		return

	# 3. Your existing normal movement state checks
	if is_on_floor():
		if velocity.x == 0:
			anim_state = state.IDLE
		else:
			anim_state = state.RUNNING
	else:
		if velocity.y < 0:
			anim_state = state.JUMPUP
		else:
			anim_state = state.JUMPDOWN
func update_animation(direction):
	if direction > 0:
		animator.flip_h = false
	elif direction < 0:
		animator.flip_h = true
		
	# Move the match block back here!
	match anim_state:
		state.IDLE:
			animation_player.play("idle")
		state.RUNNING:
			animation_player.play("run")
		state.JUMPUP:
			animation_player.play("jumpup")
		state.JUMPDOWN:
			animation_player.play("jumpdown")
		state.DEAD:
			animation_player.play("dead")
		state.JUMPATTACK:
			animation_player.play("jump attack")
		state.JUMPTHROW:
			animation_player.play("jump throw")
		state.SLIDE:
			animation_player.play("slide")
		state.THROW:
			animation_player.play("throw")

# --- Make sure this function is entirely separate ---
func update_state():
	if anim_state == state.DEAD:
		return
		
	# 1. Reset special actions back to normal once their animation finishes
	if anim_state in [state.SLIDE, state.THROW, state.JUMPATTACK, state.JUMPTHROW]:
		if not animation_player.is_playing():
			if is_on_floor():
				anim_state = state.IDLE
			else:
				anim_state = state.JUMPDOWN
		else:
			return 

	# 2. Check for inputs
	if Input.is_action_just_pressed("slide") and is_on_floor():
		anim_state = state.SLIDE
		return
	if Input.is_action_just_pressed("throw"):
		if is_on_floor():
			anim_state = state.THROW
		else:
			anim_state = state.JUMPTHROW
		return
	if Input.is_action_just_pressed("jumpattack") and not is_on_floor():
		anim_state = state.JUMPATTACK
		return

	# 3. Normal movement
	if is_on_floor():
		if velocity.x == 0:
			anim_state = state.IDLE
		else:
			anim_state = state.RUNNING
	else:
		if velocity.y < 0:
			anim_state = state.JUMPUP
		else:
			anim_state = state.JUMPDOWN
	update_state()
	update_animation(direction)
	move_and_slide()
