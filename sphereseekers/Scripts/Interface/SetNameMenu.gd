extends Node2D

var label_instance: Label
var error_label_instance: Label
var name_input_instance: LineEdit
var continue_button_instance: Button
	
# Called when the node enters the scene tree for the first time.
func _ready():
	label_instance = $title
	name_input_instance = $name_input
	continue_button_instance = $continue
	error_label_instance = $error
	
	if not Global.is_mobile:
		set_objects_for_desktop(label_instance, name_input_instance, continue_button_instance, error_label_instance)
	else:
		# we assume that is a smartphone
		set_objects_for_smartphone(label_instance, name_input_instance, continue_button_instance, error_label_instance)

func _on_continue_pressed():
	var trimmed_text = name_input_instance.text.strip_edges()
	
	if trimmed_text == "":
		error_label_instance.text = "Please enter your name"
		error_label_instance.modulate = Color(1, 0, 0)
		error_label_instance.visible = true
		return
		
	error_label_instance.visible = false
	var save_names: Array = LocalStorage.get_save_names()
	
	if trimmed_text in save_names:
		_on_override_confirm(trimmed_text)
	else:
		save_names.append(trimmed_text)
		LocalStorage.set_save_names(save_names)
		
		# Change the scene to Level1
		Global.is_paused = false
		PlayerClass.playerName = trimmed_text
		get_tree().change_scene_to_file("res://Scenes/Levels/Tutorial.tscn")

func _on_override_confirm(save_name):
	var popup = ConfirmationDialog.new()
	popup.dialog_text = "Save with this name already exists. Are you sure you want to override that save?"
	popup.ok_button_text = "Override"
	popup.cancel_button_text = "Exit"
	popup.get_ok_button().modulate = Color.RED
	add_child(popup)
	popup.confirmed.connect(_on_override_pressed.bind(save_name))
	popup.popup_centered()

func _on_override_pressed(_save_name):
	Global.is_paused = false
	PlayerClass.playerName = save_name
	get_tree().change_scene_to_file("res://Scenes/Levels/Tutorial.tscn")

func set_objects_for_desktop(label, name_input, continue_button, error_label):
	var screen_size = get_viewport_rect().size
	var width = screen_size.x
	var height = screen_size.y

	# Title
	label.set_size(Vector2(width * 0.75, height * 0.15))
	label.text = "Set Name"
	label.set_position(Vector2(
		(width - label.size.x) / 2,
		(height - label.size.y) / 10
	))
	label.add_theme_font_size_override("font_size", 48)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.visible = true

	# LineEdit
	name_input.set_size(Vector2(width * 0.75, height * 0.08))
	name_input.set_position(Vector2(
		(width - name_input.size.x) / 2,
		label.position.y + label.size.y + height * 0.2
	))
	name_input.placeholder_text = "Enter your name"
	name_input.visible = true

	# Continue Button
	continue_button.set_size(Vector2(width * 0.5, height * 0.08))
	continue_button.set_position(Vector2(
		(width - continue_button.size.x) / 2,
		name_input.position.y + name_input.size.y + height * 0.1 
	))
	continue_button.text = "Continue"
	continue_button.visible = true

	# Error Label
	error_label.set_size(Vector2(width * 0.75, height * 0.05))
	error_label.set_position(Vector2(
		(width - error_label.size.x) / 2,
		continue_button.position.y + continue_button.size.y + height * 0.1
	))
	error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	error_label.modulate = Color(1, 0, 0)
	error_label.visible = false

func set_objects_for_smartphone(label, name_input, continue_button, error_label):
	var screen_size = get_viewport_rect().size
	var width = screen_size.x
	var height = screen_size.y

	# Title
	label.set_size(Vector2(width * 0.75, height * 0.15))
	label.text = "Set Name"
	label.set_position(Vector2(
		(width - label.size.x) / 2,
		(height - label.size.y) / 10
	))
	label.add_theme_font_size_override("font_size", 48)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.visible = true

	# LineEdit
	name_input.set_size(Vector2(width * 0.75, height * 0.08))
	name_input.set_position(Vector2(
		(width - name_input.size.x) / 2,
		label.position.y + label.size.y + height * 0.2
	))
	name_input.placeholder_text = "Enter your name"
	name_input.visible = true

	# Continue Button
	continue_button.set_size(Vector2(width * 0.5, height * 0.08))
	continue_button.set_position(Vector2(
		(width - continue_button.size.x) / 2,
		name_input.position.y + name_input.size.y + height * 0.1 
	))
	continue_button.text = "Continue"
	continue_button.visible = true

	# Error Label
	error_label.set_size(Vector2(width * 0.75, height * 0.05))
	error_label.set_position(Vector2(
		(width - error_label.size.x) / 2,
		continue_button.position.y + continue_button.size.y + height * 0.1
	))
	error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	error_label.modulate = Color(1, 0, 0)
	error_label.visible = false
	
