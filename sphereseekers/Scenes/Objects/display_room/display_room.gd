extends Node3D

@onready var skin_container := $CanvasLayer/Control/skin_button_container
@onready var confirm_button := $CanvasLayer/Control/confirm_btn
@onready var skin_name_label := $CanvasLayer/Control/skin_name_label
@onready var marble := $display_room/marble

@export var skins: Array[StandardMaterial3D]
@export var skin_previews: Array[Texture2D]
@export var skin_names: Array[String]

var current_skin_index := 0
var skin_buttons: Array[TextureButton] = []

func _ready():
	generate_skin_buttons()
	update_skin()
	update_button_highlight()
	position_selector_ui()
	skin_name_label.add_theme_font_size_override("font_size", 24)
	set_label_background()

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

	confirm_button.size = Vector2(100,50)
	var button_size = confirm_button.size
	confirm_button.anchor_left = 0
	confirm_button.anchor_top = 0
	confirm_button.anchor_right = 0
	confirm_button.anchor_bottom = 0

	var padding_x = screen_size.x * 0.05
	var padding_y = screen_size.y * 0.05

	confirm_button.position = Vector2(
		screen_size.x - button_size.x - padding_x,
		padding_y
	)
	
	var label_size = skin_name_label.get_size()
	skin_name_label.anchor_left = 0
	skin_name_label.anchor_right = 0
	skin_name_label.anchor_top = 0
	skin_name_label.anchor_bottom = 0

	skin_name_label.position = Vector2(
		(screen_size.x - label_size.x) / 2,
		screen_size.y * 0.05
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
	print(skins[current_skin_index])
	get_tree().change_scene_to_file("res://Scenes/Interface/MainMenu.tscn")
