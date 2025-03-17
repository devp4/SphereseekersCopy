extends Node

class_name Player

# Player data
var playerName: String = ""
var current_level: int = 1
var current_level_time = 0

# Ex: {"1": 12.34} 
var best_times: Dictionary = {}

func get_player() -> Dictionary:
	return {
		"name": playerName,
		"current_level": current_level,
		"best_times": best_times
	}

func set_current_level(level):
	current_level = level

func get_current_level():
	return current_level
	
func set_level_best_time():
	var string_current_level = str(current_level)
	if string_current_level not in best_times:
		best_times[string_current_level] = current_level_time
	elif current_level_time < best_times[string_current_level]:
		best_times[string_current_level] = current_level_time
	
func get_current_level_best_time():
	return best_times.get(str(current_level), null)

func set_player(data: Dictionary):
	playerName = data.get("name", "Player")
	current_level = data.get("current_level", 1)
	best_times = data.get("best_times", {})

func save_player():
	LocalStorage.save_player_data(playerName, get_player())

func load_game(player_name):
	var data = LocalStorage.get_player_data(player_name)
	if data: set_player(data)
