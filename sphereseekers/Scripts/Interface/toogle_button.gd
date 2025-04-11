extends Control

signal toogled(is_on: bool)

@export var is_on: bool = false
@export var toggle_width: float = 100
@export var toggle_height: float = 50

func _ready():
	set_process(true)

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		var local_click_pos = event.position
		if Rect2(Vector2.ZERO, size).has_point(local_click_pos):
			is_on = not is_on
			queue_redraw()
			emit_signal("toogled", is_on)

func _process(_delta):
	# Always maintain the custom size
	custom_minimum_size = Vector2(toggle_width, toggle_height)

func _draw():
	var radius = toggle_height / 2.0
	var bg_color = Color(0.2, 0.8, 0.2) if is_on else Color(0.6, 0.6, 0.6)
	var circle_color = Color(1, 1, 1)

	# Create rounded background
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius

	draw_style_box(style, Rect2(Vector2.ZERO, size))

	# Draw moving circle
	var circle_x_pos = (size.x - radius) if is_on else radius
	draw_circle(Vector2(circle_x_pos, radius), radius * 0.8, circle_color)
