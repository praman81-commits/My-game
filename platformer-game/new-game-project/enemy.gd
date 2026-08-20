extends CharacterBody2D

const SPEED = 100.0
const ATTACK_RANGE = 35.0
const ATTACK_COOLDOWN = 0.5
const HIT_FRAME = 3

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var player: CharacterBody2D = null
var can_attack: bool = true
var is_attacking: bool = false
var damage_dealt: bool = false

@onready var animator: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	find_player()


func find_player() -> void:

	player = get_tree().current_scene.find_child(
		"Player",
		true,
		false
	)

	if player == null:
		player = get_tree().current_scene.find_child(
			"player",
			true,
			false
		)


func _physics_process(delta: float) -> void:

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Find player
	if player == null:
		find_player()

	if player == null:
		velocity.x = 0
		move_and_slide()
		return


	# ------------------------------------------------
	# ATTACKING
	# ------------------------------------------------

	if is_attacking:

		velocity.x = 0

		check_sword_hit()

		move_and_slide()

		return


	# ------------------------------------------------
	# DISTANCE
	# ------------------------------------------------

	var distance_to_player = global_position.distance_to(
		player.global_position
	)

	var direction = player.global_position.x - global_position.x


	# Face player
	if direction != 0:
		animator.flip_h = direction < 0


	# ------------------------------------------------
	# ATTACK
	# ------------------------------------------------

	if distance_to_player <= ATTACK_RANGE:

		velocity.x = 0

		if can_attack:
			start_attack()


	# ------------------------------------------------
	# CHASE
	# ------------------------------------------------

	else:

		velocity.x = sign(direction) * SPEED

		# Play walking animation only if it exists
		if animator.sprite_frames.has_animation("walk"):
			animator.play("walk")

		elif animator.sprite_frames.has_animation("Walk"):
			animator.play("Walk")

		elif animator.sprite_frames.has_animation("run"):
			animator.play("run")

		elif animator.sprite_frames.has_animation("Run"):
			animator.play("Run")


	move_and_slide()


func start_attack() -> void:

	is_attacking = true
	can_attack = false
	damage_dealt = false

	velocity.x = 0

	print("ENEMY STARTED ATTACK")


	# Play attack animation
	if animator.sprite_frames.has_animation("attack"):
		animator.play("attack")

	elif animator.sprite_frames.has_animation("Attack"):
		animator.play("Attack")

	else:
		print("ERROR: No Attack animation found!")


func check_sword_hit() -> void:

	# Already damaged the player during this swing
	if damage_dealt:
		return


	# Make sure attack animation is playing
	if animator.animation != "attack" and animator.animation != "Attack":
		return


	# Wait until sword reaches hit frame
	if animator.frame < HIT_FRAME:
		return


	# Damage can only happen once per swing
	damage_dealt = true


	if player == null:
		return


	# Check distance at the EXACT moment of impact
	var distance_to_player = global_position.distance_to(
		player.global_position
	)

	print("SWORD HIT FRAME!")
	print("Distance: ", distance_to_player)


	if distance_to_player <= ATTACK_RANGE:

		if player.has_method("take_damage"):

			print("!!! PLAYER HIT !!!")

			player.take_damage(1)

	else:

		print("SWORD MISSED")


func _on_animated_sprite_2d_animation_finished() -> void:

	if animator.animation == "attack" or animator.animation == "Attack":

		print("ATTACK FINISHED")

		is_attacking = false

		await get_tree().create_timer(
			ATTACK_COOLDOWN
		).timeout

		can_attack = true


func _on_sword_hit_box_body_entered(body: Node2D) -> void:
	if not is_attacking:
		return

	if body == player:

		if not damage_dealt:

			damage_dealt = true

			print("SWORD HIT NINJA!")

			if player.has_method("take_damage"):
				player.take_damage(1)
