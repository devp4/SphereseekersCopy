extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	text = "Best: --.--"
	var best_time = PlayerClass.get_current_level_best_time()
	if best_time: text = "Best: " + str(best_time).pad_decimals(2) + " sec"
