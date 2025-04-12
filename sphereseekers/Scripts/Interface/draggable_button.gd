extends TextureButton

var action_callable: Callable = Callable()
var dragging := false
var drag_offset := Vector2()

func _ready():
	connect("button_down", Callable(self, "_on_button_down"))
	connect("button_up", Callable(self, "_on_button_up")) 
	connect("pressed", Callable(self, "_on_pressed"))

func _on_button_down():
	if action_callable.is_valid():
		action_callable.call("down")

func _on_button_up():
	if action_callable.is_valid():
		action_callable.call("up")

func _on_pressed():
	if action_callable.is_valid():
		action_callable.call()

func _gui_input(event):
	if event is InputEventScreenTouch and Global.allow_dragging:
		if event.pressed:
			dragging = true
			Global.dragging_button = true
			drag_offset = get_local_mouse_position()
		else:
			dragging = false
			Global.dragging_button = false
	elif event is InputEventScreenDrag and dragging:
		position = get_global_mouse_position() - drag_offset
		
	# Consume the input event to prevent it from propagating further
	if dragging and (event is InputEventScreenTouch or event is InputEventScreenDrag):
		get_viewport().set_input_as_handled()
