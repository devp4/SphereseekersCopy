extends TextureRect
 
var label: Label
 
func _ready():
	texture = load("res://Assets/Interface/ui_images/set_name_in_4x1.png")
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if not Global.is_mobile:
		custom_minimum_size = Vector2(Global.screen_size.x * 0.1, Global.screen_size.x * 0.025)
	else:
		custom_minimum_size = Vector2(Global.screen_size.x * 0.25, Global.screen_size.x * 0.0625)
		

	# Create the label
	label = Label.new()
	if Global.is_mobile: label.add_theme_font_size_override("font_size", 32)
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
		
		var total_seconds = int(PlayerClass.current_level_time)
		var minutes = total_seconds / 60
		var seconds = total_seconds % 60
		
		label.text = str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)
