extends Node

class_name Player

# Player data
var playerName: String = ""
var current_level: int = 1
var current_level_time = 0

# Ex: {"level1": 12.34} 
var best_times: Dictionary = {}

func get_player() -> Dictionary:
	return {
		"name": playerName,
		"current_level": current_level,
		"best_times": best_times
	}

func load_player(data: Dictionary):
	playerName = data.get("name", "Player")
	current_level = data.get("current_level", 1)
	best_times = data.get("best_times", {})

func save_game():
	LocalStorage.save_player_data(playerName, get_player())

func load_game(player_name):
	var js_string = "localStorage.getItem('%s')" % player_name
	var data = LocalStorage.get_player_data(player_name)
	if data: load_player(data)

func update_best_time(level: int, time: float):
	if not best_times.has(str(level)) or time < best_times[str(level)]:
		best_times[str(level)] = time
		save_game()
