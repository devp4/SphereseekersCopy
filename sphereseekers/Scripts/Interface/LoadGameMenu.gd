extends Node2D

func _ready():
	var screen_size = get_viewport_rect().size
	var width = screen_size.x
	var height = screen_size.y
	
	# Main vertical container
	var main_vbox = VBoxContainer.new()
	main_vbox.size = Vector2(width * 0.6, height * 0.8)
	main_vbox.set_position(Vector2(
		(width - main_vbox.size.x) / 2,
		height * 0.1  # Top margin
	))
	main_vbox.add_theme_constant_override("separation", 20)
	add_child(main_vbox)
	
	# Title label
	var title_label = Label.new()
	title_label.text = "Load Game"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 30)
	title_label.add_theme_constant_override("margin_bottom", 20)
	main_vbox.add_child(title_label)
	
	# Scroll container
	var scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(scroll_container)
	
	# Items container with padding
	var items_vbox = VBoxContainer.new()
	items_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	items_vbox.add_theme_constant_override("margin_left", 20)
	items_vbox.add_theme_constant_override("margin_right", 20)
	items_vbox.add_theme_constant_override("separation", 10)
	scroll_container.add_child(items_vbox)
	
	var saves = LocalStorage.get_save_names()
	
	for save_name in saves:
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 20)
		items_vbox.add_child(hbox)
		
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
		var load_button = Button.new()
		load_button.text = "Load"
		load_button.custom_minimum_size = Vector2(80, 30)
		button_box.add_child(load_button)
		load_button.pressed.connect(_on_load_pressed.bind(save_name))
		
		# Delete button
		var delete_button = Button.new()
		delete_button.text = "Delete"
		delete_button.custom_minimum_size = Vector2(80, 30)
		delete_button.modulate = Color.RED
		button_box.add_child(delete_button)
		delete_button.pressed.connect(_on_delete_confirm.bind(save_name))
		
	var main_menu_button = Button.new()
	main_menu_button.text = "Main Menu"
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	main_vbox.add_child(main_menu_button)

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/Interface/MainMenu.tscn")

func _on_load_pressed(save_name):
	print("Loading save: ", save_name)
	
func _on_delete_confirm(save_name):
	var popup = ConfirmationDialog.new()
	popup.dialog_text = "Are you sure you want to delete this save? This cannot be undone."
	popup.ok_button_text = "Delete"
	popup.cancel_button_text = "Exit"
	popup.get_ok_button().modulate = Color.RED
	popup.confirmed.connect(_on_delete_pressed.bind(save_name))
	add_child(popup)
	popup.popup_centered()

func _on_delete_pressed(save_name):
	var saves = LocalStorage.get_save_names()
	var new_saves = []
	
	for save in saves:
		if save != save_name:
			new_saves.append(save)
	
	LocalStorage.set_save_names(new_saves)
	get_tree().change_scene_to_file("res://Scenes/Interface/LoadGameMenu.tscn")
	 
	
	
