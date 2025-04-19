extends Node


func get_local_storage(key):
	return JavaScriptBridge.eval("localStorage.getItem('%s')" % key)

func set_local_storage(key, item):
	var _key_string = "%s" % key
	var _item_string = JSON.stringify(item)
	JavaScriptBridge.eval("localStorage.setItem('%s', '%s')" % [key, item])

func get_save_names():
	var data = JavaScriptBridge.eval("localStorage.getItem('saves')")
	if data == null: return []
	else: return JSON.parse_string(data)

func set_save_names(save_names):
	var save_names_string = JSON.stringify(save_names)
	var complete_string = "localStorage.setItem('saves', '%s')" % save_names_string
	JavaScriptBridge.eval(complete_string)

func delete_player(player_name):
	var complete_string = "localStorage.removeItem('%s')" % player_name
	JavaScriptBridge.eval(complete_string)

func set_recent_save(name):
	var data = JavaScriptBridge.eval("localStorage.setItem('recent_save', '%s')" % name)
	if data == null: return null
	else: return null

func delete_recent_save():
	var complete_string = "localStorage.removeItem('recent_save')"
	JavaScriptBridge.eval(complete_string)

func get_recent_save():
	var data = JavaScriptBridge.eval("localStorage.getItem('recent_save')")
	if data == null: return null
	else: return data

func save_player_data(player_name, player_data):
	# convert int keys to string
	if "best_times" in player_data and player_data["best_times"] is Dictionary:
		var new_best_times = {}
		for key in player_data["best_times"].keys():
			new_best_times[str(key)] = player_data["best_times"][key]
		
		player_data["best_times"] = new_best_times
		
	var player_string = JSON.stringify(player_data)
	
	player_string = player_string.replace("'", "\\'")
	var js_string = "localStorage.setItem('%s', '%s')" % [player_name, player_data]
	var _data = JavaScriptBridge.eval(js_string)

func get_player_data(player_name):
	var js_string = "localStorage.getItem('%s')" % player_name
	var data = JavaScriptBridge.eval(js_string)
	if data == null: return []
	else: return JSON.parse_string(data)

func print_message(message):
	# for testing
	var js_string = "console.log('%s')" % message
	var _data = JavaScriptBridge.eval(js_string)
