extends CharacterBody2D

# --- CONFIGURATION ---
const SPEED = 250.0
const JUMP_VELOCITY = -350.0
const ACCELERATION = 20.0

# State Machine
enum State { IDLE, RUNNING, JUMP, ATTACK }
var anim_state = State.IDLE

var max_health: int = 3
var health: int = 3

# --- NODE REFERENCES ---
@onready var animator = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var health_bar = $ProgressBar2

# Get gravity setting from project defaults
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready():
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health


func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle Movement
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION)

	move_and_slide()
	update_animation(direction)


func update_animation(direction):
	if not is_on_floor():
		anim_state = State.JUMP
		animator.play("jump")
	elif direction != 0:
		animator.flip_h = direction < 0
		anim_state = State.RUNNING
		animator.play("run")
	else:
		anim_state = State.IDLE
		animator.play("idle")


# --- ANIMATION CALLBACK ---
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "jump_attack":
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction != 0:
			anim_state = State.RUNNING
		else:
			anim_state = State.IDLE


# --- DAMAGE & HEALTH SYSTEM ---
func take_damage(amount: int = 1) -> void:
	health -= amount
	print("Player took damage! Current health: ", health)
	velocity.y = -150

	if health_bar:
		health_bar.value = health

	if health <= 0:
		print("Player Died!")
		# Fixes the CollisionObject physics error by deferring scene reload
		get_tree().call_deferred("reload_current_scene")


# --- HEALING SYSTEM ---
func heal(amount: int = 1) -> void:
	health = min(health + amount, max_health)
	
	if health_bar:
		health_bar.value = health
		
	print("Player healed! Current health: ", health)
	
