extends Area3D

@export var restart_position: Vector3

# Called when a body enters the Area3D
func _on_body_entered(body):
	if body.is_in_group("player"):
		Global.is_falling = true
		body.global_transform.origin = restart_position
