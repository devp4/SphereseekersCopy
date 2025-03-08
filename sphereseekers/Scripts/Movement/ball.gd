extends RigidBody3D
@export var movement_speed : float = 20.0
@export var max_linear_velocity : float = 20.0
@export var max_angular_velocity : float = 350.0
@export var braking_factor : float = 0.05
@export var spin_boost_factor : float = 75.0
@export var jump_force : float = 100.0;

@onready var camera_3d: Camera3D = $"../CameraRig/HRotation/VRotation/SpringArm3D/Camera3D"

var can_move: bool = true
var is_on_ground: bool = true

func _integrate_forces(_state: PhysicsDirectBodyState3D) -> void:
	
	if not can_move:
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		return
		
	# Set speed limits for speed and rotation speed of marble
	linear_velocity.z = clamp(linear_velocity.z, -max_linear_velocity, max_linear_velocity)
	linear_velocity.x = clamp(linear_velocity.x, -max_linear_velocity, max_linear_velocity)
	
	angular_velocity.x = clamp(angular_velocity.x, -max_angular_velocity, max_angular_velocity)
	
	# Get inputs from user to calculate intended direction
	var forward_input = Input.get_action_raw_strength("ui_down") - Input.get_action_raw_strength("ui_up")
	var horizontal_input = Input.get_action_raw_strength("ui_right") - Input.get_action_raw_strength("ui_left")
	
	# Get position (a/k/a "transform") of camera
	var _camera_tranform = camera_3d.get_camera_transform()
	
	# Cancel out y-component to keep movement horizontal
	var cam_forward = (camera_3d.global_transform.basis.z * Vector3(1, 0, 1)).normalized()
	var cam_horizontal = (camera_3d.global_transform.basis.x * Vector3(1, 0, 1)).normalized()
	
	# Calculate forward/backward direction relative to camera position
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
		
func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
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
