extends RigidBody3D

@export var movement_speed: float = 20.0
@export var max_linear_velocity: float = 20.0
@export var max_angular_velocity: float = 350.0
@export var braking_factor: float = 0.05
@export var spin_boost_factor: float = 75.0
@export var jump_force: float = 100.0

@onready var camera_3d: Camera3D = $"../CameraRig/HRotation/VRotation/SpringArm3D/Camera3D"

var can_move: bool = true
var is_on_ground: bool = true

var label_tilt: Label
var label_accel: Label
var label_perm: Label

var calibrated = false
var initial_tilt = {"beta": 0, "gamma": 0}

func calibrate_tilt() -> void:
	if Global.is_mobile:
		initial_tilt = MobileMovementJs.get_tilt()

func get_calibrated_tilt():
	var new_tilt = MobileMovementJs.get_tilt()
	return {"beta": new_tilt["beta"] - initial_tilt["beta"], "gamma": new_tilt["gamma"] - initial_tilt["gamma"]}
		
func _ready():
	MobileMovementJs.create_listeners()
	create_debug_labels()
	create_permission_button()

	var mesh = $MeshInstance3D
	mesh.set_surface_override_material(0, Global.player_skin)

func create_permission_button() -> void:
	if not Global.is_mobile:
		return
		
	var canvas_layer = $CanvasLayer  # Use existing CanvasLayer if you already created one
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
	if MobileMovementJs.request_permission():
		await get_tree().create_timer(1.0).timeout  # Wait a bit for permission to be processed
		label_perm.text = "Permission: " + MobileMovementJs.get_permission_status()
	
	if not calibrated:
		calibrate_tilt()
		calibrated = true

func create_debug_labels() -> void:
	var canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)

	# Create the tilt label
	label_tilt = Label.new()
	label_tilt.text = "Tilt: Loading..."
	label_tilt.position = Vector2(20, 20)
	label_tilt.add_theme_color_override("font_color", Color(1, 1, 1)) # White text
	canvas_layer.add_child(label_tilt)
	
	label_perm = Label.new()
	label_perm.text = "Permission: " + MobileMovementJs.get_permission_status()
	label_perm.position = Vector2(20, 180)
	label_perm.add_theme_color_override("font_color", Color(1, 1, 1))
	canvas_layer.add_child(label_perm)

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
		var tilt = MobileMovementJs.get_tilt()
		var permission = MobileMovementJs.get_permission_status()
		
		label_perm.text = "Permission: " + permission
		
		if permission == "granted":
			if tilt:
				var calibrated_tilt = get_calibrated_tilt()
				var beta = calibrated_tilt["beta"]
				var gamma = calibrated_tilt["gamma"]
				
				# Adjust sensitivity based on testing
				var sens = 0.5

				if beta < -10: forward_input = -1 * sens
				elif beta > 7: forward_input = 1 * sens
				else: forward_input = 0 

				if gamma < -8: horizontal_input = -1 * sens
				elif gamma > 8: horizontal_input = 1 * sens
				else: horizontal_input = 0 
				
				label_tilt.text = "Tilt:\nBeta: " + str(round_place(beta)) + "\nGamma: " + str(round_place(gamma))
			else:
				label_tilt.text = "Tilt: Not Available"
			
		else:
			label_tilt.text = "Tilt: Need Permission"
			label_accel.text = "Accel: Need Permission"
	else:
		# Desktop keyboard fallback
		forward_input = Input.get_action_raw_strength("ui_down") - Input.get_action_raw_strength("ui_up")
		horizontal_input = Input.get_action_raw_strength("ui_right") - Input.get_action_raw_strength("ui_left")

	# Calculate movement direction
	var direction_forward = forward_input * cam_forward
	var direction_horizontal = horizontal_input * cam_horizontal

	# Jump
	if Input.is_action_pressed("ui_end") and is_on_ground:
		apply_impulse(Vector3(0, jump_force, 0))
		is_on_ground = false

	# Boost charging
	if Input.is_action_pressed("shift"):
		var horizontal_velocity = Vector3(linear_velocity.x, 0, linear_velocity.z)
		horizontal_velocity = horizontal_velocity.lerp(Vector3.ZERO, braking_factor)
		linear_velocity = Vector3(horizontal_velocity.x, linear_velocity.y, horizontal_velocity.z)

		angular_velocity = angular_velocity.lerp(Vector3.ZERO, braking_factor)
		physics_material_override.friction = 0.0

		if Input.is_action_just_pressed("spacebar"):
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
