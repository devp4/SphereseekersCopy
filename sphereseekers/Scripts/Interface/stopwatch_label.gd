extends Label

func _ready():
	text = "00:00"
	
func _process(delta):
	if !Global.is_paused:
		PlayerClass.current_level_time += delta
		text = str(PlayerClass.current_level_time).pad_decimals(2)
