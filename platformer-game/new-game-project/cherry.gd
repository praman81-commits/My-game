extends Area2D



func _on_body_entered(body):
	# Check if the object touching the cherry is the player
	if body.has_method("heal"):
		body.heal(1)     # Add 1 health point
		queue_free()    # Delete the cherry after collection
