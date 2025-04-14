extends Control

var slider
var mute_toggle
var drag_toggle
var back_button

var bus_index = AudioServer.get_bus_index("Master")

func _ready():
	var screen_size = get_viewport_rect().size
	set_background(screen_size)
	set_main_title(screen_size)
	set_audio_section(screen_size)
	set_mute_section(screen_size)
	set_drag_section(screen_size)
	set_back_button(screen_size)
	
	slider.connect("value_changed", _on_music_volume_changed)

func set_background(screen_size):
	var background = ColorRect.new()
	background.color = Color(173 / 255.0, 216 / 255.0, 230 / 255.0)
	background.size = screen_size
	add_child(background)

func set_main_title(screen_size):
	
	var main_title = Label.new()
	
	if Global.is_mobile:
		main_title.text = "Options"
		main_title.add_theme_font_size_override("font_size", 50)
		main_title.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		main_title.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		main_title.set_size(Vector2(screen_size.x * 0.5, screen_size.y * 0.1))
		var title_target = Vector2((screen_size.x - main_title.size.x) / 2, screen_size.y * 0.02)
		main_title.position = Vector2(title_target.x, title_target.y)
		add_child(main_title)
	else:
		main_title.text = "Options"
		main_title.add_theme_font_size_override("font_size", 50)
		main_title.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		main_title.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		main_title.set_size(Vector2(screen_size.x * 0.15, screen_size.x * 0.075))
		var title_target = Vector2((screen_size.x - main_title.size.x) / 2, screen_size.y * 0.02)
		main_title.position = Vector2(title_target.x, title_target.y)
		add_child(main_title)

func set_audio_section(screen_size):
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

func set_mute_section(screen_size):
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

func set_drag_section(screen_size):
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

func set_back_button(screen_size):
	
	back_button = TextureButton.new()
	back_button.texture_normal = load("res://Assets/buttons/confirm_btn_2x1.png")
	back_button.ignore_texture_size = true
	back_button.stretch_mode = TextureButton.STRETCH_SCALE
	add_child(back_button)
	back_button.connect("pressed", _on_back_pressed)

	if Global.is_mobile:
		back_button.size = Vector2(screen_size.y * 0.16, screen_size.y * 0.08)
		back_button.position = Vector2(
			(screen_size.x - back_button.size.x) / 2, screen_size.y * 0.8
		)
	else:
		back_button.size = Vector2(screen_size.x * 0.15, screen_size.y * 0.08)
		back_button.position = Vector2(
			(screen_size.x - back_button.size.x) / 2, screen_size.y * 0.9
		)

func _on_music_volume_changed(value):
	Global.volume_level = value
	var fixed_value = value / 1000
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(fixed_value)
	)

func _on_mute_toggled(button_pressed):
	Global.is_muted = button_pressed
	AudioServer.set_bus_mute(bus_index, button_pressed)

func _on_drag_toggled(button_pressed):
	Global.allow_dragging = button_pressed

func _on_back_pressed():
	queue_free()
