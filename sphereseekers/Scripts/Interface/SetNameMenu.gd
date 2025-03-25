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

	if Global.is_mobile:
		set_mobile_layout()
	else:
		set_desktop_layout()
			
func _on_mobile_input_focus() -> void:
	_show_mobile_keyboard()
	
func _on_mobile_input_unfocus() -> void:
	DisplayServer.virtual_keyboard_hide()
	
func _show_mobile_keyboard() -> void:
	DisplayServer.virtual_keyboard_show("")
	
	if OS.get_name() == "Web":
		_trigger_keyboard_js()

func _trigger_keyboard_js() -> void:
	# JavaScript method to force keyboard on mobile web
	if OS.get_name() == "Web":
		JavaScriptBridge.eval("""
		function showKeyboard() {
			// Try to focus on the input
			var input = document.querySelector('textarea');
			if (input) {
				input.focus();
				input.click();
			}
		}
		showKeyboard();
		""")

func _on_continue_pressed() -> void:
	var name = name_input.text.strip_edges()
		
	if name == "":
		error_label.text = "Please enter your name"
		error_label.modulate = Color(1, 0, 0, 0) # Start transparent
		error_label.visible = true

		var tween = create_tween()
		tween.tween_property(error_label, "modulate", Color.RED, 0.4)
		return

	error_label.visible = false
	var save_names: Array = LocalStorage.get_save_names()

	if name in save_names:
		show_override_dialog(name)
	else:
		save_names.append(name)
		LocalStorage.set_save_names(save_names)
		Global.is_paused = false
		get_tree().change_scene_to_file("res://Scenes/Interface/loading_screen.tscn")

func show_override_dialog(name: String) -> void:
	var dialog := ConfirmationDialog.new()
	dialog.dialog_text = "Save with this name already exists. Are you sure you want to override that save?"
	dialog.ok_button_text = "Override"
	dialog.cancel_button_text = "Exit"
	dialog.get_ok_button().modulate = Color.RED
	add_child(dialog)
	dialog.confirmed.connect(_on_override_confirmed.bind(name))
	dialog.popup_centered()

func _on_override_confirmed(_name: String) -> void:
	Global.is_paused = false
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
	title_label.text = "Set Name"
	title_label.set_size(Vector2(w * 0.75, h * 0.15))
	var title_target_pos = Vector2((w - title_label.size.x) / 2, h * 0.08)
	title_label.position = Vector2(title_target_pos.x, -title_label.size.y)
	animate_property(title_label, "position", title_target_pos, 1.0, Tween.TRANS_BOUNCE)

	title_label.add_theme_font_size_override("font_size", 48)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.visible = true

	# Input
	name_input.set_size(Vector2(w * 0.8, h * 0.08))
	var input_target_pos = Vector2((w - name_input.size.x) / 2, title_target_pos.y + title_label.size.y + h * 0.05)
	name_input.position = Vector2(-name_input.size.x, input_target_pos.y)
	animate_property(name_input, "position", input_target_pos, 0.6)
	name_input.editable = true
	name_input.visible = true

	# Continue Button
	continue_btn.set_size(Vector2(w * 0.5, h * 0.08))
	var button_target_pos = Vector2((w - continue_btn.size.x) / 2, input_target_pos.y + name_input.size.y + h * 0.05)
	continue_btn.position = Vector2(w + continue_btn.size.x, button_target_pos.y)
	animate_property(continue_btn, "position", button_target_pos, 0.6)

	continue_btn.text = "Continue"
	continue_btn.visible = true

	# Error Label
	error_label.set_size(Vector2(w * 0.8, h * 0.05))
	error_label.set_position(Vector2((w - error_label.size.x) / 2, button_target_pos.y + continue_btn.size.y + h * 0.05))
	error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	error_label.modulate = Color.RED
	error_label.visible = false

func animate_property(node: Node, property: String, target_value: Variant, duration: float, transition := Tween.TRANS_SINE, ease := Tween.EASE_OUT) -> void:
	var tween = create_tween()
	tween.tween_property(node, property, target_value, duration).set_trans(transition).set_ease(ease)
