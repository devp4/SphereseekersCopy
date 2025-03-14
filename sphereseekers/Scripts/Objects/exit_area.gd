extends Area3D

# Called when a body enters the Area3D
func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Level Finished")
		get_tree().paused = true
		
		PlayerClass.set_level_best_time()
		PlayerClass.save_player()
