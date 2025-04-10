extends Control

@onready var background = $background
@onready var main_title = $main_title
@onready var audio_section_title = $audio_section_title

# Slider Section
@onready var slider_container = $slider_container
@onready var slider_label = $slider_container/slider_label
@onready var slider = $slider_container/slider

# Mute Section
@onready var mute_container = $mute_container
@onready var mute_label = $mute_container/mute_label
@onready var mute_checkbox = $mute_container/mute_checkbox

# Controls Section
@onready var controls_section_title = $controls_section_title
@onready var controls_table = $controls_table

# Exit Section
@onready var menu_button = $menu_button


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
var default_actions = {
	"move_forward": KEY_W,
	"move_backward": KEY_S,
	"move_left": KEY_A,
	"move_right": KEY_D,
	"jump": KEY_SPACE,
	"stop": KEY_SHIFT
}

var waiting_for_key = false
var action_to_rebind = ""

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
	mute_checkbox.button_pressed = AudioServer.is_bus_mute(bus_index)

	
	# Connect signals
	slider.connect("value_changed", _on_music_volume_changed)
	mute_checkbox.connect("toggled", _on_mute_toggled)

	
func _input(event):
	if waiting_for_key:
		if event is InputEventKey and event.pressed:
			if event.keycode == KEY_ESCAPE:
				cancel_rebinding()
				return
				
			remap_action_key(action_to_rebind, event)
			
			get_viewport().set_input_as_handled()
			return

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
	if Global.is_mobile:
		audio_section_title.add_theme_font_size_override("font_size", 60)
		audio_section_title.text = "Audio Settings"
		audio_section_title.size_flags_horizontal = 0
		audio_section_title.set_size(Vector2(screen_size.x * 0.5, screen_size.y * 0.05))
		var title_target = Vector2((screen_size.x * 0.05), screen_size.y * 0.2)
		audio_section_title.position = Vector2(title_target.x, title_target.y)
	else:
		audio_section_title.add_theme_font_size_override("font_size", 24)
		audio_section_title.text = "Audio Settings"
		audio_section_title.size_flags_horizontal = 0
		audio_section_title.set_size(Vector2(screen_size.x * 0.1, screen_size.x * 0.05))
		var title_target = Vector2((screen_size.x * 0.05), main_title.size.y * 1.25)
		audio_section_title.position = Vector2(title_target.x, title_target.y)

func set_slider_section():
	if Global.is_mobile:
		# HBOX
		slider_container.size = Vector2(screen_size.x * 0.9, screen_size.y * 0.1)
		slider_container.size_flags_horizontal = 0
		slider_container.size_flags_vertical = 0
		slider_container.position = Vector2((screen_size.x * 0.05), screen_size.y * 0.3)
		
		# Label
		slider_label.add_theme_font_size_override("font_size", 50)
		slider_label.text = "Volume"
		slider_label.size_flags_horizontal = 0
		
		# Spacer
		var spacer = Control.new()
		spacer.size_flags_horizontal = 3
		slider_container.add_child(spacer)
		slider_container.move_child(spacer, 1)
		
		# Slider
		slider.size_flags_horizontal = 3
		slider.size_flags_vertical = 1
		slider.size = Vector2(screen_size.x * 0.5, slider_container.size.y)
		slider.min_value = 0
		slider.max_value = 100
		slider.value = Global.volume_level
		slider.step = 1
	else:
		# HBOX
		slider_container.size = Vector2(screen_size.x * 0.8, screen_size.y * 0.05)
		slider_container.size_flags_horizontal = 0
		slider_container.size_flags_vertical = 0
		slider_container.position = Vector2((screen_size.x * 0.05), audio_section_title.position.y * 1.5)
		
		# Label
		slider_label.add_theme_font_size_override("font_size", 16)
		slider_label.text = "Volume"
		slider_label.size_flags_horizontal = 0
		
		# Spacer
		var spacer = Control.new()
		spacer.size_flags_horizontal = 3
		slider_container.add_child(spacer)
		slider_container.move_child(spacer, 1)
		
		# Slider
		slider.size_flags_horizontal = 3
		slider.size_flags_vertical = 1
		slider.size = Vector2(screen_size.x * 0.5, screen_size.y * 0.05)
		slider.min_value = 0
		slider.max_value = 100
		slider.value = Global.volume_level
		slider.step = 1

func set_mute_section():
	if Global.is_mobile:
		# HBOX
		mute_container.size = Vector2(screen_size.x * 0.9, screen_size.y * 0.1)
		mute_container.size_flags_horizontal = 0
		mute_container.size_flags_vertical = 0
		mute_container.position = Vector2(screen_size.x * 0.05, screen_size.y * 0.4)
		
		# Label
		mute_label.add_theme_font_size_override("font_size", 50)
		mute_label.text = "Mute game"
		mute_label.size_flags_horizontal = 0
		
		# Spacer
		var spacer = Control.new()
		spacer.size_flags_horizontal = 3
		mute_container.add_child(spacer)
		mute_container.move_child(spacer, 1)
		
		# Checkbox
		mute_checkbox.button_pressed = Global.is_muted
		mute_checkbox.size_flags_horizontal = 0
		mute_checkbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
		mute_checkbox.custom_minimum_size = Vector2(mute_container.size.y, mute_container.size.y)
	else:
		# HBOX
		mute_container.size = Vector2(screen_size.x * 0.8, screen_size.y * 0.05)
		mute_container.size_flags_horizontal = 0
		mute_container.size_flags_vertical = 0
		mute_container.position = Vector2((screen_size.x * 0.05), slider_container.position.y * 1.25)
		
		# Label
		mute_label.add_theme_font_size_override("font_size", 16)
		mute_label.text = "Mute game"
		mute_label.size_flags_horizontal = 0
		
		# Spacer
		var spacer = Control.new()
		spacer.size_flags_horizontal = 3
		mute_container.add_child(spacer)
		mute_container.move_child(spacer, 1)
		
		# Checkbox
		mute_checkbox.button_pressed = Global.is_muted
		mute_checkbox.size_flags_horizontal = 0
		mute_checkbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
		mute_checkbox.custom_minimum_size = Vector2(mute_container.size.y, mute_container.size.y)

func set_controls_section():
	if Global.is_mobile:
		controls_section_title.visible = false
		controls_table.visible = false
	else:
		# Controls title
		controls_section_title.add_theme_font_size_override("font_size", 24)
		controls_section_title.text = "Key Binds"
		controls_section_title.size_flags_horizontal = 0
		controls_section_title.set_size(Vector2(screen_size.x * 0.15, screen_size.x * 0.05))
		var title_target = Vector2((screen_size.x * 0.05), mute_container.position.y + mute_container.size.y * 1.5)
		controls_section_title.position = Vector2(title_target.x, title_target.y)
		
		# Controls table setup
		controls_table.size = Vector2(screen_size.x * 0.8, screen_size.y * 0.3)
		controls_table.position = Vector2(screen_size.x * 0.05, controls_section_title.position.y + controls_section_title.size.y * 1)
		controls_table.columns = 2
		
		# Load controls from InputMap or create default ones
		load_controls()
		
		# Generate the table rows
		update_controls_table()

func set_draggable_section():
	if Global.is_mobile:
		
		var drag_section_title = Label.new()
		drag_section_title.add_theme_font_size_override("font_size", 60)
		drag_section_title.text = "Game Settings"
		drag_section_title.size_flags_horizontal = 0
		drag_section_title.set_size(Vector2(screen_size.x * 0.5, screen_size.y * 0.05))
		var title_target = Vector2((screen_size.x * 0.05), screen_size.y * 0.5)
		drag_section_title.position = Vector2(title_target.x, title_target.y)
		add_child(drag_section_title)
		
		var drag_container = HBoxContainer.new()
		drag_container.size = Vector2(screen_size.x * 0.9, screen_size.y * 0.1)
		drag_container.size_flags_horizontal = 0
		drag_container.size_flags_vertical = 0
		drag_container.position = Vector2((screen_size.x * 0.05), screen_size.y * 0.6)
		add_child(drag_container)
		
		# Label
		var drag_label = Label.new()
		drag_label.add_theme_font_size_override("font_size", 50)
		drag_label.text = "Allow moving buttons"
		drag_label.size_flags_horizontal = 0
		drag_container.add_child(drag_label)
		
		# Spacer
		var spacer = Control.new()
		spacer.size_flags_horizontal = 3
		drag_container.add_child(spacer)
		drag_container.move_child(spacer, 1)
		
		# Checkbox
		
		var drag_checkbox = CheckBox.new()
		drag_checkbox.size_flags_horizontal = 0
		drag_checkbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
		drag_checkbox.custom_minimum_size = Vector2(drag_container.size.y, drag_container.size.y)
		drag_container.add_child(drag_checkbox)
		drag_checkbox.button_pressed = Global.allow_dragging
		drag_checkbox.connect("toggled", _on_drag_toggled)
	else:
		pass
	
func set_back_button():
	if Global.is_mobile:
		menu_button.size = Vector2(screen_size.x * 0.15, screen_size.y * 0.08)
		menu_button.position = Vector2(
			(screen_size.x - menu_button.size.x) / 2, screen_size.y * 0.9
		)
	else:
		menu_button.size = Vector2(screen_size.x * 0.15, screen_size.y * 0.08)
		menu_button.position = Vector2(
			(screen_size.x - menu_button.size.x) / 2, controls_table.position.y + controls_table.size.y * 1.25
		)

func load_controls():
	var config = ConfigFile.new()
	var err = config.load("user://input_settings.cfg")
	
	for action_id in actions:
		if !InputMap.has_action(action_id):
			InputMap.add_action(action_id)
			
		InputMap.action_erase_events(action_id)
		
		if err != OK:
			var event = InputEventKey.new()
			event.keycode = default_actions[action_id]
			event.pressed = true
			InputMap.action_add_event(action_id, event)
		else:
			if config.has_section_key("inputs", action_id):
				var keycode = config.get_value("inputs", action_id, default_actions[action_id])
				var event = InputEventKey.new()
				event.keycode = keycode
				event.pressed = true
				InputMap.action_add_event(action_id, event)
			else:
				var event = InputEventKey.new()
				event.keycode = default_actions[action_id]
				event.pressed = true
				InputMap.action_add_event(action_id, event)

func update_controls_table():

	for action_id in actions:
		var action_label = Label.new()
		action_label.text = action_names[action_id]
		action_label.add_theme_font_size_override("font_size", 16)
		action_label.custom_minimum_size = Vector2(screen_size.x * 0.3, screen_size.y * 0.05)
		controls_table.add_child(action_label)
		
		var key_button = Button.new()
		key_button.size_flags_horizontal = 3
		key_button.text = get_action_key_string(action_id)
		key_button.custom_minimum_size = Vector2(screen_size.x * 0.3, screen_size.y * 0.05)
		key_button.name = "btn_" + action_id
		key_button.connect("pressed", Callable(self, "_on_key_button_pressed").bind(action_id))
		controls_table.add_child(key_button)

func get_action_key_string(action_id):
	var events = InputMap.action_get_events(action_id)
	if events.size() == 0:
		return "Unassigned"
		
	var event = events[0]
	
	if event is InputEventKey:
		return OS.get_keycode_string(event.keycode)
		
	return "Unknown"

func _on_key_button_pressed(action_id):
	if waiting_for_key:
		cancel_rebinding()
	
	action_to_rebind = action_id
	waiting_for_key = true
	
	var button = controls_table.get_node("btn_" + action_id)
	button.text = "Press any key..."	

func cancel_rebinding():
	if waiting_for_key:
		var button = controls_table.get_node("btn_" + action_to_rebind)
		button.text = get_action_key_string(action_to_rebind)
		waiting_for_key = false
		action_to_rebind = ""

func remap_action_key(action_id, event):
	InputMap.action_erase_events(action_id)
	
	if event is InputEventKey:
		InputMap.action_add_event(action_id, event)
		
		var button = controls_table.get_node("btn_" + action_id)
		button.text = OS.get_keycode_string(event.keycode)
		
		save_controls()
	
	waiting_for_key = false
	action_to_rebind = ""

func save_controls():
	var config = ConfigFile.new()
	
	config.load("user://input_settings.cfg")
	
	for action_id in actions:
		var events = InputMap.action_get_events(action_id)
		if events.size() > 0 and events[0] is InputEventKey:
			config.set_value("inputs", action_id, events[0].keycode)
	
	config.save("user://input_settings.cfg")

func on_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/Interface/MainMenu.tscn")
