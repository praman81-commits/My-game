extends area2d

# --- CONFIGURATION ---
const SPEED = 80.0
const ATTACK_RANGE = 35.0 # Distance to stop and attack

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_attacking: bool = false

@onready var animator = $AnimatedSprite2D # Or $AnimationPlayer if using that
@onready var player = get_parent().get_node_or_null("player") # Make sure path matches scene tree


func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	if player and not is_attacking:
		# Calculate distance to player
		var distance_to_player = global_position.distance_to(player.global_position)
		var direction = (player.global_position.x - global_position.x)

		# Flip sprite to face player
		if direction != 0:
			animator.flip_h = direction < 0

		# Check if within attack range
		if distance_to_player <= ATTACK_RANGE:
			velocity.x = 0
			attack()
		else:
			# Walk toward player
			velocity.x = sign(direction) * SPEED
			animator.play("walk") # Replace "walk" with your enemy walk animation name
	else:
		velocity.x = 0

	move_and_slide()


func attack():
	is_attacking = true
	velocity.x = 0
	animator.play("attack") # Replace "attack" with your enemy attack animation name

	# Trigger damage call to player
	if player and player.has_method("take_damage"):
		player.take_damage(1)


# Connect this from your AnimatedSprite2D / AnimationPlayer signal: animation_finished
func _on_animated_sprite_2d_animation_finished():
	if animator.animation == "attack":
		is_attacking = false # Allow movement again after attack finishes
