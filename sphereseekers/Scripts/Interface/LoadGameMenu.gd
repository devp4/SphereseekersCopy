extends Node2D

var button_size: float
var font_size: float
var screen_size: Vector2

func _ready():
	
	screen_size = get_viewport_rect().size
	var width = screen_size.x
	var _height = screen_size.y
	
	if Global.is_mobile:
		button_size = width * 0.1
		font_size = 70
		_set_mobile_objects()
	else:
		button_size = width * 0.05
		font_size = 50
		_set_desktop_objects()

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/Interface/MainMenu.tscn")

func _on_load_pressed(save_name):
	PlayerClass.clear_player()
	PlayerClass.load_game(save_name)
	Global.in_main_menu = false
	LocalStorage.set_recent_save(PlayerClass.playerName)
	
	# Make sure that Cannons will shoot
	Global.stop_all_projectiles = false
	MusicPlayer.find_child("AudioStreamPlayer2D").stop()
	get_tree().change_scene_to_file("res://Scenes/Interface/loading_screen.tscn")
	
func _on_delete_confirm(save_name):
	if Global.is_mobile:
		confirm_remove_on_mobile(_on_delete_pressed.bind(save_name))
	else:
		confirm_remove_on_desktop(_on_delete_pressed.bind(save_name))
	
func _on_delete_pressed(save_name):
	var saves = LocalStorage.get_save_names()
	var new_saves = []
	
	for save in saves:
		if save != save_name:
			new_saves.append(save)
	
	LocalStorage.set_save_names(new_saves)
	PlayerClass.delete_player(save_name)
	var recent_save = LocalStorage.get_recent_save()
	if recent_save == save_name:
		LocalStorage.delete_recent_save()
	get_tree().change_scene_to_file("res://Scenes/Interface/LoadGameMenu.tscn")

func _set_desktop_objects():
	
	var width = screen_size.x
	var height = screen_size.y
	
	var background_rect = ColorRect.new()
	background_rect.color = Color(173 / 255.0, 216 / 255.0, 230 / 255.0)
	background_rect.size = Vector2(width, height)
	background_rect.position = Vector2(0, 0)
	add_child(background_rect)
	
	# Main vertical container
	var main_vbox = VBoxContainer.new()
	main_vbox.size = Vector2(width * 0.8, height * 0.9)
	main_vbox.set_position(Vector2(
		(width - main_vbox.size.x) / 2,
		height * 0.05  # Top margin
	))
	main_vbox.add_theme_constant_override("separation", 20)
	add_child(main_vbox)
	
	# Title label
	var title_label = TextureRect.new()
	title_label.texture = load("res://Assets/Interface/ui_images/label_load_game_2x1.png")
	title_label.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	title_label.custom_minimum_size = Vector2(height * 0.4, height * 0.2)
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
		
		# Left spacer
		create_left_spacer(hbox)
		
		# Save name label
		create_label(hbox, save_name, font_size)
		
		# Button container
		var button_box = HBoxContainer.new()
		button_box.add_theme_constant_override("separation", 10)
		hbox.add_child(button_box)
		
		# Load button
		var load_texture = "res://Assets/buttons/load_button.png"
		create_action_button(load_texture, button_size, button_box, _on_load_pressed.bind(save_name))
		
		# Load button
		var delete_texture = "res://Assets/buttons/delete_button.png"
		create_action_button(delete_texture, button_size, button_box, _on_delete_confirm.bind(save_name))
		
		# Right spacer
		create_right_spacer(hbox)
		
	var main_menu_button = TextureButton.new()
	main_menu_button.texture_normal = load("res://Assets/buttons/menu_btn_2x1.png")
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	main_menu_button.ignore_texture_size = true
	main_menu_button.stretch_mode = TextureButton.STRETCH_SCALE
	main_menu_button.custom_minimum_size = Vector2(height * 0.2, height * 0.1)
	main_menu_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	main_vbox.add_child(main_menu_button)
	 
func _set_mobile_objects():
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
	title_label.texture = load("res://Assets/Interface/ui_images/label_load_game_2x1.png")
	title_label.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	title_label.custom_minimum_size = Vector2(width *  0.6, width * 0.3)
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
	
	var saves = LocalStorage.get_save_names()
	
	for save_name in saves:
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 50)
		items_vbox.add_child(hbox)
		
		create_left_spacer(hbox)
		
		# Save name label
		create_label(hbox, save_name, font_size)
		
		# Button container
		var button_box = HBoxContainer.new()
		button_box.add_theme_constant_override("separation", 10)
		hbox.add_child(button_box)
		
		# Load button
		var load_texture = "res://Assets/buttons/load_button.png"
		create_action_button(load_texture, button_size, button_box, _on_load_pressed.bind(save_name))
		
		# Delete button
		var delete_texture = "res://Assets/buttons/delete_button.png"
		create_action_button(delete_texture, button_size, button_box, _on_delete_confirm.bind(save_name))
		
		create_right_spacer(hbox)
		
	var main_menu_button = TextureButton.new()
	main_menu_button.texture_normal = load("res://Assets/buttons/menu_btn_2x1.png")
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	main_menu_button.ignore_texture_size = true
	main_menu_button.stretch_mode = TextureButton.STRETCH_SCALE
	main_menu_button.custom_minimum_size = Vector2(width * 0.5, height * 0.08)
	main_menu_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	main_vbox.add_child(main_menu_button)	
	
func create_left_spacer(hbox: HBoxContainer):
	var left_spacer = Control.new()
	left_spacer.size_flags_horizontal = Control.SIZE_EXPAND
	left_spacer.size_flags_stretch_ratio = 0.05
	hbox.add_child(left_spacer)
	
func create_right_spacer(hbox: HBoxContainer):
	var right_spacer = Control.new()
	right_spacer.size_flags_horizontal = Control.SIZE_EXPAND
	right_spacer.size_flags_stretch_ratio = 0.05
	hbox.add_child(right_spacer)

func create_label(hbox: HBoxContainer, save_name: String, font_size: float):
	var name_label = Label.new()
	
	if save_name.length() >= 13:
		name_label.text = "%s..." % save_name.substr(0, 10)
	else:
		name_label.text = "%s" % save_name
	
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", font_size)
	hbox.add_child(name_label)

func create_action_button
(texture_path: String, button_size: float, button_box: HBoxContainer, method: Callable):
	var load_button = TextureButton.new()
	load_button.texture_normal = load(texture_path)
	load_button.ignore_texture_size = true
	load_button.stretch_mode = TextureButton.STRETCH_SCALE
	load_button.custom_minimum_size = Vector2(button_size, button_size)
	button_box.add_child(load_button)
	load_button.pressed.connect(method)

func create_top_spacer(hbox: HBoxContainer):
	var top_spacer = Control.new()
	top_spacer.size_flags_vertical = Control.SIZE_EXPAND
	top_spacer.size_flags_stretch_ratio = 0.1
	hbox.add_child(top_spacer)

func confirm_remove_on_desktop(confirm_action: Callable):
	var popup = ConfirmationDialog.new()
	popup.dialog_text = "Are you sure you want to delete this save? \n This cannot be undone."
	popup.title = "Confirm Delete"
	popup.confirmed.connect(confirm_action)
	popup.add_theme_icon_override("close", Texture2D.new())
	add_child(popup)
	
	# Get the label to center-align the text
	var label = popup.get_label()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 24)
	
	# Hide default buttons
	popup.get_ok_button().hide()
	popup.get_cancel_button().hide()
	
	# Create a VBoxContainer to structure the content vertically
	var container = VBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.custom_minimum_size = Vector2(screen_size.x * 0.25, screen_size.y * 0.25)
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
	delete_btn.texture_normal = load("res://Assets/buttons/confirm_btn_2x1.png")
	delete_btn.ignore_texture_size = true
	delete_btn.stretch_mode = TextureButton.STRETCH_SCALE
	delete_btn.custom_minimum_size = Vector2(screen_size.x * 0.12, 50)
	delete_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	delete_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button_box.add_child(delete_btn)
	delete_btn.pressed.connect(confirm_action)
	
	# Add some spacing between buttons
	var spacer_h = Control.new()
	spacer_h.custom_minimum_size = Vector2(20, 0)
	button_box.add_child(spacer_h)
	
	var exit_btn = TextureButton.new()
	exit_btn.texture_normal = load("res://Assets/buttons/cancel_btn_2x1.png")
	exit_btn.ignore_texture_size = true
	exit_btn.stretch_mode = TextureButton.STRETCH_SCALE
	exit_btn.custom_minimum_size = Vector2(screen_size.x * 0.12, 50)
	exit_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	exit_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button_box.add_child(exit_btn)
	exit_btn.pressed.connect(popup.hide)
	
	# Add bottom margin
	var bottom_margin = Control.new()
	bottom_margin.custom_minimum_size = Vector2(0, 10)
	container.add_child(bottom_margin)
	
	popup.popup_centered()

func confirm_remove_on_mobile(confirm_action: Callable):
	var popup = ConfirmationDialog.new()
	popup.dialog_text = "Are you sure you want to delete this save? \n This cannot be undone."
	popup.title = "Confirm Delete"
	popup.confirmed.connect(confirm_action)
	popup.add_theme_icon_override("close", Texture2D.new())
	add_child(popup)
	
	# Get the label to center-align the text
	var label = popup.get_label()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 40)
	
	# Hide default buttons
	popup.get_ok_button().hide()
	popup.get_cancel_button().hide()
	
	# Create a VBoxContainer to structure the content vertically
	var container = VBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.custom_minimum_size = Vector2(screen_size.x * 0.8, screen_size.y * 0.25)
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
	delete_btn.texture_normal = load("res://Assets/buttons/confirm_btn_2x1.png")
	delete_btn.ignore_texture_size = true
	delete_btn.stretch_mode = TextureButton.STRETCH_SCALE
	delete_btn.custom_minimum_size = Vector2(screen_size.x * 0.30, screen_size.y * 0.1)
	delete_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	delete_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button_box.add_child(delete_btn)
	delete_btn.pressed.connect(confirm_action)
	
	# Add some spacing between buttons
	var spacer_h = Control.new()
	spacer_h.custom_minimum_size = Vector2(20, 0)
	button_box.add_child(spacer_h)
	
	var exit_btn = TextureButton.new()
	exit_btn.texture_normal = load("res://Assets/buttons/cancel_btn_2x1.png")
	exit_btn.ignore_texture_size = true
	exit_btn.stretch_mode = TextureButton.STRETCH_SCALE
	exit_btn.custom_minimum_size = Vector2(screen_size.x * 0.3, screen_size.y * 0.1)
	exit_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	exit_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button_box.add_child(exit_btn)
	exit_btn.pressed.connect(popup.hide)
	
	# Add bottom margin
	var bottom_margin = Control.new()
	bottom_margin.custom_minimum_size = Vector2(0, 10)
	container.add_child(bottom_margin)
	
	popup.popup_centered()
