extends Area2D


@export var flip_time = 1
@export var direction: int = -1

func _ready():
	pass

func _process(delta):
	translate(Vector2.RIGHT * direction)
	$AnimatedSprite2D.flip_h = direction < 0

func _on_timer_timeout() -> void:
	direction *= -1
	$Timer.wait_time = flip_time

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		print("Player hit!")
		direction *= -1 # Turns the enemy around immediately!
		if body.has_method("take_damage"):
			body.take_damage(1)
