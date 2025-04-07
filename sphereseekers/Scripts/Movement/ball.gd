extends RigidBody3D
@export var movement_speed : float = 20.0
@export var max_linear_velocity : float = 20.0
@export var max_angular_velocity : float = 350.0
@export var braking_factor : float = 0.05
@export var spin_boost_factor : float = 75.0
@export var jump_force : float = 100.0;

@onready var camera_3d: Camera3D = $"../CameraRig/HRotation/VRotation/SpringArm3D/Camera3D"
@onready var x_label: Label = $"../UI/x"
@onready var y_label: Label = $"../UI/y"
@onready var z_label: Label = $"../UI/z"
@onready var a_label: Label = $"../UI/a"

var can_move: bool = true
var is_on_ground: bool = true

var initial_accel := Vector3.ZERO
var calibrated = false
var initial_tilt = {"beta": 0, "gamma": 0}

func normalize_tilt(value: float) -> float:
	var deadzone = 0.1
	if abs(value) < deadzone:
		return 0.0
		
	return 1 if value > 0 else -1

func calibrate_tilt() -> void:
	if Global.is_mobile:
		initial_tilt = MobileMovementJs.get_tilt()
		z_label.text = "init beta " + str(round_place(initial_tilt["beta"]))
		a_label.text = "init gamma " + str(round_place(initial_tilt["gamma"]))
	
func get_calibrated_tilt():
	var new_tilt = MobileMovementJs.get_tilt()
	return {"beta": new_tilt["beta"] - initial_tilt["beta"], "gamma": new_tilt["gamma"] - initial_tilt["gamma"]}
	
func _ready():
	var mesh = $MeshInstance3D
	mesh.set_surface_override_material(0, Global.player_skin)
	if Global.is_mobile: 
		MobileMovementJs.create_listeners()

func round_place(num):
	return int(num * 1000) / float(1000)

func _integrate_forces(_state: PhysicsDirectBodyState3D) -> void:
	if not calibrated:
		calibrate_tilt()
		calibrated = true
		
	if not can_move:
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		return
	
	# Set speed limits
	linear_velocity.z = clamp(linear_velocity.z, -max_linear_velocity, max_linear_velocity)
	linear_velocity.x = clamp(linear_velocity.x, -max_linear_velocity, max_linear_velocity)
	angular_velocity.x = clamp(angular_velocity.x, -max_angular_velocity, max_angular_velocity)

	# Get camera direction
	var cam_forward = (camera_3d.global_transform.basis.z * Vector3(1, 0, 1)).normalized()
	var cam_horizontal = (camera_3d.global_transform.basis.x * Vector3(1, 0, 1)).normalized()

	var forward_input = 0.0
	var horizontal_input = 0.0
	# Use accelerometer on mobile
	if Global.is_mobile:
		var cal_tilt = get_calibrated_tilt()
		var cal_beta = cal_tilt["beta"]
		var cal_gamma = cal_tilt["gamma"]
		
		var tilt = MobileMovementJs.get_tilt()
		var beta = tilt["beta"]
		var gamma = tilt["gamma"]
		x_label.text = "beta: " + str(round_place(beta)) + " cal: " + str(round_place(cal_beta))
		y_label.text = " gamma: " + str(round_place(gamma)) + " cal: " + str(round_place(cal_gamma))
		
		var sens = 0.5
		
		if cal_beta < -10: forward_input = -1 * sens
		elif cal_beta > 7: forward_input = 1 * sens
		else: forward_input = 0 
		
		if cal_gamma < -8: horizontal_input = -1 * sens
		elif cal_gamma > 8: horizontal_input = 1 * sens
		else: horizontal_input = 0 
		

	else:
		# Use keyboard on desktop
		forward_input = Input.get_action_raw_strength("ui_down") - Input.get_action_raw_strength("ui_up")
		horizontal_input = Input.get_action_raw_strength("ui_right") - Input.get_action_raw_strength("ui_left")
		
	# Calculate movement direction
	var direction_forward = forward_input * cam_forward
	var direction_horizontal = horizontal_input * cam_horizontal
	
	if Input.is_action_pressed("ui_end") and is_on_ground:
		apply_impulse(Vector3(0, jump_force, 0))
		is_on_ground = false

	# Ball will not move around while shift is being held down...
	if (Input.is_action_pressed("shift")):
		# Apply braking force gradually (lerp to zero) while leaving gravity intact
		var horizontal_velocity = Vector3(linear_velocity.x, 0, linear_velocity.z)
		horizontal_velocity = horizontal_velocity.lerp(Vector3.ZERO, braking_factor)
		linear_velocity = Vector3(horizontal_velocity.x, linear_velocity.y, horizontal_velocity.z)
		
		# Apply braking to spinning visual as well
		angular_velocity = angular_velocity.lerp(Vector3.ZERO, braking_factor)
		
		# Reduce friction while charging to prevent creeping forward
		physics_material_override.friction = 0.0
		
		
		if (Input.is_action_just_pressed("spacebar")):
			#print("SHIFT + SPACEBAR PRESSED")
			#print("Rotation impulse direction matrix: ", direction_forward)
			#print("Angular velocity (magnitude): ", get_angular_velocity().length())
			#print("Angular velocity (vector): ", get_angular_velocity())
			apply_torque_impulse(-cam_horizontal * spin_boost_factor)
		return
			
	if (Input.is_action_just_released("shift")):
		physics_material_override.friction = 1.0  # Restore original friction
		var lil_jump_magnitude = 0.6 # Magnitude of lil jump after releasing charged boost
		var lil_jump_impulse = lil_jump_magnitude * Vector3.ONE
		
		var final_boost_vector = lil_jump_impulse + direction_forward # Set direction of boost
		
		var spin_speed = get_angular_velocity().length()
		apply_central_impulse(spin_speed * final_boost_vector) # Apply boost to marble
		
		#print("shift released!")
	
	#print("Forward Before force: ", direction_forward)
	#print("Horizonatal Before force: ", direction_horizontal)
	#print("==========================================")
	#print("Linear velocity (magnitude): ", get_linear_velocity().length())
	#print("Linear velocity (vector): ", get_linear_velocity())
	#print("==========================================")
	#print("Angular velocity (magnitude): ", get_angular_velocity().length())
	#print("Angular velocity (vector): ", get_angular_velocity())

	apply_central_force(direction_forward * movement_speed * get_physics_process_delta_time())
	apply_central_force(direction_horizontal * movement_speed * get_physics_process_delta_time())


func disable_controls():
	can_move = false
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

# Collision detection method
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy_balls"):
		reset_position()
	if body.is_in_group("killing_obstacle"):
		reset_position()
		
func _on_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if body.is_in_group("Ground"):
		is_on_ground = true

# Resets player position to (0, 5, -67.5)
func reset_position() -> void:
	set_inertia(Vector3.ZERO)
	linear_velocity = Vector3.ZERO # Stop ball
	angular_velocity = Vector3.ZERO
	var new_transform = global_transform
	new_transform.origin = Vector3(0, 5, -67.5) # Set position to (0, 5, -67.5)
	global_transform = new_transform
	is_on_ground = true
