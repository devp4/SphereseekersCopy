extends Node


func get_local_storage(item):
	var data = JavaScriptBridge.eval("localStorage.getItem()")

func set_local_storage(key, item):
	pass
