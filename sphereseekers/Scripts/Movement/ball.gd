extends RigidBody3D

@export var movement_speed: float = 20.0
@export var max_linear_velocity: float = 20.0
@export var max_angular_velocity: float = 350.0
@export var braking_factor: float = 0.05
@export var spin_boost_factor: float = 75.0
@export var jump_force: float = 100.0

@onready var camera_3d: Camera3D = $"../CameraRig/HRotation/VRotation/SpringArm3D/Camera3D"
@onready var canvas_layer: CanvasLayer

var can_move: bool = true
var is_on_ground: bool = true
var buttons_created = false

func _ready():
	
	if Global.is_mobile:
		Accelerometer.create_accelerometer()
		create_permission_button()
		if Global.controls_shown:
			create_action_buttons()
	
	var mesh = $MeshInstance3D
	mesh.set_surface_override_material(0, Global.player_skin)

func _process(delta):
	if Global.controls_shown and not buttons_created:
		create_action_buttons()
		buttons_created = true

func create_permission_button() -> void:
	if not Global.is_mobile:
		return
		
	if not canvas_layer:
		canvas_layer = CanvasLayer.new()
		add_child(canvas_layer)
	
	var btn = Button.new()
	btn.text = "Enable Motion Controls"
	btn.position = Vector2(20, 260)
	btn.size = Vector2(250, 60)
	btn.connect("pressed", Callable(self, "_on_permission_button_pressed"))
	canvas_layer.add_child(btn)

func _on_permission_button_pressed() -> void:
	if Accelerometer.request_permission():
		await get_tree().create_timer(1.0).timeout  # Wait a bit for permission to be processed

func round_place(num):
	return int(num * 1000) / float(1000)

func _integrate_forces(_state: PhysicsDirectBodyState3D) -> void:
	if not can_move:
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		return

	# Limit speed
	linear_velocity.z = clamp(linear_velocity.z, -max_linear_velocity, max_linear_velocity)
	linear_velocity.x = clamp(linear_velocity.x, -max_linear_velocity, max_linear_velocity)
	angular_velocity.x = clamp(angular_velocity.x, -max_angular_velocity, max_angular_velocity)

	# Get camera direction
	var cam_forward = (camera_3d.global_transform.basis.z * Vector3(1, 0, 1)).normalized()
	var cam_horizontal = (camera_3d.global_transform.basis.x * Vector3(1, 0, 1)).normalized()

	var forward_input = 0.0
	var horizontal_input = 0.0

	if Global.is_mobile:
		var tilt = Accelerometer.get_tilt()
		var accel = Accelerometer.get_acceleration()
		var permission = Accelerometer.get_permission_status()
		
		if permission == "granted":
			if tilt:
				var beta = tilt["beta"]
				var gamma = tilt["gamma"]
				
				# Adjust sensitivity based on testing
				var sensitivity = 0.1  # Increased sensitivity
				
				# iOS might need different handling compared to Android
				forward_input = clamp(-beta * sensitivity, -1.0, 1.0) 
				horizontal_input = clamp(gamma * sensitivity, -1.0, 1.0)
	else:
		# Desktop keyboard fallback
		forward_input = Input.get_action_raw_strength("ui_down") - Input.get_action_raw_strength("ui_up")
		horizontal_input = Input.get_action_raw_strength("ui_right") - Input.get_action_raw_strength("ui_left")

	# Calculate movement direction
	var direction_forward = forward_input * cam_forward
	var direction_horizontal = horizontal_input * cam_horizontal

	# Jump
	if not Global.is_mobile and Input.is_action_pressed("ui_end"):
		make_jump()

	var stop_button_pressed = false
	if Global.is_mobile and canvas_layer and canvas_layer.has_node("StopButton"):
		stop_button_pressed = canvas_layer.get_node("StopButton").is_pressed()
	
	# Boost charging
	if Input.is_action_pressed("shift") or stop_button_pressed:
		var horizontal_velocity = Vector3(linear_velocity.x, 0, linear_velocity.z)
		horizontal_velocity = horizontal_velocity.lerp(Vector3.ZERO, braking_factor)
		linear_velocity = Vector3(horizontal_velocity.x, linear_velocity.y, horizontal_velocity.z)

		angular_velocity = angular_velocity.lerp(Vector3.ZERO, braking_factor)
		physics_material_override.friction = 0.0

		if not Global.is_mobile and Input.is_action_just_pressed("spacebar"):
			apply_torque_impulse(-cam_horizontal * spin_boost_factor)
		return

	if Input.is_action_just_released("shift"):
		physics_material_override.friction = 1.0
		var lil_jump_magnitude = 0.6
		var lil_jump_impulse = lil_jump_magnitude * Vector3.ONE
		var final_boost_vector = lil_jump_impulse + direction_forward
		var spin_speed = get_angular_velocity().length()
		apply_central_impulse(spin_speed * final_boost_vector)

	# Apply forces
	apply_central_force(direction_forward * movement_speed * get_physics_process_delta_time())
	apply_central_force(direction_horizontal * movement_speed * get_physics_process_delta_time())

func disable_controls():
	can_move = false
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy_balls") or body.is_in_group("killing_obstacle"):
		reset_position()

func _on_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if body.is_in_group("Ground"):
		is_on_ground = true

func reset_position() -> void:
	set_inertia(Vector3.ZERO)
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	var new_transform = global_transform
	new_transform.origin = Vector3(0, 5, -67.5)
	global_transform = new_transform
	is_on_ground = true

func create_action_buttons():
	if not canvas_layer:
		canvas_layer = CanvasLayer.new()
		add_child(canvas_layer)
	
	var screen_size = get_viewport().get_visible_rect().size
	
	var jump_btn = preload("res://Scripts/Interface/draggable_button.gd").new()
	jump_btn.name = "JumpButton"
	jump_btn.position = Vector2(screen_size.x * 0.75, screen_size.y * 0.75)
	jump_btn.ignore_texture_size = true
	jump_btn.stretch_mode = TextureButton.STRETCH_SCALE
	jump_btn.size = Vector2(screen_size.x * 0.15, screen_size.x * 0.15)
	jump_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	jump_btn.texture_normal = load("res://Assets/buttons/jump_button.png")
	jump_btn.action_callable = Callable(self, "make_jump")
	canvas_layer.add_child(jump_btn)

	var stop_btn = preload("res://Scripts/Interface/draggable_button.gd").new()
	stop_btn.name = "StopButton"
	stop_btn.position = Vector2(screen_size.x * 0.15, screen_size.y * 0.75)
	stop_btn.ignore_texture_size = true
	stop_btn.stretch_mode = TextureButton.STRETCH_SCALE
	stop_btn.size = Vector2(screen_size.x * 0.15, screen_size.x * 0.15)
	stop_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	stop_btn.texture_normal = load("res://Assets/buttons/stop_button.png") 
	stop_btn.action_callable = Callable(self, "_on_stop_button_event")
	canvas_layer.add_child(stop_btn)

func _on_stop_button_event(event_type = ""):
	if event_type == "down":
		# This is equivalent to pressing shift
		var horizontal_velocity = Vector3(linear_velocity.x, 0, linear_velocity.z)
		horizontal_velocity = horizontal_velocity.lerp(Vector3.ZERO, braking_factor)
		linear_velocity = Vector3(horizontal_velocity.x, linear_velocity.y, horizontal_velocity.z)

		angular_velocity = angular_velocity.lerp(Vector3.ZERO, braking_factor)
		physics_material_override.friction = 0.0
	elif event_type == "up":
		# This is equivalent to releasing shift
		physics_material_override.friction = 1.0
		var lil_jump_magnitude = 0.6
		var lil_jump_impulse = lil_jump_magnitude * Vector3.ONE
		var final_boost_vector = lil_jump_impulse + (camera_3d.global_transform.basis.z * Vector3(1, 0, 1)).normalized()
		var spin_speed = get_angular_velocity().length()
		apply_central_impulse(spin_speed * final_boost_vector)
	else:
		pass

func make_jump(event_type = ""):
	if event_type == "down" and is_on_ground:
		# Regular jump functionality
		apply_impulse(Vector3(0, jump_force, 0))
		is_on_ground = false
	elif is_on_ground:
		# For regular press without event_type
		apply_impulse(Vector3(0, jump_force, 0))
		is_on_ground = false
	
	# Check if stop button is being held (to implement the spin boost)
	if canvas_layer and canvas_layer.has_node("StopButton") and canvas_layer.get_node("StopButton").is_pressed():
		# This is equivalent to pressing space while shift is held
		var cam_horizontal = (camera_3d.global_transform.basis.x * Vector3(1, 0, 1)).normalized()
		apply_torque_impulse(-cam_horizontal * spin_boost_factor)
