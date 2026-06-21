extends CharacterBody2D


@export var speed = 300.0
@export var  jump_velocity = -400.0
@export var acceleration: float = 15.0
@export var jump = 1

enum state {IDLE,RUNNING,JUMPUP,JUMPDOWN,DEAD,JUMPATTCK,JUMPTHROW,SLIDE,THROW}

var anim_state = state.IDLE

@onready var animator = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer

# Get the gravity from the project setting to be synced with RegidBody  nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_graviy")

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
	match anim_state:
		state.IDLE:
			animation_player.play("idle")
		state.RUNNING:
			animation_player.play("run")
		state.JUMPUP:
			animation_player.play("jumpup")
		state.JUMPDOWN:
			animation_player.play("jumpdown")
		state.
	
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta	
		
		# Handle Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left","right")
	if direction:
		velocity.x = move_toward(velocity.x,direction*speed,acceleration)
	else:
		velocity.x = move_toward(velocity.x,0,speed)

	move_and_slide()
