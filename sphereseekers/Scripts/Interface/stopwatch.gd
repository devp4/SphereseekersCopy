extends TextureRect
 
var label: Label
 
func _ready():
	texture = load("res://Assets/Interface/ui_images/set_name_in_4x1.png")
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	custom_minimum_size = Vector2(120, 30)

	# Create the label
	label = Label.new()
	label.text = "00:00"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	label.size_flags_vertical = SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	label.anchor_left = 0
	label.anchor_right = 1
	label.anchor_top = 0
	label.anchor_bottom = 1
	label.offset_left = 0
	label.offset_right = 0
	label.offset_top = 0
	label.offset_bottom = 0

	add_child(label)
 
func _process(delta):
	if !Global.is_paused:
		PlayerClass.current_level_time += delta
		label.text = str(PlayerClass.current_level_time).pad_decimals(2)
