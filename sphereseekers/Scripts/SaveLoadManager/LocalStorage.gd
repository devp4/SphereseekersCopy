extends Node


func get_local_storage(key):
	return JavaScriptBridge.eval("localStorage.getItem(%s)" % key)

func set_local_storage(key, item):
	var key_string = "%s" % key
	var item_string = JSON.stringify(item)
	JavaScriptBridge.eval("localStorage.setItem(%s, %s)" % [key, item])

func get_save_names():
	var data = JavaScriptBridge.eval("localStorage.getItem('saves')")
	if data == null: return []
	else: return JSON.parse_string(data)

func set_save_names(save_names):
	var save_names_string = JSON.stringify(save_names)
	var complete_string = "localStorage.setItem('saves', '%s')" % save_names_string
	JavaScriptBridge.eval(complete_string)
