extends Control

@onready var background = $background
@onready var main_title = $main_title
@onready var audio_section_title = $audio_section_title
@onready var menu_button = $menu_button

var slider
var mute_toggle
var controls_table

var bus_index = AudioServer.get_bus_index("Master")
var actions = ["move_forward", "move_backward", "move_left", "move_right", "jump", "stop"]
var action_names = {
	"move_forward": "Move Forward",
	"move_backward": "Move Backward",
	"move_left": "Move Left",
	"move_right": "Move Right",
	"jump": "Jump",
	"stop": "Stop"
}

var action_keys = {
	"move_forward": ["W", "↑"],
	"move_backward": ["S", "↓"],
	"move_left": ["A", "←"],
	"move_right": ["D", "→"],
	"jump": ["Space", "End"],
	"stop": ["Shift"]
}


var screen_size

func _ready():
	screen_size = get_viewport_rect().size
	set_background()

	await get_tree().process_frame
	
	set_main_title()
	set_audio_title()
	set_slider_section()
	set_mute_section()
	set_controls_section()
	set_draggable_section()
	set_back_button()
	
	slider.value = Global.volume_level
	mute_toggle.is_on = AudioServer.is_bus_mute(bus_index)
	
	slider.connect("value_changed", _on_music_volume_changed)
	mute_toggle.connect("toggled", _on_mute_toggled)

func _on_music_volume_changed(value):
	Global.volume_level = value
	var fixed_value = value / 1000
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(fixed_value)
	)
	
func _on_mute_toggled(button_pressed):
	if button_pressed:
		Global.is_muted = true
		AudioServer.set_bus_mute(bus_index, true)
	else:
		Global.is_muted = false
		AudioServer.set_bus_mute(bus_index, false)

func _on_drag_toggled(button_pressed):
	if button_pressed:
		Global.allow_dragging = true
	else:
		Global.allow_dragging = false
	
func set_background():
	background.color = Color(173 / 255.0, 216 / 255.0, 230 / 255.0)
	background.set_size(screen_size)
	background.set_position(Vector2.ZERO)

func set_main_title():
	if Global.is_mobile:
		main_title.set_size(Vector2(screen_size.x * 0.5, screen_size.y * 0.1))
		var title_target = Vector2((screen_size.x - main_title.size.x) / 2, screen_size.y * 0.02)
		main_title.position = Vector2(title_target.x, title_target.y)
	else:
		main_title.set_size(Vector2(screen_size.x * 0.15, screen_size.x * 0.075))
		var title_target = Vector2((screen_size.x - main_title.size.x) / 2, screen_size.y * 0.02)
		main_title.position = Vector2(title_target.x, title_target.y)

func set_audio_title():
	var audio_section_title = Label.new()
	add_child(audio_section_title)
	
	if Global.is_mobile:
		pass
	else:
		audio_section_title.add_theme_font_size_override("font_size", 24)
		audio_section_title.text = "Audio Settings"
		audio_section_title.size_flags_horizontal = 0
		audio_section_title.set_size(Vector2(screen_size.x * 0.1, screen_size.x * 0.05))
		var title_target = Vector2((screen_size.x * 0.05), screen_size.y * 0.15)
		audio_section_title.position = Vector2(title_target.x, title_target.y)

func set_slider_section():
	if Global.is_mobile:
		pass
	else:
		var slider_container = HBoxContainer.new()
		add_child(slider_container)

		slider_container.size = Vector2(screen_size.x * 0.8, screen_size.y * 0.05)
		slider_container.size_flags_horizontal = 0
		slider_container.size_flags_vertical = 0
		slider_container.position = Vector2((screen_size.x * 0.05), screen_size.y * 0.25)

		var slider_label = Label.new()
		slider_label.add_theme_font_size_override("font_size", 20)
		slider_label.text = "Volume"
		slider_label.size_flags_horizontal = 0
		slider_container.add_child(slider_label)

		var spacer = Control.new()
		spacer.size_flags_horizontal = 3
		slider_container.add_child(spacer)
		slider_container.move_child(spacer, 1)

		slider = HSlider.new()
		slider.size_flags_horizontal = 3
		slider.size_flags_vertical = 1
		slider.size = Vector2(screen_size.x * 0.5, screen_size.y * 0.05)
		slider.min_value = 0
		slider.max_value = 100
		slider.value = Global.volume_level
		slider.step = 1
		slider_container.add_child(slider)

func set_mute_section():
	if Global.is_mobile:
		# HBOX
		var mute_container = VBoxContainer.new()
		mute_container.size = Vector2(screen_size.x * 0.9, screen_size.y * 0.2)
		mute_container.position = Vector2(
			(screen_size.x - mute_container.size.x) / 2, 
			screen_size.y * 0.2)
		add_child(mute_container)
		
		mute_container.alignment = BoxContainer.ALIGNMENT_CENTER
		
		# Label
		var mute_label = Label.new()
		mute_label.add_theme_font_size_override("font_size", 50)
		mute_label.text = "Mute Game"
		mute_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		mute_container.add_child(mute_label)
		
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(0, 20)
		mute_container.add_child(spacer)
		
		# Checkbox
		mute_toggle = preload("res://Scripts/Interface/toogle_button.gd").new()
		mute_toggle.is_on = Global.is_muted
		mute_container.toggle_width = mute_container.size.y * 0.25
		mute_container.toggle_height = mute_container.size.y * 0.125
		mute_toggle.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		mute_container.add_child(mute_toggle)
		mute_toggle.connect("toogled", _on_mute_toggled)
		
	else:
		# HBOX
		var mute_container = HBoxContainer.new()
		mute_container.size = Vector2(screen_size.x * 0.8, screen_size.y * 0.05)
		mute_container.size_flags_horizontal = 0
		mute_container.size_flags_vertical = 0
		mute_container.position = Vector2((screen_size.x * 0.05), screen_size.y * 0.35)
		add_child(mute_container)
		
		# Label
		var mute_label = Label.new()
		mute_label.add_theme_font_size_override("font_size", 20)
		mute_label.text = "Mute game"
		mute_label.size_flags_horizontal = 0
		mute_container.add_child(mute_label)
		
		# Spacer
		var spacer = Control.new()
		spacer.size_flags_horizontal = 3
		mute_container.add_child(spacer)
		mute_container.move_child(spacer, 1)
		
		# Checkbox
		mute_toggle = preload("res://Scripts/Interface/toogle_button.gd").new()
		mute_toggle.is_on = Global.is_muted
		mute_toggle.toggle_width = mute_container.size.y * 2
		mute_toggle.toggle_height = mute_container.size.y
		mute_toggle.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		mute_container.add_child(mute_toggle)
		mute_toggle.connect("toogled", _on_mute_toggled)
		
func set_controls_section():
	if Global.is_mobile:
		pass
	else:
		# Controls title
		var controls_section_title = Label.new()
		controls_section_title.add_theme_font_size_override("font_size", 24)
		controls_section_title.text = "Key Binds"
		controls_section_title.size_flags_horizontal = 0
		controls_section_title.set_size(Vector2(screen_size.x * 0.15, screen_size.x * 0.05))
		var title_target = Vector2((screen_size.x * 0.05), screen_size.y * 0.45)
		controls_section_title.position = Vector2(title_target.x, title_target.y)
		add_child(controls_section_title)
		
		# Controls table
		controls_table = GridContainer.new()
		controls_table.size = Vector2(screen_size.x * 0.8, screen_size.y * 0.3)
		controls_table.position = Vector2(screen_size.x * 0.05, controls_section_title.position.y + controls_section_title.size.y)
		controls_table.columns = 5
		add_child(controls_table)
		
		# Generate the table rows
		update_controls_table()

func set_draggable_section():
	if Global.is_mobile:
		
		var drag_container = VBoxContainer.new()
		drag_container.size = Vector2(screen_size.x * 0.9, screen_size.y * 0.2)
		drag_container.position = Vector2(
			(screen_size.x - drag_container.size.x) / 2, 
			screen_size.y * 0.35)
		add_child(drag_container)
		
		drag_container.alignment = BoxContainer.ALIGNMENT_CENTER
		
		# Label
		var drag_label = Label.new()
		drag_label.add_theme_font_size_override("font_size", 50)
		drag_label.text = "Enable button dragging"
		drag_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		drag_container.add_child(drag_label)
		
		# Spacer
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(0, 20)
		drag_container.add_child(spacer)
		
		# Checkbox
		var drag_toogle = preload("res://Scripts/Interface/toogle_button.gd").new()
		drag_toogle.is_on = Global.allow_dragging
		drag_toogle.toggle_width = drag_container.size.y * 0.25
		drag_toogle.toggle_height = drag_container.size.y * 0.125
		drag_toogle.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		drag_container.add_child(drag_toogle)
		drag_toogle.button_pressed = Global.allow_dragging
		drag_toogle.connect("toogled", _on_drag_toggled)
	else:
		pass
	
func set_back_button():
	if Global.is_mobile:
		menu_button.size = Vector2(screen_size.y * 0.16, screen_size.y * 0.08)
		menu_button.position = Vector2(
			(screen_size.x - menu_button.size.x) / 2, screen_size.y * 0.8
		)
	else:
		menu_button.size = Vector2(screen_size.x * 0.15, screen_size.y * 0.08)
		menu_button.position = Vector2(
			(screen_size.x - menu_button.size.x) / 2, screen_size.y * 0.9
		)

func update_controls_table():
	for action_id in actions:
		# 1. Action name
		var action_label = Label.new()
		action_label.text = action_names[action_id]
		action_label.add_theme_font_size_override("font_size", 20)
		action_label.custom_minimum_size = Vector2(screen_size.x * 0.2, screen_size.y * 0.05)
		action_label.align = HORIZONTAL_ALIGNMENT_LEFT
		action_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		controls_table.add_child(action_label)

		# 2. Spacer
		var spacer1 = Control.new()
		spacer1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		controls_table.add_child(spacer1)

		# 3. Spacer
		var spacer2 = Control.new()
		spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		controls_table.add_child(spacer2)

		# 4. Main key
		var keys = action_keys.get(action_id, [])
		var main_key = keys[0] if keys.size() > 0 else "Unknown"
		var main_key_label = create_key_label(main_key)
		controls_table.add_child(main_key_label)

		# 5. Auxiliary key
		var aux_key = keys[1] if keys.size() > 1 else ""
		if aux_key != "":
			var aux_key_label = create_key_label(aux_key)
			controls_table.add_child(aux_key_label)
		else:
			var empty_label = Label.new()
			empty_label.custom_minimum_size = Vector2(screen_size.x * 0.1, screen_size.y * 0.05)
			controls_table.add_child(empty_label)

func create_key_label(text_value):
	var key_label = Label.new()
	key_label.text = text_value
	key_label.add_theme_font_size_override("font_size", 16)
	key_label.custom_minimum_size = Vector2(screen_size.x * 0.1, screen_size.y * 0.05)
	key_label.align = HORIZONTAL_ALIGNMENT_CENTER
	key_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.7, 0.7, 0.7)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	key_label.add_theme_stylebox_override("normal", style)
	
	return key_label

func on_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/Interface/MainMenu.tscn")
