extends Control

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

func _ready():
	
	var background = $Background
	var label = $Label
	var button = $Button
	
	if not Global.is_mobile:
		set_objects_for_desktop(background, label, button)
	else:
		# we assume that is a smartphone
		set_objects_for_smartphone(background, label, button)
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _on_continue_pressed():
	Global.controls_shown = true
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	queue_free()
	get_parent().controls_menu_instance = null

func set_objects_for_desktop(background, label, button):
	var screen_size = get_viewport_rect().size
	var width = screen_size.x
	var height = screen_size.y

	background.set_size(Vector2(width * 0.8, height * 0.8))
	background.set_position(Vector2(width * 0.1, height * 0.1))
	background.color = Color(0, 0, 0, 0.5)

	var bg_size = background.size
	var bg_position = background.position

	label.text = "How to play"
	label.set_size(Vector2(bg_size.x * 0.6, bg_size.y * 0.1))
	label.set_position(Vector2(
		bg_position.x + (bg_size.x - label.size.x) / 2,
		bg_position.y + bg_size.y * 0.02
	))
	label.add_theme_font_size_override("font_size", 48)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Create controls table
	var controls_table = GridContainer.new()
	controls_table.columns = 5
	controls_table.size = Vector2(bg_size.x * 0.7, bg_size.y * 0.4)
	controls_table.position = Vector2(
		bg_position.x + (bg_size.x - controls_table.size.x) / 2,
		label.position.y + label.size.y + bg_size.y * 0.02
	)
	add_child(controls_table)

	# Populate the controls table
	for action_id in actions:
		# 1. Action name
		var action_label = Label.new()
		action_label.text = action_names[action_id]
		action_label.add_theme_font_size_override("font_size", 20)
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
		var main_key = action_keys.get(action_id, [])[0] if action_keys.has(action_id) else "Unknown"
		var main_key_label = create_key_label(main_key)
		controls_table.add_child(main_key_label)

		# 5. Aux key
		var aux_key = action_keys.get(action_id, [])[1] if action_keys.has(action_id) and action_keys[action_id].size() > 1 else ""
		if aux_key != "":
			var aux_key_label = create_key_label(aux_key)
			controls_table.add_child(aux_key_label)
		else:
			var empty = Control.new()
			empty.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			controls_table.add_child(empty)

	# Tip label
	var tip_label = Label.new()
	tip_label.text = "TIP: Hold 'Stop' and press 'Jump' to boost forward! (Shift + Space)"
	tip_label.set_size(Vector2(bg_size.x * 0.7, bg_size.y * 0.05))
	tip_label.add_theme_font_size_override("font_size", 24)
	tip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tip_label.position = Vector2(
		bg_position.x + (bg_size.x - tip_label.size.x) / 2,
		bg_size.y * 0.85
	)
	add_child(tip_label)

	# Button
	button.size = Vector2(screen_size.y * 0.16, screen_size.y * 0.08)
	button.position = Vector2(
		bg_position.x + (bg_size.x - button.size.x) / 2,
		bg_size.y * 0.95
	)

func create_key_label(text_value):
	var key_label = Label.new()
	key_label.text = text_value
	key_label.add_theme_font_size_override("font_size", 20)
	key_label.custom_minimum_size = Vector2(100, 40)
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

func set_objects_for_smartphone(background, label, button):
	var screen_size = get_viewport_rect().size
	var width = screen_size.x
	var height = screen_size.y

	# Background
	background.set_size(Vector2(width * 0.9, height * 0.85))
	background.set_position(Vector2(width * 0.05, height * 0.075))
	background.color = Color(0, 0, 0, 0.5)

	var bg_size = background.size
	var bg_position = background.position

	# Title (How to Play)
	label.text = "How to Play"
	label.set_size(Vector2(bg_size.x * 0.8, bg_size.y * 0.15))
	label.set_position(Vector2(
		bg_position.x + (bg_size.x - label.size.x) / 2,
		bg_position.y + bg_size.y * 0.03
	))
	label.add_theme_font_size_override("font_size", 64)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Table (VBoxContainer with HBoxContainers inside)
	var table_container = VBoxContainer.new()
	table_container.size = Vector2(bg_size.x * 0.8, bg_size.y * 0.25)
	table_container.position = Vector2(
		bg_position.x + (bg_size.x - table_container.size.x) / 2,
		label.position.y + label.size.y + bg_size.y * 0.02
	)
	add_child(table_container)

	# Row 1: Jump button image + "Jump"
	var row1 = HBoxContainer.new()
	row1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row1.alignment = BoxContainer.ALIGNMENT_CENTER
	table_container.add_child(row1)

	var jump_img = TextureRect.new()
	jump_img.texture = load("res://Assets/buttons/jump_button.png")
	jump_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	jump_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	jump_img.custom_minimum_size = Vector2(screen_size.y * 0.1, screen_size.y * 0.1)
	row1.add_child(jump_img)

	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(screen_size.y * 0.1, 0)
	row1.add_child(spacer1)

	var jump_label = Label.new()
	jump_label.text = "Jump"
	jump_label.add_theme_font_size_override("font_size", 32)
	jump_label.align = HORIZONTAL_ALIGNMENT_LEFT
	jump_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row1.add_child(jump_label)

	# Row 2: Stop button image + "Stop"
	var row2 = HBoxContainer.new()
	row2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row2.alignment = BoxContainer.ALIGNMENT_CENTER
	table_container.add_child(row2)

	var stop_img = TextureRect.new()
	stop_img.texture = load("res://Assets/buttons/stop_button.png")
	stop_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stop_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	stop_img.custom_minimum_size = Vector2(screen_size.y * 0.1, screen_size.y * 0.1)
	row2.add_child(stop_img)

	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(screen_size.y * 0.1, 0)
	row2.add_child(spacer2)

	var stop_label = Label.new()
	stop_label.text = "Stop"
	stop_label.add_theme_font_size_override("font_size", 32)
	stop_label.align = HORIZONTAL_ALIGNMENT_LEFT
	stop_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row2.add_child(stop_label)

	# Tips Section (VBoxContainer)
	var tips_container = VBoxContainer.new()
	tips_container.size = Vector2(bg_size.x * 0.8, bg_size.y * 0.25)
	tips_container.position = Vector2(
		bg_position.x + (bg_size.x - tips_container.size.x) / 2,
		table_container.position.y + table_container.size.y + bg_size.y * 0.02
	)
	add_child(tips_container)

	# Tip 1
	var tip1 = Label.new()
	tip1.text = "Tip: Find a comfortable position before activating the accelerometer."
	tip1.add_theme_font_size_override("font_size", 32)
	tip1.autowrap_mode = TextServer.AUTOWRAP_WORD
	tips_container.add_child(tip1)

	var tip_spacer1 = Control.new()
	tip_spacer1.custom_minimum_size = Vector2(0, screen_size.y * 0.05)
	tips_container.add_child(tip_spacer1)

	# Tip 2
	var tip2 = Label.new()
	tip2.text = "Tip: You can drag action buttons if enabled in Game Settings."
	tip2.add_theme_font_size_override("font_size", 32)
	tip2.autowrap_mode = TextServer.AUTOWRAP_WORD
	tips_container.add_child(tip2)

	var tip_spacer2 = Control.new()
	tip_spacer2.custom_minimum_size = Vector2(0, screen_size.y * 0.05)
	tips_container.add_child(tip_spacer2)

	# Tip 3
	var tip3 = Label.new()
	tip3.text = "Tip: Hold 'Stop' and press 'Jump' to boost forward!"
	tip3.add_theme_font_size_override("font_size", 32)
	tip3.autowrap_mode = TextServer.AUTOWRAP_WORD
	tips_container.add_child(tip3)

	# Button (Continue)
	button.size = Vector2(screen_size.y * 0.16, screen_size.y * 0.08)
	button.position = Vector2(
		bg_position.x + (bg_size.x - button.size.x) / 2,
		tips_container.position.y + tips_container.size.y + bg_size.y * 0.1
	)

	
