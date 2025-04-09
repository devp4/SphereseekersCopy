extends Control

# UI elements
var background: ColorRect
var label: TextureRect
var resume: TextureButton
var restart: TextureButton
var options: TextureButton
var menu: TextureButton

# Constants
const BUTTON_WIDTH_RATIO = 0.3  # Buttons will be 80% of background width
const BUTTON_WIDTH_RATIO_MOBILE = 0.5
const BUTTON_HEIGHT_RATIO = 0.15  # Each button takes 15% of background height
const SPACING_RATIO = 0.05  # 5% of background height as spacing between buttons

func _ready():
	# Initialize references
	_init_ui_references()
	
	# Setup layout based on device
	if Global.is_mobile:
		_setup_layout()
	else:
		_setup_layout()
	
	process_mode = Node.PROCESS_MODE_ALWAYS

func _init_ui_references():
	background = $background
	label = $title
	resume = $resume_button
	restart = $restart_button
	options = $options_button
	menu = $menu_button

func _setup_layout():
	var screen_size = get_viewport_rect().size
	var w = screen_size.x
	var h = screen_size.y

	# Background (responsive for both desktop and mobile)
	background.set_size(Vector2(w * 0.8, h * 0.8))
	background.set_position(Vector2(w * 0.1, h * 0.1))
	background.color = Color(0, 0, 0, 0.5)

	# Arrange buttons to fill background
	_arrange_buttons()

func _arrange_buttons():
	var buttons = [resume, restart, options, menu]
	var bg_size = background.size
	var bg_pos = background.position

	var button_width
	
	if Global.is_mobile:
		button_width = bg_size.x * BUTTON_WIDTH_RATIO_MOBILE
	else:
		button_width = bg_size.x * BUTTON_WIDTH_RATIO
		
	var button_height = bg_size.y * BUTTON_HEIGHT_RATIO
	var spacing = bg_size.y * SPACING_RATIO

	var button_count = buttons.size()
	var total_height = button_count * button_height + (button_count - 1) * spacing
	var start_y = bg_pos.y + (bg_size.y - total_height) / 2

	for i in range(button_count):
		var btn = buttons[i]
		btn.set_size(Vector2(button_width, button_height))

		var x = bg_pos.x + (bg_size.x - button_width) / 2
		var y = start_y + i * (button_height + spacing)

		btn.position = Vector2(x, y)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		get_parent().unpause_game()
		get_viewport().set_input_as_handled()

# Button Actions
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
