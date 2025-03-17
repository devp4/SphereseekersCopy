extends Node3D

var controls_menu_instance = null
var pause_menu_instance = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Show Controls menu on first launch
	if not Global.controls_shown:
		show_controls_menu()
		
	# Set up environment
	var environment = Environment.new()
	var bg_color = Color(0.68, 0.85, 0.9) 
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = bg_color
	
	var world = get_viewport().get_world_3d()
	world.environment = environment
	
	PlayerClass.set_current_level(1)
		
func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:  # Escape key
		if not controls_menu_instance:  # Don't allow pause while controls are showing
			if not Global.is_paused:
				pause_game()
			else:
				unpause_game()
				
func process(delta):
	if Global.is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		PlayerClass.current_level_time += delta
		$UI/StopwatchLabel.text = str(PlayerClass.current_level_time).pad_decimals(2)

func show_controls_menu():
	controls_menu_instance = preload("res://Scenes/Interface/ControlsMenu.tscn").instantiate()
	add_child(controls_menu_instance)
	get_tree().paused = true

func pause_game():
	if pause_menu_instance:
		return
	Global.is_paused = true
	pause_menu_instance = preload("res://Scenes/Interface/PauseMenu.tscn").instantiate()
	add_child(pause_menu_instance)
	pause_menu_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true

func unpause_game():
	Global.is_paused = false
	if pause_menu_instance:
		pause_menu_instance.queue_free()
		pause_menu_instance = null
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	
