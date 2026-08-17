extends CharacterBody2D

# --- CONFIGURATION ---
const SPEED = 250.0
const JUMP_VELOCITY = -350.0
const ACCELERATION = 20.0

# State Machine (Idle, Run, Jump, Attack)
enum State { IDLE, RUNNING, JUMP, ATTACK }
var anim_state = State.IDLE

var max_health: int = 3
var health: int = 3

# --- NODE REFERENCES ---
@onready var animator = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var health_bar = $"../CanvasLayer/ProgressBar2"

# Get gravity setting
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# 1. Apply Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Get Input Direction (-1, 0, or 1)
	var direction = Input.get_axis("ui_left", "ui_right")

	# 3. Handle Attack Input
	if Input.is_action_just_pressed("jumpattack") and anim_state != State.ATTACK:
		anim_state = State.ATTACK

	# 4. Movement Logic (Update non-attack states)
	if anim_state != State.ATTACK:
		if is_on_floor():
			if Input.is_action_just_pressed("ui_accept"):
				velocity.y = JUMP_VELOCITY
				anim_state = State.JUMP
			elif direction != 0:
				anim_state = State.RUNNING
			else:
				anim_state = State.IDLE
		else:
			anim_state = State.JUMP

	# 5. Apply Horizontal Velocity (Allowed during ALL states including ATTACK)
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 6. Move Node
	move_and_slide()

	# 7. Update Sprite Visuals & Animations
	update_animation(direction)


func update_animation(direction):
	# Flip sprite direction based on movement input
	if direction > 0:
		animator.flip_h = false
	elif direction < 0:
		animator.flip_h = true

	# Play matching track in AnimationPlayer
	match anim_state:
		State.IDLE:
			animation_player.play("idle")
		State.RUNNING:
			animation_player.play("run")
		State.JUMP:
			animation_player.play("jump")
		State.ATTACK:
			animation_player.play("jump attack")


# Signal: Connected from AnimationPlayer -> animation_finished
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "jump attack":
		# Reset state based on whether player is moving or standing still
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction != 0:
			anim_state = State.RUNNING
		else:
			anim_state = State.IDLE


func take_damage(amount: int = 1) -> void:
	health -= amount
	print("Player took damage! Current health: ", health)
	
	velocity.y = -150
	
	# Update the progress bar UI
	if health_bar:
		health_bar.value = health
		
	if health <= 0:
		print("Player Died!")
		get_tree().reload_current_scene()            
