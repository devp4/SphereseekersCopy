extends Control

func _ready():
	var background = $background
	var label = $title
	var resume = $resume_button
	var restart = $restart_button
	var options = $options_button
	var menu = $menu_button
	
	if not Global.is_mobile:
		set_objects_for_desktop(background, label, resume, restart, options, menu)
	else:
		# we assume that is a smartphone
		set_objects_for_smartphone(background, label, resume, restart, options, menu)
	
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		get_parent().unpause_game()
		get_viewport().set_input_as_handled()

func _on_resume_button_pressed():
	get_parent().unpause_game()

func _on_restart_button_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.is_paused = false
	Global.stop_all_projectiles = true
	get_tree().paused = false
	await get_tree().process_frame
	Global.stop_all_projectiles = false
	get_tree().reload_current_scene()
	PlayerClass.current_level_time = 0

func _on_options_button_pressed():
	print("Options menu coming soon!")

func _on_main_menu_button_pressed():
	Global.in_main_menu = true
	Global.stop_all_projectiles = true
	Global.controls_shown = false
	Global.is_paused = false
	
	for sphere in get_tree().get_nodes_in_group("enemy_balls"):
		if is_instance_valid(sphere):
			sphere.queue_free()
	
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Interface/MainMenu.tscn")

func set_objects_for_desktop(background, label, resume, restart, options, menu):
	var screen_size = get_viewport_rect().size
	var width = screen_size.x
	var height = screen_size.y

	# Background (ColorRect)
	background.set_size(Vector2(width * 0.4, height * 0.8))
	background.set_position(Vector2(width * 0.3, height * 0.1))
	background.color = Color(0, 0, 0, 0.5)

	# Background position
	var bg_size = background.size
	var bg_position = background.position

	# Label (Title)
	label.text = "Sphereseekers"
	label.set_size(Vector2(bg_size.x * 0.75, bg_size.y * 0.15))
	label.set_position(Vector2(
		bg_position.x + (bg_size.x - label.size.x) / 2,
		bg_position.y + bg_size.y * 0.05
	))
	label.add_theme_font_size_override("font_size", 48)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Resume
	resume.text = "Resume"
	resume.set_size(Vector2(bg_size.x * 0.5, bg_size.y * 0.1))

	resume.set_position(Vector2(
		bg_position.x + (bg_size.x - resume.size.x) / 2,
		bg_position.y + bg_size.y * 0.30
	))
	
	# Restart
	restart.text = "Restart"
	restart.set_size(Vector2(bg_size.x * 0.5, bg_size.y * 0.1))

	restart.set_position(Vector2(
		bg_position.x + (bg_size.x - restart.size.x) / 2,
		bg_position.y + bg_size.y * 0.45
	))
	
	# Options
	options.text = "Options"
	options.set_size(Vector2(bg_size.x * 0.5, bg_size.y * 0.1))

	options.set_position(Vector2(
		bg_position.x + (bg_size.x - options.size.x) / 2,
		bg_position.y + bg_size.y * 0.60
	))
	
	# Menu
	menu.text = "Main Menu"
	menu.set_size(Vector2(bg_size.x * 0.5, bg_size.y * 0.1))

	menu.set_position(Vector2(
		bg_position.x + (bg_size.x - menu.size.x) / 2,
		bg_position.y + bg_size.y * 0.75
	))
	
func set_objects_for_smartphone(background, label, resume, restart, options, menu):
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
	label.text = "Sphereseekers"
	label.set_size(Vector2(bg_size.x * 0.9, bg_size.y * 0.12))
	label.set_position(Vector2(
		bg_position.x + (bg_size.x - label.size.x) / 2,
		bg_position.y + bg_size.y * 0.05
	))
	label.add_theme_font_size_override("font_size", 42)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Button size
	var button_width = bg_size.x * 0.7
	var button_height = bg_size.y * 0.12
	var button_spacing = bg_size.y * 0.02

	# Resume
	resume.text = "Resume"
	resume.set_size(Vector2(button_width, button_height))
	resume.set_position(Vector2(
		bg_position.x + (bg_size.x - resume.size.x) / 2,
		bg_position.y + bg_size.y * 0.25
	))
	
	# Restart
	restart.text = "Restart"
	restart.set_size(Vector2(button_width, button_height))
	restart.set_position(Vector2(
		bg_position.x + (bg_size.x - restart.size.x) / 2,
		resume.position.y + button_height + button_spacing
	))
	
	# Options
	options.text = "Options"
	options.set_size(Vector2(button_width, button_height))
	options.set_position(Vector2(
		bg_position.x + (bg_size.x - options.size.x) / 2,
		restart.position.y + button_height + button_spacing
	))
	
	# Menu
	menu.text = "Main Menu"
	menu.set_size(Vector2(button_width, button_height))
	menu.set_position(Vector2(
		bg_position.x + (bg_size.x - menu.size.x) / 2,
		options.position.y + button_height + button_spacing
	))
