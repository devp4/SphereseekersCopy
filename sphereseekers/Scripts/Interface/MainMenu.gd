extends Control

# UI References
var bg_rect: ColorRect
var title_label: TextureRect
var continue_btn: TextureButton
var new_game_btn: TextureButton
var load_game_btn: TextureButton
var options_btn: TextureButton
var skins_btn: TextureButton
var credits_btn: TextureButton
var music_player: AudioStreamPlayer2D

const MOBILE_KEYWORDS = ["Android", "iPhone", "iPad", "iPod", "Windows Phone", "Mobile"]

func _ready() -> void:
	bg_rect = $background
	title_label = $title
	continue_btn = $continue_button
	new_game_btn = $new_game_button
	load_game_btn = $load_game_button
	options_btn = $options_button
	skins_btn = $skins_button
	credits_btn = $credits_button
	
	Global.screen_size = get_viewport_rect().size
	
	if not MusicPlayer.find_child("AudioStreamPlayer2D").is_playing():
		MusicPlayer.find_child("AudioStreamPlayer2D").play()
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index("Master"),
			linear_to_db(Global.volume_level/1000)
		)
	
	Global.is_mobile = is_running_on_mobile_browser()

	if Global.is_mobile:
		var targets = set_objects_for_mobile()
		await animate_mobile_buttons(targets)
	else:
		var targets = set_objects_for_desktop()
		animate_title(title_label)
		await animate_buttons_in(targets)
	
	
func _on_Continue_pressed() -> void:
	var recent_save = LocalStorage.get_recent_save()

	if recent_save == null:
		return

	PlayerClass.clear_player()
	PlayerClass.load_game(recent_save)
	Global.in_main_menu = false

	# Make sure that Cannons will shoot
	Global.stop_all_projectiles = false
	MusicPlayer.find_child("AudioStreamPlayer2D").stop()
	get_tree().change_scene_to_file("res://Scenes/Interface/loading_screen.tscn")

func _on_new_game_pressed() -> void:	
	get_tree().change_scene_to_file("res://Scenes/Interface/SetNameMenu.tscn")

func _on_load_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Interface/LoadGameMenu.tscn")

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Interface/options_menu.tscn")

func _on_skins_pressed() -> void:
	MusicPlayer.find_child("AudioStreamPlayer2D").stop()
	get_tree().change_scene_to_file("res://Scenes/Levels/display_room.tscn")

func _on_credits_pressed() -> void:
	MusicPlayer.find_child("AudioStreamPlayer2D").stop()
	get_tree().change_scene_to_file("res://Scenes/Interface/Credits.tscn")

func is_running_on_mobile_browser() -> bool:
	if not OS.has_feature("web"):
		return false
	var user_agent = JavaScriptBridge.eval("navigator.userAgent;")
	for keyword in MOBILE_KEYWORDS:
		if keyword in user_agent:
			return true
	return false

func set_objects_for_desktop() -> Array:
	var screen_size = get_viewport_rect().size
	var w = screen_size.x
	var h = screen_size.y

	bg_rect.set_size(screen_size)
	bg_rect.set_position(Vector2.ZERO)
	bg_rect.color = Color(173.0/255.0, 216.0/255.0, 230.0/255.0, 1.0)

	title_label.set_size(Vector2(500, 250))
	title_label.set_position(Vector2((w - title_label.size.x) / 2, h * 0.1))

	var button_width = w * 0.12
	var button_height = 50
	var spacing = w * 0.04
	var y_pos = h * 0.75

	var buttons = [
		continue_btn, new_game_btn, load_game_btn,
		options_btn, skins_btn, credits_btn
	]

	var button_targets = []

	for i in buttons.size():
		var btn = buttons[i]
		btn.set_size(Vector2(button_width, button_height))
		btn.position = Vector2(-button_width, y_pos)

		if i == 0:
			var overlay = ColorRect.new()
			overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			overlay.color = Color(0, 0, 0, 0.4)
			overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

			btn.add_child(overlay)
			var recent_save = LocalStorage.get_recent_save()
			if recent_save == null: 
				overlay.visible = true
				btn.disabled = true
			else: 
				overlay.visible = false
				btn.disabled = false
				
		var target = Vector2(spacing + i * (button_width + spacing), y_pos)
		button_targets.append({ "button": btn, "target": target })

	return button_targets

func set_objects_for_mobile() -> Array:
	var screen_size = get_viewport_rect().size
	var w = screen_size.x
	var h = screen_size.y

	bg_rect.set_size(screen_size)
	bg_rect.set_position(Vector2.ZERO)
	bg_rect.color = Color(173 / 255.0, 216 / 255.0, 230 / 255.0)

	title_label.set_size(Vector2(800, 400))
	var title_target = Vector2((w - title_label.size.x) / 2, h * 0.05)
	title_label.position = Vector2(title_target.x, -title_label.size.y)

	var title_tween = create_tween()
	title_tween.tween_property(title_label, "position", title_target, 1.0)\
		.set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_OUT)

	var button_width = w * 0.5
	var button_height = h * 0.08
	var spacing = h * 0.015
	var start_y = title_target.y + title_label.size.y + h * 0.04

	var buttons = [
		continue_btn, new_game_btn, load_game_btn,
		options_btn, skins_btn, credits_btn
	]
	
	var button_targets = []

	for i in buttons.size():
		var btn = buttons[i]
		btn.set_size(Vector2(button_width, button_height))
		
		if i == 0:
			var overlay = ColorRect.new()
			overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			overlay.color = Color(0, 0, 0, 0.4)
			overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

			btn.add_child(overlay)
			var recent_save = LocalStorage.get_recent_save()
			if recent_save == null: 
				overlay.visible = true
				btn.disabled = true
			else: 
				overlay.visible = false
				btn.disabled = false
				
		var target_x = (w - button_width) / 2
		var target_y = start_y + i * (button_height + spacing)
		btn.position = Vector2(target_x, h + button_height)

		button_targets.append({ "button": btn, "target": Vector2(target_x, target_y) })

	return button_targets

func animate_title(title: TextureRect) -> void:
	var final_pos = title.position
	title.position = Vector2(final_pos.x, -title.size.y)

	var tween = create_tween()
	tween.tween_property(title, "position", final_pos, 1.2)\
		.set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_OUT)

func animate_buttons_in(button_targets: Array) -> void:
	for entry in button_targets:
		var btn = entry["button"]
		var target = entry["target"]

		var tween = create_tween()
		tween.tween_property(btn, "position", target, 0.6)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)

		await get_tree().create_timer(0.1).timeout

func animate_mobile_buttons(button_targets: Array) -> void:
	for entry in button_targets:
		var btn = entry["button"]
		var target = entry["target"]

		var tween = create_tween()
		tween.tween_property(btn, "position", target, 0.5)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)

		await get_tree().create_timer(0.1).timeout
