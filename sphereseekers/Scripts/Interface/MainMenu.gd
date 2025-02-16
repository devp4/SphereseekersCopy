extends Control

const MOBILE_KEYWORDS = ["Android", "iPhone", "iPad", "iPod", "Windows Phone", "Mobile"]

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	
	var background = $background
	var title = $title
	var continue_button = $continue_button
	var new_game_button = $new_game_button
	var load_game_button = $load_game_button
	var options_button = $options_button
	var exit_button = $exit_button
	
	# You can perform any setup for your menu here if needed
	Global.is_mobile = is_running_on_mobile_browser()
	
	if Global.is_mobile:
		get_window().size = Vector2(400, 600)
		set_objects_for_mobile(background, title, continue_button, new_game_button, load_game_button, options_button, exit_button)
	else:
		set_objects_for_desktop(background, title, continue_button, new_game_button, load_game_button, options_button, exit_button)

func _on_Continue_pressed() -> void:
	pass

# Signal handler for the "New Game" button
func _on_new_game_pressed() -> void:
	# Change the scene to Level1
	Global.is_paused = false
	get_tree().change_scene_to_file("res://Scenes/Levels/Tutorial.tscn")

func _on_load_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Interface/SetNameMenu.tscn")
	
func _on_options_pressed() -> void:
	pass

func _on_exit_pressed() -> void:
	pass
	
func is_running_on_mobile_browser() -> bool:
	if not OS.has_feature("web"):
		return false
	var user_agent = JavaScriptBridge.eval("navigator.userAgent;")
	for keyword in MOBILE_KEYWORDS:
		if keyword in user_agent:
			return true
	return false
	

func set_objects_for_desktop(background, title, continue_button, new_game_button, load_game_button, options_button, exit_button):
	var screen_size = get_viewport_rect().size
	var width = screen_size.x
	var height = screen_size.y

	# Background (ColorRect)
	background.set_size(Vector2(width * 0.4, height * 0.8))
	background.set_position(Vector2(width * 0.3, height * 0.1))
	background.color = Color(77 / 255.0, 77 / 255.0, 77 / 255.0)

	# Background position
	var bg_size = background.size
	var bg_position = background.position

	# title
	title.text = "Sphereseekers"
	title.set_size(Vector2(bg_size.x * 0.75, bg_size.y * 0.15))
	title.set_position(Vector2(
		bg_position.x + (bg_size.x - title.size.x) / 2,
		bg_position.y + bg_size.y * 0.05
	))
	title.add_theme_font_size_override("font_size", 48)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Continue
	continue_button.text = "Continue"
	continue_button.set_size(Vector2(bg_size.x * 0.5, bg_size.y * 0.1))

	continue_button.set_position(Vector2(
		bg_position.x + (bg_size.x - continue_button.size.x) / 2,
		bg_position.y + bg_size.y * 0.30
	))
	
	# New Game
	new_game_button.text = "New Game"
	new_game_button.set_size(Vector2(bg_size.x * 0.5, bg_size.y * 0.1))

	new_game_button.set_position(Vector2(
		bg_position.x + (bg_size.x - new_game_button.size.x) / 2,
		bg_position.y + bg_size.y * 0.45
	))
	
	# Load Game
	load_game_button.text = "Load Game"
	load_game_button.set_size(Vector2(bg_size.x * 0.5, bg_size.y * 0.1))

	load_game_button.set_position(Vector2(
		bg_position.x + (bg_size.x - load_game_button.size.x) / 2,
		bg_position.y + bg_size.y * 0.60
	))
	
	# Options
	options_button.text = "Options"
	options_button.set_size(Vector2(bg_size.x * 0.5, bg_size.y * 0.1))

	options_button.set_position(Vector2(
		bg_position.x + (bg_size.x - options_button.size.x) / 2,
		bg_position.y + bg_size.y * 0.75
	))
	
	# Exit
	exit_button.text = "Main Menu"
	exit_button.set_size(Vector2(bg_size.x * 0.5, bg_size.y * 0.1))

	exit_button.set_position(Vector2(
		bg_position.x + (bg_size.x - exit_button.size.x) / 2,
		bg_position.y + bg_size.y * 0.9
	))
	
func set_objects_for_mobile(background, title, continue_button, new_game_button, load_game_button, options_button, exit_button):
	var screen_size = get_viewport_rect().size
	var width = screen_size.x
	var height = screen_size.y

	# Background (ColorRect)
	background.set_size(Vector2(width * 0.85, height * 0.6))  # Wider for readability
	background.set_position(Vector2(width * 0.075, height * 0.2))  # Centered
	background.color = Color(0, 0, 0, 0.5)

	# Background position
	var bg_size = background.size
	var bg_position = background.position

	# Label (Title)
	title.text = "Sphereseekers"
	title.set_size(Vector2(bg_size.x * 0.9, bg_size.y * 0.12))
	title.set_position(Vector2(
		bg_position.x + (bg_size.x - title.size.x) / 2,
		bg_position.y + bg_size.y * 0.05
	))
	title.add_theme_font_size_override("font_size", 42)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Button size
	var button_width = bg_size.x * 0.7
	var button_height = bg_size.y * 0.12
	var button_spacing = bg_size.y * 0.02

	# Continue
	continue_button.text = "Continue"
	continue_button.set_size(Vector2(button_width, button_height))
	continue_button.set_position(Vector2(
		bg_position.x + (bg_size.x - continue_button.size.x) / 2,
		bg_position.y + bg_size.y * 0.25
	))
	
	# New Game
	new_game_button.text = "New Game"
	new_game_button.set_size(Vector2(button_width, button_height))
	new_game_button.set_position(Vector2(
		bg_position.x + (bg_size.x - new_game_button.size.x) / 2,
		continue_button.position.y + button_height + button_spacing
	))
	
	# Load Game
	load_game_button.text = "Load Game"
	load_game_button.set_size(Vector2(button_width, button_height))
	load_game_button.set_position(Vector2(
		bg_position.x + (bg_size.x - load_game_button.size.x) / 2,
		new_game_button.position.y + button_height + button_spacing
	))
	
	# Options
	options_button.text = "Options"
	options_button.set_size(Vector2(button_width, button_height))
	options_button.set_position(Vector2(
		bg_position.x + (bg_size.x - options_button.size.x) / 2,
		load_game_button.position.y + button_height + button_spacing
	))
	
	# Exit
	exit_button.text = "Exit"
	exit_button.set_size(Vector2(button_width, button_height))
	exit_button.set_position(Vector2(
		bg_position.x + (bg_size.x - exit_button.size.x) / 2,
		options_button.position.y + button_height + button_spacing
	))
