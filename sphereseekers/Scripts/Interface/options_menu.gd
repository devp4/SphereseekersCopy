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
@onready var reset_controls_button = $reset_controls_button
@onready var message_label = $message_label

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

	await get_tree().process_frame  # wait for next frame

	set_main_title()
	set_audio_title()
	set_slider_section()
	set_mute_section()
	set_controls_section()
	
	# Connect signals
	slider.connect("value_changed", _on_music_volume_changed)
	mute_checkbox.connect("toggled", _on_mute_toggled)
	reset_controls_button.connect("pressed", _on_reset_controls_pressed)

	# Hide message label initially
	message_label.visible = false
	
func _input(event):
	if waiting_for_key:
		if event is InputEventKey and event.pressed:
			# Don't capture Escape key as it's often used to cancel
			if event.keycode == KEY_ESCAPE:
				cancel_rebinding()
				return
				
			# Assign this key to the selected action
			remap_action_key(action_to_rebind, event)
			
			# Mark the event as handled
			get_viewport().set_input_as_handled()
			return

func _on_music_volume_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
	
func _on_mute_toggled(button_pressed):
	if button_pressed:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)

func set_background():
	background.color = Color(173 / 255.0, 216 / 255.0, 230 / 255.0)
	background.set_size(screen_size)
	background.set_position(Vector2.ZERO)

func set_main_title():
	if Global.is_mobile:
		pass
	else:
		main_title.set_size(Vector2(screen_size.x * 0.15, screen_size.x * 0.075))
		var title_target = Vector2((screen_size.x - main_title.size.x) / 2, screen_size.y * 0.02)
		main_title.position = Vector2(title_target.x, title_target.y)

func set_audio_title():
	if Global.is_mobile:
		pass
	else:
		audio_section_title.add_theme_font_size_override("font_size", 24)
		audio_section_title.text = "Audio Settings"
		audio_section_title.size_flags_horizontal = 0
		audio_section_title.set_size(Vector2(screen_size.x * 0.1, screen_size.x * 0.05))
		var title_target = Vector2((screen_size.x * 0.05), main_title.size.y * 1.25)
		audio_section_title.position = Vector2(title_target.x, title_target.y)

func set_slider_section():
	if Global.is_mobile:
		pass
	else:
		# HBOX
		slider_container.size = Vector2(screen_size.x * 0.8, screen_size.y * 0.05)
		slider_container.size_flags_horizontal = 0
		slider_container.size_flags_vertical = 0
		slider_container.position = Vector2((screen_size.x * 0.05), audio_section_title.position.y * 1.5)
		
		# Label
		slider_label.add_theme_font_size_override("font_size", 24)
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
		slider.value = 100
		slider.step = 1

func set_mute_section():
	if Global.is_mobile:
		pass
	else:
		# HBOX
		mute_container.size = Vector2(screen_size.x * 0.8, screen_size.y * 0.05)
		mute_container.size_flags_horizontal = 0
		mute_container.size_flags_vertical = 0
		mute_container.position = Vector2((screen_size.x * 0.05), slider_container.position.y * 1.25)
		
		# Label
		mute_label.add_theme_font_size_override("font_size", 24)
		mute_label.text = "Mute game"
		mute_label.size_flags_horizontal = 0
		
		# Spacer
		var spacer = Control.new()
		spacer.size_flags_horizontal = 3
		mute_container.add_child(spacer)
		mute_container.move_child(spacer, 1)
		
		# Slider
		mute_checkbox.size = Vector2(screen_size.x * 0.1, screen_size.x * 0.1)

func set_controls_section():
	if Global.is_mobile:
		pass
	else:
		# Controls title
		controls_section_title.add_theme_font_size_override("font_size", 24)
		controls_section_title.text = "Control Settings"
		controls_section_title.size_flags_horizontal = 0
		controls_section_title.set_size(Vector2(screen_size.x * 0.15, screen_size.x * 0.05))
		var title_target = Vector2((screen_size.x * 0.05), mute_container.position.y + mute_container.size.y * 1.25)
		controls_section_title.position = Vector2(title_target.x, title_target.y)
		
		# Controls table setup
		controls_table.size = Vector2(screen_size.x * 0.8, screen_size.y * 0.3)
		controls_table.position = Vector2(screen_size.x * 0.05, controls_section_title.position.y + controls_section_title.size.y * 1.25)
		controls_table.columns = 2
		
		# Add header row
		var header_action = Label.new()
		header_action.text = "Action"
		header_action.add_theme_font_size_override("font_size", 20)
		header_action.custom_minimum_size = Vector2(screen_size.x * 0.3, 40)
		controls_table.add_child(header_action)
		
		var header_key = Label.new()
		header_key.text = "Key Binding"
		header_key.add_theme_font_size_override("font_size", 20)
		header_key.custom_minimum_size = Vector2(screen_size.x * 0.3, 40)
		controls_table.add_child(header_key)
		
		# Load controls from InputMap or create default ones
		load_controls()
		
		# Generate the table rows
		update_controls_table()
		
		# Reset controls button
		reset_controls_button.text = "Reset to Defaults"
		reset_controls_button.custom_minimum_size = Vector2(150, 50)
		reset_controls_button.position = Vector2(
			controls_table.position.x + controls_table.size.x - reset_controls_button.custom_minimum_size.x,
			controls_table.position.y + controls_table.size.y + 20
		)
		
		# Message label for feedback
		message_label.text = ""
		message_label.add_theme_font_size_override("font_size", 18)
		message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		message_label.custom_minimum_size = Vector2(400, 40)
		message_label.position = Vector2(
			(screen_size.x - message_label.custom_minimum_size.x) / 2,
			reset_controls_button.position.y
		)

func load_controls():
	var config = ConfigFile.new()
	var err = config.load("user://input_settings.cfg")
	
	for action_id in actions:
		if !InputMap.has_action(action_id):
			InputMap.add_action(action_id)
			
		# Clear any existing bindings
		InputMap.action_erase_events(action_id)
		
		if err != OK:
			# No saved config found, set up defaults
			var event = InputEventKey.new()
			event.keycode = default_actions[action_id]
			event.pressed = true
			InputMap.action_add_event(action_id, event)
		else:
			# Load from saved config
			if config.has_section_key("inputs", action_id):
				var keycode = config.get_value("inputs", action_id, default_actions[action_id])
				var event = InputEventKey.new()
				event.keycode = keycode
				event.pressed = true
				InputMap.action_add_event(action_id, event)
			else:
				# Use default if this action isn't in the config
				var event = InputEventKey.new()
				event.keycode = default_actions[action_id]
				event.pressed = true
				InputMap.action_add_event(action_id, event)

# Update the controls table UI
func update_controls_table():
	# Remove existing action rows (keep headers)
	for i in range(controls_table.get_child_count() - 1, 1, -1):
		controls_table.get_child(i).queue_free()
	
	# Add a row for each action
	for action_id in actions:
		var action_label = Label.new()
		action_label.text = action_names[action_id]
		action_label.add_theme_font_size_override("font_size", 16)
		action_label.custom_minimum_size = Vector2(screen_size.x * 0.3, 40)
		controls_table.add_child(action_label)
		
		var key_button = Button.new()
		key_button.text = get_action_key_string(action_id)
		key_button.custom_minimum_size = Vector2(screen_size.x * 0.3, 40)
		key_button.name = "btn_" + action_id
		key_button.connect("pressed", Callable(self, "_on_key_button_pressed").bind(action_id))
		controls_table.add_child(key_button)

# Get a string representation of the key assigned to an action
func get_action_key_string(action_id):
	var events = InputMap.action_get_events(action_id)
	if events.size() == 0:
		return "Unassigned"
		
	var event = events[0]
	
	if event is InputEventKey:
		return OS.get_keycode_string(event.keycode)
		
	return "Unknown"

# Handle key button press to start rebinding
func _on_key_button_pressed(action_id):
	if waiting_for_key:
		# Cancel previous rebinding
		cancel_rebinding()
	
	# Start waiting for input
	action_to_rebind = action_id
	waiting_for_key = true
	
	# Update UI
	var button = controls_table.get_node("btn_" + action_id)
	button.text = "Press any key..."
	
	# Show message
	message_label.text = "Press any key to bind to '" + action_names[action_id] + "' (ESC to cancel)"
	message_label.visible = true

# Cancel the current key rebinding
func cancel_rebinding():
	if waiting_for_key:
		var button = controls_table.get_node("btn_" + action_to_rebind)
		button.text = get_action_key_string(action_to_rebind)
		waiting_for_key = false
		action_to_rebind = ""
		message_label.visible = false

# Remap a key for an action
func remap_action_key(action_id, event):
	# Clear existing bindings
	InputMap.action_erase_events(action_id)
	
	# Add new binding
	if event is InputEventKey:
		InputMap.action_add_event(action_id, event)
		
		# Update the UI
		var button = controls_table.get_node("btn_" + action_id)
		button.text = OS.get_keycode_string(event.keycode)
		
		# Save settings
		save_controls()
		
		# Show confirmation
		message_label.text = "Control remapped successfully!"
		message_label.visible = true
		
		# Hide message after a delay
		await get_tree().create_timer(1.5).timeout
		if message_label.text == "Control remapped successfully!":
			message_label.visible = false
	
	# Reset state
	waiting_for_key = false
	action_to_rebind = ""

# Save control settings to file
func save_controls():
	var config = ConfigFile.new()
	
	# Load existing config first so we don't lose other settings
	config.load("user://input_settings.cfg")
	
	# Save each action's keycode
	for action_id in actions:
		var events = InputMap.action_get_events(action_id)
		if events.size() > 0 and events[0] is InputEventKey:
			config.set_value("inputs", action_id, events[0].keycode)
	
	config.save("user://input_settings.cfg")

# Reset controls to defaults
func _on_reset_controls_pressed():
	# Ask for confirmation
	var confirm_dialog = ConfirmationDialog.new()
	confirm_dialog.title = "Reset Controls"
	confirm_dialog.dialog_text = "Reset all controls to default settings?"
	confirm_dialog.get_ok_button().text = "Reset"
	confirm_dialog.connect("confirmed", Callable(self, "_reset_controls_confirmed"))
	add_child(confirm_dialog)
	confirm_dialog.popup_centered()

# Handle confirmation of reset
func _reset_controls_confirmed():
	for action_id in actions:
		# Clear existing bindings
		InputMap.action_erase_events(action_id)
		
		# Set up default key
		var event = InputEventKey.new()
		event.keycode = default_actions[action_id]
		event.pressed = true
		InputMap.action_add_event(action_id, event)
	
	# Update UI
	update_controls_table()
	
	# Save settings
	save_controls()
	
	# Show confirmation
	message_label.text = "Controls reset to defaults!"
	message_label.visible = true
	
	# Hide message after a delay
	await get_tree().create_timer(1.5).timeout
	if message_label.text == "Controls reset to defaults!":
		message_label.visible = false
