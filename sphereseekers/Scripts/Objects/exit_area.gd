extends Area3D

var tween: Tween

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("disable_controls"):
			body.disable_controls()

		var platform_center = global_transform.origin
		var target_position = platform_center + Vector3(0, 2.0, 0)
		
		tween = get_tree().create_tween()
		tween.tween_property(body, "position", target_position, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_callback(_on_animation_complete)

func _on_animation_complete():
	print("Current Level: ", Global.level_to_play)
	PlayerClass.set_level_best_time()

	# Instead of immediately loading next level, show level complete popup
	show_level_complete_popup(_on_continue_pressed, _on_restart_pressed)

func _on_restart_pressed():
	remove_mobile_buttons()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	PlayerClass.save_player()
	Global.is_paused = false
	get_tree().change_scene_to_file("res://Scenes/Interface/loading_screen.tscn")
	
func _on_continue_pressed():
	remove_mobile_buttons()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_level_to_play()
	PlayerClass.save_player()
	Global.is_paused = false
	get_tree().change_scene_to_file("res://Scenes/Interface/loading_screen.tscn")

func remove_mobile_buttons():
	if Global.jump_btn and Global.jump_btn.is_inside_tree():
		Global.jump_btn.queue_free()
		Global.jump_btn = null

	if Global.stop_btn and Global.stop_btn.is_inside_tree():
		Global.stop_btn.queue_free()
		Global.stop_btn = null
	
	await get_tree().process_frame

func _level_to_play():
	match Global.level_to_play:
		Global.levels.TUTORIAL:
			Global.level_to_play = Global.levels.LEVEL1
		Global.levels.LEVEL1:
			Global.level_to_play = Global.levels.LEVEL2
		Global.levels.LEVEL2:
			Global.level_to_play = Global.levels.LEVEL3
		Global.levels.LEVEL3:
			Global.level_to_play = Global.levels.LEVEL4
		Global.levels.LEVEL4:
			Global.level_to_play = Global.levels.CREDITS

func show_level_complete_popup(confirm_action: Callable, restart_action: Callable):
	Global.is_paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var screen_size = Global.screen_size
	var popup = ConfirmationDialog.new()
	popup.title = "Results"
	popup.confirmed.connect(confirm_action)
	popup.add_theme_icon_override("close", Texture2D.new())
	add_child(popup)

	var label = popup.get_label()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	if Global.is_mobile:
		label.add_theme_font_size_override("font_size", 40)
	else:
		label.add_theme_font_size_override("font_size", 24)

	popup.get_ok_button().hide()
	popup.get_cancel_button().hide()

	var container = VBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	if Global.is_mobile:
		container.custom_minimum_size = Vector2(screen_size.x * 0.8, screen_size.y * 0.4)
	else:
		container.custom_minimum_size = Vector2(screen_size.x * 0.25, screen_size.y * 0.25)
	
	popup.add_child(container)

	var current_time_label = Label.new()
	var total_current_time = int(PlayerClass.current_level_time)
	var current_minutes = total_current_time / 60
	var current_seconds = total_current_time % 60
	current_time_label.text = "Your Time: %02d:%02d" % [current_minutes, current_seconds]
	current_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	current_time_label.add_theme_font_size_override("font_size", 30)
	container.add_child(current_time_label)

	var best_time = PlayerClass.get_current_level_best_time()
	if best_time == null:
		best_time = PlayerClass.current_level_time
	var total_best_time = int(best_time)
	var best_minutes = total_best_time / 60
	var best_seconds = total_best_time % 60
	var best_time_label = Label.new()
	best_time_label.text = "Best Time: %02d:%02d" % [best_minutes, best_seconds]
	best_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	best_time_label.add_theme_font_size_override("font_size", 30)
	container.add_child(best_time_label)

	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.add_child(spacer)

	var stars_container = HBoxContainer.new()
	stars_container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.add_child(stars_container)

	var star_count = calculate_stars(PlayerClass.current_level_time)

	var star_texture = TextureRect.new()

	match star_count:
		3:
			star_texture.texture = load("res://Assets/Interface/ui_images/three_stars.png")
		2:
			star_texture.texture = load("res://Assets/Interface/ui_images/two_stars.png")
		1:
			star_texture.texture = load("res://Assets/Interface/ui_images/one_star.png")

	star_texture.custom_minimum_size = Vector2(300, 100)
	stars_container.add_child(star_texture)

	var spacer2 = Control.new()
	spacer2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.add_child(spacer2)

	var button_box = HBoxContainer.new()
	button_box.alignment = BoxContainer.ALIGNMENT_CENTER
	container.add_child(button_box)

	var confirm_btn = TextureButton.new()
	confirm_btn.texture_normal = load("res://Assets/buttons/confirm_btn_2x1.png")
	confirm_btn.ignore_texture_size = true
	confirm_btn.stretch_mode = TextureButton.STRETCH_SCALE
	
	if Global.is_mobile:
		confirm_btn.custom_minimum_size = Vector2(screen_size.x * 0.3, screen_size.y * 0.1)
	else:
		confirm_btn.custom_minimum_size = Vector2(screen_size.x * 0.12, 50)
	
	confirm_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	confirm_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	confirm_btn.pressed.connect(confirm_action)
	button_box.add_child(confirm_btn)
	
	var restart_btn = TextureButton.new()
	restart_btn.texture_normal = load("res://Assets/buttons/restart_btn_2x1.png")
	restart_btn.ignore_texture_size = true
	restart_btn.stretch_mode = TextureButton.STRETCH_SCALE
	
	if Global.is_mobile:
		restart_btn.custom_minimum_size = Vector2(screen_size.x * 0.3, screen_size.y * 0.1)
	else:
		restart_btn.custom_minimum_size = Vector2(screen_size.x * 0.12, 50)
	
	restart_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	restart_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	restart_btn.pressed.connect(restart_action)
	button_box.add_child(restart_btn)

	var bottom_margin = Control.new()
	bottom_margin.custom_minimum_size = Vector2(0, 10)
	container.add_child(bottom_margin)

	popup.popup_centered()

func calculate_stars(current_time):
	var level_name = PlayerClass.convert_level_to_string()
	var thresholds = PlayerClass.star_times.get(level_name, [])

	if thresholds.size() == 3:
		if current_time <= thresholds[2]:
			return 3
		elif current_time <= thresholds[1]:
			return 2
		elif current_time <= thresholds[0]:
			return 1
	
	return 1
