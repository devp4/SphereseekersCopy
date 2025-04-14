extends Node

class_name Player

# Player data
var playerName: String = ""
var current_level_time = 0

# Ex: {"1": 12.34} 
var best_times: Dictionary = {}

func get_player() -> Dictionary:
	return {
		"name": playerName,
		"current_level": convert_level_to_string(),
		"best_times": best_times
	}

func convert_level_to_string():
	var level = Global.level_to_play
	match level:
		Global.levels.TUTORIAL:
			return "tutorial"
		Global.levels.LEVEL1:
			return "level1"
		Global.levels.LEVEL2:
			return "level2"
		Global.levels.LEVEL3:
			return "level3"
		Global.levels.LEVEL4:
			return "level4"
		_:
			return "tutorial"

func convert_string_to_level(string_level):
	match string_level:
		"tutorial":
			return Global.levels.TUTORIAL
		"level1":
			return Global.levels.LEVEL1
		"level2":
			return Global.levels.LEVEL2
		"level3":
			return Global.levels.LEVEL3
		"level4":
			return Global.levels.LEVEL4
		_:
			return Global.levels.TUTORIAL
				
	
func set_level_best_time():
	var string_current_level = convert_level_to_string()
	if string_current_level not in best_times:
		best_times[string_current_level] = current_level_time
	elif current_level_time < best_times[string_current_level]:
		best_times[string_current_level] = current_level_time
	
func get_current_level_best_time():
	return best_times.get(convert_level_to_string(), null)

func clear_player():
	current_level_time = 0
	set_player({})

func set_player(data: Dictionary):
	playerName = data.get("name", "Player")
	var level = data.get("current_level", "tutorial")
	Global.level_to_play = convert_string_to_level(level)
	best_times = data.get("best_times", {})

func save_player():
	print("lveel to play ", Global.level_to_play)
	LocalStorage.save_player_data(playerName, get_player())

func delete_player(player_name):
	LocalStorage.delete_player(player_name)

func load_game(player_name):
	var data = LocalStorage.get_player_data(player_name)
	if data: set_player(data)
