extends Node2D

func _ready():
	var screen_size = get_viewport_rect().size
	var width = screen_size.x
	var height = screen_size.y
	
	var background_rect = ColorRect.new()
	background_rect.color = Color(173 / 255.0, 216 / 255.0, 230 / 255.0)
	background_rect.size = Vector2(width, height)
	background_rect.position = Vector2(0, 0)
	add_child(background_rect)
	
	# Main vertical container
	var main_vbox = VBoxContainer.new()
	main_vbox.size = Vector2(width * 0.8, height * 0.8)
	main_vbox.set_position(Vector2(
		(width - main_vbox.size.x) / 2,
		height * 0.1  # Top margin
	))
	main_vbox.add_theme_constant_override("separation", 20)
	add_child(main_vbox)
	
	# Title label
	var title_label = TextureRect.new()
	title_label.texture = load("res://Assets/Interface/ui_images/load_game_label.png")
	title_label.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	title_label.custom_minimum_size = Vector2(400, 100)
	main_vbox.add_child(title_label)
	
	# Scroll container
	var scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.2, 0.2, 0.5)
	bg_style.corner_radius_top_left = 16
	bg_style.corner_radius_top_right = 16
	bg_style.corner_radius_bottom_left = 16
	bg_style.corner_radius_bottom_right = 16
	bg_style.set_corner_detail(8)
	scroll_container.add_theme_stylebox_override("panel", bg_style)
	
	main_vbox.add_child(scroll_container)
	
	# Items container with padding
	var items_vbox = VBoxContainer.new()
	items_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	items_vbox.add_theme_constant_override("separation", 10)
	scroll_container.add_child(items_vbox)
	
	var top_spacer = Control.new()
	top_spacer.size_flags_vertical = Control.SIZE_EXPAND
	top_spacer.size_flags_stretch_ratio = 0.1
	items_vbox.add_child(top_spacer)
	
	var saves = LocalStorage.get_save_names()
	
	for save_name in saves:
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 50)
		items_vbox.add_child(hbox)
		
		var left_spacer = Control.new()
		left_spacer.size_flags_horizontal = Control.SIZE_EXPAND
		left_spacer.size_flags_stretch_ratio = 0.05
		hbox.add_child(left_spacer)
		
		# Save name label
		var name_label = Label.new()
		name_label.text = "%s" % save_name
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.add_theme_font_size_override("font_size", 24)
		hbox.add_child(name_label)
		
		# Button container
		var button_box = HBoxContainer.new()
		button_box.add_theme_constant_override("separation", 10)
		hbox.add_child(button_box)
		
		# Load button
		var load_button = TextureButton.new()
		load_button.texture_normal = load("res://Assets/buttons/load_button.png")
		load_button.ignore_texture_size = true
		load_button.stretch_mode = TextureButton.STRETCH_SCALE
		load_button.custom_minimum_size = Vector2(160, 40)
		button_box.add_child(load_button)
		load_button.pressed.connect(_on_load_pressed.bind(save_name))
		
		# Delete button
		var delete_button = TextureButton.new()
		delete_button.texture_normal = load("res://Assets/buttons/delete_button.png")
		delete_button.ignore_texture_size = true
		delete_button.stretch_mode = TextureButton.STRETCH_SCALE
		delete_button.custom_minimum_size = Vector2(160, 40)
		button_box.add_child(delete_button)
		delete_button.pressed.connect(_on_delete_confirm.bind(save_name))
		
		var right_spacer = Control.new()
		right_spacer.size_flags_horizontal = Control.SIZE_EXPAND
		right_spacer.size_flags_stretch_ratio = 0.05
		hbox.add_child(right_spacer)
		
	var main_menu_button = TextureButton.new()
	main_menu_button.texture_normal = load("res://Assets/buttons/menu_button.png")
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	main_menu_button.ignore_texture_size = true
	main_menu_button.stretch_mode = TextureButton.STRETCH_SCALE
	main_menu_button.custom_minimum_size = Vector2(200, 75)
	main_menu_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	main_vbox.add_child(main_menu_button)

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/Interface/MainMenu.tscn")

func _on_load_pressed(save_name):
	PlayerClass.clear_player()
	PlayerClass.load_game(save_name)
	Global.in_main_menu = false
	
	# New game is going to played, set the level to play to TUTORIAL
	Global.level_to_play = Global.levels.TUTORIAL
	
	# Make sure that Cannons will shoot
	Global.stop_all_projectiles = false
	get_tree().change_scene_to_file("res://Scenes/Levels/Tutorial.tscn")
	
func _on_delete_confirm(save_name):
	var popup = ConfirmationDialog.new()
	popup.dialog_text = "Are you sure you want to delete this save? \n This cannot be undone."
	popup.title = "Confirm Delete"
	popup.confirmed.connect(_on_delete_pressed.bind(save_name))
	popup.add_theme_icon_override("close", Texture2D.new())
	add_child(popup)
	
	# Get the label to center-align the text
	var label = popup.get_label()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Hide default buttons
	popup.get_ok_button().hide()
	popup.get_cancel_button().hide()
	
	# Create a VBoxContainer to structure the content vertically
	var container = VBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.custom_minimum_size = Vector2(300, 100)
	popup.add_child(container)
	
	# Add spacer to push buttons to the bottom
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.add_child(spacer)
	
	# Add button box at the bottom
	var button_box = HBoxContainer.new()
	button_box.alignment = BoxContainer.ALIGNMENT_CENTER
	button_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(button_box)
	
	# Add buttons with proper spacing
	var delete_btn = TextureButton.new()
	delete_btn.texture_normal = load("res://Assets/buttons/delete_button.png")
	delete_btn.ignore_texture_size = true
	delete_btn.stretch_mode = TextureButton.STRETCH_SCALE
	delete_btn.expand = true
	delete_btn.custom_minimum_size = Vector2(100, 25)
	delete_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	delete_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button_box.add_child(delete_btn)
	delete_btn.pressed.connect(_on_delete_pressed.bind(save_name))
	
	# Add some spacing between buttons
	var spacer_h = Control.new()
	spacer_h.custom_minimum_size = Vector2(20, 0)
	button_box.add_child(spacer_h)
	
	var exit_btn = TextureButton.new()
	exit_btn.texture_normal = load("res://Assets/buttons/cancel_button.png")
	exit_btn.ignore_texture_size = true
	exit_btn.stretch_mode = TextureButton.STRETCH_SCALE
	exit_btn.expand = true
	exit_btn.custom_minimum_size = Vector2(100, 25)
	exit_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	exit_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button_box.add_child(exit_btn)
	exit_btn.pressed.connect(popup.hide)
	
	# Add bottom margin
	var bottom_margin = Control.new()
	bottom_margin.custom_minimum_size = Vector2(0, 10)
	container.add_child(bottom_margin)
	
	popup.popup_centered()
	
func _on_delete_pressed(save_name):
	var saves = LocalStorage.get_save_names()
	var new_saves = []
	
	for save in saves:
		if save != save_name:
			new_saves.append(save)
	
	LocalStorage.set_save_names(new_saves)
	PlayerClass.delete_player(save_name)
	get_tree().change_scene_to_file("res://Scenes/Interface/LoadGameMenu.tscn")
	 
func _set_mobile_objects():
	var screen_size = get_viewport_rect().size
	var width = screen_size.x
	var height = screen_size.y
	
	var background_rect = ColorRect.new()
	background_rect.color = Color(173 / 255.0, 216 / 255.0, 230 / 255.0)
	background_rect.size = Vector2(width, height)
	background_rect.position = Vector2(0, 0)
	add_child(background_rect)
	
	# Main vertical container
	var main_vbox = VBoxContainer.new()
	main_vbox.size = Vector2(width * 0.8, height * 0.8)
	main_vbox.set_position(Vector2(
		(width - main_vbox.size.x) / 2,
		height * 0.1  # Top margin
	))
	main_vbox.add_theme_constant_override("separation", 20)
	add_child(main_vbox)
	
	# Title label
	var title_label = TextureRect.new()
	title_label.texture = load("res://Assets/Interface/ui_images/load_game_label.png")
	title_label.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	title_label.custom_minimum_size = Vector2(400, 100)
	main_vbox.add_child(title_label)
	
	# Scroll container
	var scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.2, 0.2, 0.5)
	bg_style.corner_radius_top_left = 16
	bg_style.corner_radius_top_right = 16
	bg_style.corner_radius_bottom_left = 16
	bg_style.corner_radius_bottom_right = 16
	bg_style.set_corner_detail(8)
	scroll_container.add_theme_stylebox_override("panel", bg_style)
	
	main_vbox.add_child(scroll_container)
	
	# Items container with padding
	var items_vbox = VBoxContainer.new()
	items_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	items_vbox.add_theme_constant_override("separation", 10)
	scroll_container.add_child(items_vbox)
	
	var top_spacer = Control.new()
	top_spacer.size_flags_vertical = Control.SIZE_EXPAND
	top_spacer.size_flags_stretch_ratio = 0.1
	items_vbox.add_child(top_spacer)
	
	var saves = LocalStorage.get_save_names()
	
	for save_name in saves:
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 50)
		items_vbox.add_child(hbox)
		
		var left_spacer = Control.new()
		left_spacer.size_flags_horizontal = Control.SIZE_EXPAND
		left_spacer.size_flags_stretch_ratio = 0.1
		hbox.add_child(left_spacer)
		
		# Save name label
		var name_label = Label.new()
		name_label.text = "%s" % save_name
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(name_label)
		
		# Button container
		var button_box = HBoxContainer.new()
		button_box.add_theme_constant_override("separation", 10)
		hbox.add_child(button_box)
		
		# Load button
		var load_button = TextureButton.new()
		load_button.texture_normal = load("res://Assets/buttons/load_button.png")
		load_button.ignore_texture_size = true
		load_button.stretch_mode = TextureButton.STRETCH_SCALE
		load_button.custom_minimum_size = Vector2(100, 25)
		button_box.add_child(load_button)
		load_button.pressed.connect(_on_load_pressed.bind(save_name))
		
		# Delete button
		var delete_button = TextureButton.new()
		delete_button.texture_normal = load("res://Assets/buttons/delete_button.png")
		delete_button.ignore_texture_size = true
		delete_button.stretch_mode = TextureButton.STRETCH_SCALE
		delete_button.custom_minimum_size = Vector2(100, 25)
		button_box.add_child(delete_button)
		delete_button.pressed.connect(_on_delete_confirm.bind(save_name))
		
		var right_spacer = Control.new()
		right_spacer.size_flags_horizontal = Control.SIZE_EXPAND
		right_spacer.size_flags_stretch_ratio = 0.1
		hbox.add_child(right_spacer)
		
	var main_menu_button = TextureButton.new()
	main_menu_button.texture_normal = load("res://Assets/buttons/menu_button.png")
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	main_menu_button.ignore_texture_size = true
	main_menu_button.stretch_mode = TextureButton.STRETCH_SCALE
	main_menu_button.custom_minimum_size = Vector2(100, 50)
	main_menu_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	main_vbox.add_child(main_menu_button)	
	
