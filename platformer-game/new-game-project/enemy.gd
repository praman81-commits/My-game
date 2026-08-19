extends CharacterBody2D

# --- CONFIGURATION ---
const SPEED = 100.0
const ATTACK_RANGE = 40.0       # Stopping distance from player
const ATTACK_COOLDOWN = 1.5     # Cooldown time (in seconds) between attacks

var custom_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_attacking: bool = false
var can_attack: bool = true

@onready var animator = $AnimatedSprite2D
var player: CharacterBody2D = null


func _ready():
	find_player()


# Finds the player node whether named 'player' or 'Player'
func find_player():
	if get_parent():
		player = get_parent().get_node_or_null("player")
		if not player:
			player = get_parent().get_node_or_null("Player")


func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += custom_gravity * delta

	# Try finding player again if not found yet
	if not player:
		find_player()

	if player and not is_attacking:
		var distance_to_player = global_position.distance_to(player.global_position)
		var direction_x = player.global_position.x - global_position.x

		# Turn sprite to face player
		if direction_x != 0:
			animator.flip_h = direction_x < 0

		# Check attack range
		if distance_to_player <= ATTACK_RANGE:
			velocity.x = 0
			if can_attack:
				start_attack()
			else:
				play_anim_safe(["idle", "Idle", "default"])
		else:
			# Walk toward player
			velocity.x = sign(direction_x) * SPEED
			play_anim_safe(["walk", "Walk", "run", "Run"])
	else:
		velocity.x = 0

	move_and_slide()


func start_attack():
	is_attacking = true
	can_attack = false
	velocity.x = 0
	play_anim_safe(["attack", "Attack"])


# Safe animation helper (prevents crashing if animation names differ)
func play_anim_safe(anim_list: Array):
	if not animator or not animator.sprite_frames:
		return
	for a in anim_list:
		if animator.sprite_frames.has_animation(a):
			animator.play(a)
			return


# --- CONNECT THIS SIGNAL IN GODOT EDITOR ---
# Node Tab -> AnimatedSprite2D -> animation_finished() -> Connect to enemy.gd
func _on_animated_sprite_2d_animation_finished():
	if animator.animation in ["attack", "Attack"]:
		# Deal damage to player when attack animation ends
		if player and global_position.distance_to(player.global_position) <= ATTACK_RANGE + 15:
			if player.has_method("take_damage"):
				player.take_damage(1)
		
		is_attacking = false
		
		# Cooldown before enemy can attack again
		await get_tree().create_timer(ATTACK_COOLDOWN).timeout
		can_attack = true
