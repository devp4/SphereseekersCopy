extends Control

var title_label: TextureRect
var error_label: Label
var continue_btn: TextureButton
var bg_rect: ColorRect
var name_input: LineEdit

func _ready() -> void:
	title_label = $title
	name_input = $name_input
	continue_btn = $continue
	error_label = $error
	bg_rect = $background

	if Global.is_mobile:
		name_input.focus_entered.connect(_on_mobile_input_focus)
		name_input.focus_exited.connect(_on_mobile_input_unfocus)
		bg_rect.gui_input.connect(_on_background_touch)
		
		if OS.get_name() == "Web":
			_setup_prevent_zoom()

	if Global.is_mobile:
		set_mobile_layout()
	else:
		set_desktop_layout()
		
func _setup_prevent_zoom():
	JavaScriptBridge.eval("""
	(function() {
		// Check if we've already setup our handlers to avoid duplicating them
		if (!window.zoomPreventionSetup) {
			// Create or update viewport meta tag
			var viewportMeta = document.querySelector('meta[name=viewport]');
			if (!viewportMeta) {
				viewportMeta = document.createElement('meta');
				viewportMeta.name = 'viewport';
				document.head.appendChild(viewportMeta);
			}
			
			// Add anti-zoom styles if not already added
			if (!document.getElementById('anti-zoom-styles')) {
				var style = document.createElement('style');
				style.id = 'anti-zoom-styles';
				style.textContent = `
					input, textarea {
						font-size: 16px !important; /* Prevent iOS zoom */
						max-height: 999999px; /* Prevent Android zoom */
					}
				`;
				document.head.appendChild(style);
			}
			
			// Prevent double-tap zoom
			document.addEventListener('touchstart', function(event) {
				if (event.touches.length > 1) {
					event.preventDefault();
				}
			}, { passive: false });
			
			// Mark that we've set up our handlers
			window.zoomPreventionSetup = true;
		}
		
		// Always refresh the viewport settings - this is crucial
		var viewportMeta = document.querySelector('meta[name=viewport]');
		viewportMeta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
		
		console.log('Zoom prevention refreshed');
	})();
	""")	
	
func _on_mobile_input_focus() -> void:
	if OS.get_name() == "Web":
		_setup_prevent_zoom()
		_trigger_keyboard_js()
	
func _on_mobile_input_unfocus() -> void:
	DisplayServer.virtual_keyboard_hide()
	
#func _show_mobile_keyboard() -> void:
	#DisplayServer.virtual_keyboard_show("")
	#
	#if OS.get_name() == "Web":
		#_trigger_keyboard_js()

func _trigger_keyboard_js() -> void:
	if OS.get_name() == "Web":
		JavaScriptBridge.eval("""
			(function() {
				var input = document.querySelector('textarea');
				if (input) {
					// Clear any existing text selection first
					if (document.getSelection) {
						document.getSelection().removeAllRanges();
					}
					
					// Use a slight delay to allow anti-zoom measures to apply
					setTimeout(function() {
						// Make sure input is actually visible and in the viewport
						input.scrollIntoView(false);
						
						// Focus the input
						input.focus();
						
						// Position cursor at end
						var len = input.value.length;
						try {
							input.setSelectionRange(len, len);
						} catch (e) {
							console.log('Error setting selection range:', e);
						}
						
						// Added this to ensure text input works
						input.setAttribute('inputmode', 'text');
						input.click();
					}, 50);
				}
			})();
		""")

func _on_background_touch(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_force_unfocus()
	
func _force_unfocus():
	name_input.release_focus()
	
	if OS.get_name() == "Web":
		JavaScriptBridge.eval("""
			(function() {
				if(document.activeElement) {
					document.activeElement.blur();
				}
			})();
		""")
		
	DisplayServer.virtual_keyboard_hide()
	
func start_game():
	Global.is_paused = false
	Global.in_main_menu = false
	MusicPlayer.find_child("AudioStreamPlayer2D").stop()
	
	# New game is going to played, set the level to play to TUTORIAL
	Global.level_to_play = Global.levels.TUTORIAL
	
	# Make sure that Cannons will shoot
	Global.stop_all_projectiles = false

func _on_continue_pressed():
	_force_unfocus()
	
	var trimmed_text = name_input.text.strip_edges()
	
	if trimmed_text == "":
		error_label.text = "Please enter your name"
		error_label.modulate = Color(1, 0, 0)
		error_label.visible = true
		return

	error_label.visible = false
	var save_names: Array = LocalStorage.get_save_names()

	if trimmed_text in save_names:
		show_override_dialog(trimmed_text)
	else:
		save_names.append(trimmed_text)
		LocalStorage.set_save_names(save_names)
		
		PlayerClass.clear_player()
		Global.level_to_play = Global.levels.TUTORIAL
		PlayerClass.playerName = trimmed_text
		PlayerClass.save_player()
		LocalStorage.set_recent_save(PlayerClass.playerName)
		
		start_game()
		
		get_tree().change_scene_to_file("res://Scenes/Levels/Tutorial.tscn")

func show_override_dialog(name: String) -> void:
	var dialog := ConfirmationDialog.new()
	dialog.dialog_text = "Save with this name already exists. Are you sure you want to override that save?"
	dialog.ok_button_text = "Override"
	dialog.cancel_button_text = "Exit"
	dialog.get_ok_button().modulate = Color.RED
	add_child(dialog)
	dialog.confirmed.connect(_on_override_pressed.bind(name))
	dialog.popup_centered()

func _on_override_pressed(_save_name):
	PlayerClass.delete_player(_save_name)
	PlayerClass.clear_player()
	Global.level_to_play = Global.levels.TUTORIAL
	PlayerClass.playerName = _save_name
	PlayerClass.save_player()
	LocalStorage.set_recent_save(PlayerClass.playerName)
	start_game()
	get_tree().change_scene_to_file("res://Scenes/Levels/Tutorial.tscn")

func set_desktop_layout() -> void:
	
	var size = get_viewport_rect().size
	var w = size.x
	var h = size.y

	bg_rect.set_size(size)
	bg_rect.set_position(Vector2.ZERO)
	bg_rect.color = Color(173 / 255.0, 216 / 255.0, 230 / 255.0)

	# Title
	title_label.set_size(Vector2(400, 200))
	var title_target_pos = Vector2((w - title_label.size.x) / 2, h * 0.08)
	title_label.position = Vector2(title_target_pos.x, -title_label.size.y)  # start above
	animate_property(title_label, "position", title_target_pos, 1.0, Tween.TRANS_BOUNCE)

	# Input
	name_input.set_size(Vector2(w * 0.75, h * 0.08))
	var input_target_pos = Vector2((w - name_input.size.x) / 2, title_target_pos.y + title_label.size.y + h * 0.2)
	name_input.position = Vector2(-name_input.size.x, input_target_pos.y)
	animate_property(name_input, "position", input_target_pos, 0.6)

	name_input.placeholder_text = "Enter your name"
	name_input.visible = true

	# Continue Button
	continue_btn.set_size(Vector2(200, 100))
	var button_target_pos = Vector2((w - continue_btn.size.x) / 2, input_target_pos.y + name_input.size.y + h * 0.1)
	continue_btn.position = Vector2(w + continue_btn.size.x, button_target_pos.y)
	animate_property(continue_btn, "position", button_target_pos, 0.6, Tween.TRANS_SINE, Tween.EASE_OUT)

	# Error Label
	error_label.set_size(Vector2(100, 50))
	error_label.set_position(Vector2((w - error_label.size.x) / 2, button_target_pos.y + continue_btn.size.y + h * 0.1))
	error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	error_label.modulate = Color.RED
	error_label.visible = false

func set_mobile_layout() -> void:
	
	var size = get_viewport_rect().size
	var w = size.x
	var h = size.y

	bg_rect.set_size(size)
	bg_rect.set_position(Vector2.ZERO)
	bg_rect.color = Color(173 / 255.0, 216 / 255.0, 230 / 255.0)

	# Title
	title_label.set_size(Vector2(h * 0.4, h * 0.2))
	var title_target_pos = Vector2((w - title_label.size.x) / 2, h * 0.15)
	title_label.position = Vector2(title_target_pos.x, -title_label.size.y)
	animate_property(title_label, "position", title_target_pos, 1.0, Tween.TRANS_BOUNCE)

	title_label.add_theme_font_size_override("font_size", 48)
	title_label.visible = true

	# Input
	name_input.set_size(Vector2(w * 0.8, w * 0.2))
	var input_target_pos = Vector2((w - name_input.size.x) / 2, title_target_pos.y + title_label.size.y + h * 0.05)
	name_input.position = Vector2(-name_input.size.x, input_target_pos.y)
	name_input.add_theme_font_size_override("font_size", 40)
	animate_property(name_input, "position", input_target_pos, 0.6)
	name_input.editable = true
	name_input.visible = true

	# Continue Button
	continue_btn.set_size(Vector2(h * 0.2, h * 0.1))
	var button_target_pos = Vector2((w - continue_btn.size.x) / 2, input_target_pos.y + name_input.size.y + h * 0.15)
	continue_btn.position = Vector2(w + continue_btn.size.x, button_target_pos.y)
	animate_property(continue_btn, "position", button_target_pos, 0.6)

	continue_btn.visible = true

	# Error Label
	error_label.set_size(Vector2(w * 0.8, h * 0.05))
	error_label.set_position(Vector2((w - error_label.size.x) / 2, button_target_pos.y + continue_btn.size.y + h * 0.15))
	error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	error_label.modulate = Color.RED
	error_label.visible = false
	error_label.add_theme_font_size_override("font_size", 36)

func animate_property(node: Node, property: String, target_value: Variant, duration: float, transition := Tween.TRANS_SINE, ease := Tween.EASE_OUT) -> void:
	var tween = create_tween()
	tween.tween_property(node, property, target_value, duration).set_trans(transition).set_ease(ease)
