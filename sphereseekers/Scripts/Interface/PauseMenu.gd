extends Control

var background = ColorRect
var label = TextureRect
var resume = TextureButton
var restart = TextureButton
var options = TextureButton
var menu = TextureButton

func _ready():
	background = $background
	label = $title
	resume = $resume_button
	restart = $restart_button
	options = $options_button
	menu = $menu_button
	
	if not Global.is_mobile:
		var _targets = set_objects_for_desktop()
	else:
		# we assume that is a smartphone
		var _targets = set_objects_for_smartphone()
		
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

func set_objects_for_desktop():
	var screen_size = get_viewport_rect().size
	var w = screen_size.x
	var h = screen_size.y

	background.set_size(Vector2(w * 0.4, h * 0.8))
	background.set_position(Vector2(w * 0.3, h * 0.1))
	background.color = Color(0, 0, 0, 0.5)

	label.set_size(Vector2(250, 125))
	label.set_position(Vector2((w - label.size.x) / 2, h * 0.1))

	var buttons = [resume, restart, options, menu]
	var button_count = buttons.size()

	var button_width = 100
	var button_height = 50
	var spacing = 20
	var total_height = button_count * button_height + (button_count - 1) * spacing

	var start_y = 50 + background.position.y + (background.size.y - total_height) / 2

	for i in range(button_count):
		var btn = buttons[i]
		btn.set_size(Vector2(button_width, button_height))

		var x = background.position.x + (background.size.x - button_width) / 2
		var y = start_y + i * (button_height + spacing)

		btn.position = Vector2(x, y)

func set_objects_for_smartphone():
	var screen_size = get_viewport_rect().size
	var w = screen_size.x
	var h = screen_size.y

	# Background setup (smaller but centered)
	background.set_size(Vector2(w * 0.85, h * 0.75))
	background.set_position(Vector2(w * 0.075, h * 0.125))
	background.color = Color(0, 0, 0, 0.5)

	var bg_size = background.size
	var bg_pos = background.position

	# Label (Title)
	label.text = "Sphereseekers"
	label.set_size(Vector2(bg_size.x * 0.9, bg_size.y * 0.12))
	label.set_position(Vector2(
		bg_pos.x + (bg_size.x - label.size.x) / 2,
		bg_pos.y + bg_size.y * 0.05
	))
	label.add_theme_font_size_override("font_size", 42)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Buttons
	var buttons = [resume, restart, options, menu]
	var button_count = buttons.size()

	var button_width = bg_size.x * 0.7
	var button_height = bg_size.y * 0.12
	var spacing = bg_size.y * 0.02
	var total_height = button_count * button_height + (button_count - 1) * spacing

	var start_y = bg_pos.y + (bg_size.y - total_height) / 2

	for i in range(button_count):
		var btn = buttons[i]
		btn.set_size(Vector2(button_width, button_height))

		var x = bg_pos.x + (bg_size.x - button_width) / 2
		var y = start_y + i * (button_height + spacing)

		btn.position = Vector2(x, y)
