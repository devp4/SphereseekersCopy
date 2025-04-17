extends Node3D

@onready var skin_container := $CanvasLayer/Control/skin_button_container
@onready var confirm_button := $CanvasLayer/Control/confirm_btn
@onready var skin_name_label := $CanvasLayer/Control/skin_name_label
@onready var marble := $display_room/marble
@onready var camera := $Camera3D

@export var skins: Array[StandardMaterial3D]
@export var skin_previews: Array[Texture2D]
@export var skin_names: Array[String]

var current_skin_index := 0
var skin_buttons: Array[TextureButton] = []

var touch_start_position: Vector2
var swipe_threshold := 100 #Minimum pixels to consider a swipe
var button_width : float
var button_height: float

func _ready():
	
	var screen_size = get_viewport().size
	
	if not Global.is_mobile:
		generate_skin_buttons()
		update_button_highlight()
		skin_name_label.add_theme_font_size_override("font_size", 24)
		button_width = screen_size.x * 0.12
		button_height = screen_size.y * 50
	else:
		set_camera_for_mobile()
		skin_name_label.add_theme_font_size_override("font_size", 44)
		button_width = screen_size.x * 0.5
		button_height = screen_size.y * 0.08
		
	position_selector_ui()
	update_skin()
	set_label()
	set_label_background()
	position_confirm_button()

func _process(delta: float) -> void:
	marble.rotate_y(deg_to_rad(10 * delta))

func generate_skin_buttons():
	var fixed_size = Vector2(64, 64)

	for i in skins.size():
		var btn = TextureButton.new()
		btn.texture_normal = skin_previews[i]
		
		btn.ignore_texture_size = true
		btn.custom_minimum_size = fixed_size
		btn.set_size(fixed_size)

		btn.size_flags_horizontal = Control.SIZE_FILL
		btn.size_flags_vertical = Control.SIZE_FILL
		btn.stretch_mode = TextureButton.STRETCH_SCALE
		btn.clip_contents = true

		btn.connect("pressed", Callable(self, "_on_skin_button_pressed").bind(i))
		skin_container.add_child(btn)
		skin_buttons.append(btn)

func _on_skin_button_pressed(index: int):
	current_skin_index = index
	update_skin()
	update_button_highlight()

func update_skin():
	if skins.is_empty():
		return
	
	marble.set_surface_override_material(0, skins[current_skin_index])
	
	if current_skin_index < skin_names.size():
		skin_name_label.text = skin_names[current_skin_index]
		await get_tree().process_frame
		skin_name_label.size = skin_name_label.get_minimum_size()
		center_skin_name_label()

func update_button_highlight():
	for i in range(skin_buttons.size()):
		if i == current_skin_index:
			skin_buttons[i].modulate = Color(1, 1, 1, 1)
		else:
			skin_buttons[i].modulate = Color(0.7, 0.7, 0.7, 1)

func position_selector_ui():
	var screen_size = get_viewport().size

	await get_tree().process_frame

	var container_size = skin_container.get_combined_minimum_size()
	skin_container.position = Vector2(
		(screen_size.x - container_size.x) / 2,
		screen_size.y - container_size.y - screen_size.y * 0.05  # 5% from bottom
	)

func set_label():
	var screen_size = get_viewport().size
	
	var label_size = skin_name_label.get_size()
	skin_name_label.anchor_left = 0
	skin_name_label.anchor_right = 0
	skin_name_label.anchor_top = 0
	skin_name_label.anchor_bottom = 0

	skin_name_label.position = Vector2(
		(screen_size.x - label_size.x) / 2,
		screen_size.y * 0.1
	)

func center_skin_name_label():
	var screen_width = get_viewport().size.x
	await get_tree().process_frame
	var label_width = skin_name_label.get_minimum_size().x
	skin_name_label.position.x = (screen_width - label_width) / 2

func set_label_background():
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(0, 0, 0, 0.5)

	stylebox.set_corner_radius(0, 8)
	stylebox.set_corner_radius(1, 8)
	stylebox.set_corner_radius(2, 8)
	stylebox.set_corner_radius(3, 8)

	stylebox.content_margin_left = 10
	stylebox.content_margin_right = 10
	stylebox.content_margin_top = 6
	stylebox.content_margin_bottom = 6

	skin_name_label.add_theme_stylebox_override("normal", stylebox)
	
func _on_select_button_pressed():
	Global.player_skin = skins[current_skin_index]
	MusicPlayer.find_child("AudioStreamPlayer2D").play()
	get_tree().change_scene_to_file("res://Scenes/Interface/MainMenu.tscn")

func set_camera_for_mobile():
	var wall = $display_room/wall
	var floor = $display_room/floor
	var base = $display_room/base
	var camera = $Camera3D
	
	wall.visible = false
	floor.visible = false
	base.visible = false
	camera.position = Vector3(5,7,5)
	camera.rotation_degrees = Vector3(-10,45,0)
	
func _unhandled_input(event: InputEvent) -> void:
	if Global.is_mobile:
		if event is InputEventScreenTouch:
			if event.pressed:
				touch_start_position = event.position
			elif not event.pressed:
				var touch_end_position = event.position
				var swipe_vector = touch_end_position - touch_start_position
				if abs(swipe_vector.x) > swipe_threshold:
					if swipe_vector.x > 0:
						select_previous_skin()
					else:
						select_next_skin()

func select_next_skin():
	current_skin_index = (current_skin_index + 1) % skins.size()
	update_skin()
	center_skin_name_label()

func select_previous_skin():
	current_skin_index = (current_skin_index - 1 + skins.size()) % skins.size()
	update_skin()
	center_skin_name_label()

func position_confirm_button():
	var screen_size = get_viewport().size
	
	# Set button size
	confirm_button.size = Vector2(screen_size.x * 0.3, screen_size.y * 0.08)
	var button_size = confirm_button.size
	
	# Reset anchors
	confirm_button.anchor_left = 0
	confirm_button.anchor_top = 0
	confirm_button.anchor_right = 0
	confirm_button.anchor_bottom = 0

	if Global.is_mobile:
		confirm_button.size = Vector2(200, 100)
		button_size = confirm_button.size
		confirm_button.position = Vector2(
			(screen_size.x - button_size.x) / 2,
			screen_size.y - button_size.y - screen_size.y * 0.25
		)
	else:
		# For desktop: Keep original top-right positioning
		var padding_x = screen_size.x * 0.05
		var padding_y = screen_size.y * 0.05
		confirm_button.size = Vector2(screen_size.x * 0.1, (screen_size.x * 0.1)/2)
		confirm_button.position = Vector2(
			screen_size.x - confirm_button.size.x - padding_x,
			padding_y
		)
