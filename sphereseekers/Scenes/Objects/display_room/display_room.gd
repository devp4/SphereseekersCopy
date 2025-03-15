extends Node3D

@onready var prev_button = $CanvasLayer/Control/prev
@onready var select_button = $CanvasLayer/Control/select
@onready var next_button = $CanvasLayer/Control/next

@onready var marble = $display_room/marble

@export var skins: Array[StandardMaterial3D]

var current_skin_index: int = 0

func _ready():
	position_buttons()
	update_skin()
	
func _process(delta: float) -> void:
	marble.rotate_y(deg_to_rad(10 * delta))
	
func position_buttons():
	var screen_size = get_viewport().size
	var button_width = 50
	var button_spacing = 50
	var total_width = (button_width * 3) + (button_spacing * 2)
	
	var start_x = (screen_size.x - total_width) / 2
	var button_y = screen_size.y - select_button.size.y - 20
	
	prev_button.position = Vector2(start_x, button_y)
	select_button.position = Vector2(start_x + button_width + button_spacing, button_y)
	next_button.position = Vector2(start_x + (button_width + button_spacing) * 2, button_y)

func next_skin():
	current_skin_index = (current_skin_index + 1) % skins.size()
	update_skin()
	
func prev_skin():
	current_skin_index = (current_skin_index - 1 + skins.size()) % skins.size()
	update_skin()
	
func select_skin():
	Global.player_skin = skins[current_skin_index]
	get_tree().change_scene_to_file("res://Scenes/Interface/MainMenu.tscn")
	#print(Global.player_skin)
	
func update_skin():
	if skins.is_empty():
		return
	marble.set_surface_override_material(0, skins[current_skin_index])
