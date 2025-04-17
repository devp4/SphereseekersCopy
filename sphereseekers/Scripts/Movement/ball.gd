extends RigidBody3D

@export var movement_speed: float = 20.0
@export var max_linear_velocity: float = 20.0
@export var max_angular_velocity: float = 350.0
@export var braking_factor: float = 0.05
@export var spin_boost_factor: float = 75.0
@export var jump_force: float = 100.0

@onready var camera_3d: Camera3D = $"../CameraRig/HRotation/VRotation/SpringArm3D/Camera3D"
@onready var stopwatch: TextureRect = $"../UI/Stopwatch"
@onready var canvas_layer: CanvasLayer

var can_move: bool = true
var is_on_ground: bool = true
var buttons_created = false
var calibrated = false
var tilts = []
var initial_tilt = {
	"alpha": 0, 
	"beta": 0, 
	"gamma": 0,
	"rotationRate": {"alpha": 0, "beta": 0, "gamma": 0}
}
var current_platform_velocity: Vector3 = Vector3.ZERO

var spin_charge_timer: float = 0.0
var spin_charging: bool = false

func calibrate_tilt():
	if Global.is_mobile:
		return MobileMovement.get_tilt()

func get_calibrated_tilt():
	var new_tilt = MobileMovement.get_tilt()
	var calibrated = {"alpha": 0, "beta": 0, "gamma": 0, "rotationRate": {"alpha": 0, "beta": 0, "gamma": 0}}
	calibrated["alpha"] = new_tilt["alpha"] - initial_tilt["alpha"]
	calibrated["beta"] = new_tilt["beta"] - initial_tilt["beta"]
	calibrated["gamma"] = new_tilt["gamma"] - initial_tilt["gamma"]
	calibrated["rotationRate"] = new_tilt["rotationRate"]
	return calibrated

func _ready():
	if Global.is_mobile:
		MobileMovement.create_listeners()
		create_permission_button()
	var mesh = $MeshInstance3D
	mesh.set_surface_override_material(0, Global.player_skin)

func _process(delta):
	if Global.is_falling:
		stop_motion()
		Global.is_falling = false

	if spin_charging:
		spin_charge_timer += delta

	if Global.is_mobile:
		if Global.controls_shown and not buttons_created:
			create_action_buttons()
			buttons_created = true
			Global.control_button_created = true
		show_hide_btns()

func create_permission_button() -> void:
	if not Global.is_mobile:
		return
	if not canvas_layer:
		canvas_layer = CanvasLayer.new()
		add_child(canvas_layer)
	var texture_rect = TextureRect.new()
	texture_rect.texture = load("res://Assets/Interface/ui_images/set_name_in_4x1.png")
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	texture_rect.custom_minimum_size = Vector2(Global.screen_size.x * 0.25, Global.screen_size.x * 0.0625)
	var btn = Button.new()
	btn.text = "Enable Motion Controls"
	btn.size = Vector2(Global.screen_size.x * 0.25, Global.screen_size.x * 0.0625)
	btn.connect("pressed", Callable(self, "_on_permission_button_pressed"))
	texture_rect.add_child(btn)
	var stopwatch_pos = stopwatch.get_rect().position
	texture_rect.set_position(Vector2(stopwatch_pos.x, stopwatch_pos.y + 50))
	add_child(texture_rect)

func _on_permission_button_pressed() -> void:
	if MobileMovement.request_permission():
		await get_tree().create_timer(1.0).timeout
	if not calibrated:
		var count = 5
		tilts.clear()
		for i in range(count):
			var tilt = MobileMovement.get_tilt()
			tilts.append(tilt)
			await get_tree().create_timer(0.1).timeout
		var avg_alpha = 0
		var avg_beta = 0
		var avg_gamma = 0
		for tilt in tilts:
			avg_alpha += tilt["alpha"]
			avg_beta += tilt["beta"]
			avg_gamma += tilt["gamma"]
		initial_tilt = {
			"alpha": avg_alpha / count, 
			"beta": avg_beta / count, 
			"gamma": avg_gamma / count,
			"rotationRate": {"alpha": 0, "beta": 0, "gamma": 0}
		}
		calibrated = true

func round_place(num):
	return int(num * 1000) / float(1000)

func _integrate_forces(_state: PhysicsDirectBodyState3D) -> void:
	if not can_move:
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		return
	linear_velocity.z = clamp(linear_velocity.z, -max_linear_velocity, max_linear_velocity)
	linear_velocity.x = clamp(linear_velocity.x, -max_linear_velocity, max_linear_velocity)
	angular_velocity.x = clamp(angular_velocity.x, -max_angular_velocity, max_angular_velocity)
	var cam_forward = (camera_3d.global_transform.basis.z * Vector3(1, 0, 1)).normalized()
	var cam_horizontal = (camera_3d.global_transform.basis.x * Vector3(1, 0, 1)).normalized()
	var forward_input = 0.0
	var horizontal_input = 0.0
	if Global.is_mobile:
		var permission = MobileMovement.get_permission_status()
		if permission == "granted":
			var tilt = MobileMovement.get_tilt()
			if tilt:
				var calibrated_tilt = get_calibrated_tilt()
				var beta = calibrated_tilt["beta"]
				var gamma = calibrated_tilt["gamma"]
				var forward_deadzone = 10.0
				var side_deadzone = 10.0
				var max_angle = 30.0
				if abs(beta) > forward_deadzone:
					var forward_factor = clamp((abs(beta) - forward_deadzone) / (max_angle - forward_deadzone), 0.0, 1.0)
					forward_input = forward_factor * sign(beta)
				if abs(gamma) > side_deadzone:
					var side_factor = clamp((abs(gamma) - side_deadzone) / (max_angle - side_deadzone), 0.0, 1.0)
					horizontal_input = side_factor * sign(gamma)
	else:
		forward_input = Input.get_action_raw_strength("ui_down") - Input.get_action_raw_strength("ui_up")
		horizontal_input = Input.get_action_raw_strength("ui_right") - Input.get_action_raw_strength("ui_left")
	var direction_forward = forward_input * cam_forward
	var direction_horizontal = horizontal_input * cam_horizontal
	if not Global.is_mobile and Input.is_action_pressed("ui_end"):
		make_jump()
	var stop_button_pressed = false
	if Global.is_mobile and canvas_layer and canvas_layer.has_node("StopButton"):
		stop_button_pressed = canvas_layer.get_node("StopButton").is_pressed()
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
	var standing_on_moving_platform := false
	current_platform_velocity = Vector3.ZERO
	for i in _state.get_contact_count():
		var collider := _state.get_contact_collider_object(i)
		if collider is AnimatableBody3D:
			var contact_local_normal := _state.get_contact_local_normal(i)
			if contact_local_normal.dot(Vector3.UP) > 0.7:
				standing_on_moving_platform = true
				current_platform_velocity = collider.get_platform_velocity()
				break
	if standing_on_moving_platform:
		var velocity := _state.get_linear_velocity()
		var horizontal_velocity = Vector3(current_platform_velocity.x, 0, current_platform_velocity.z)
		velocity.x = lerp(velocity.x, horizontal_velocity.x, 0.05)
		velocity.z = lerp(velocity.z, horizontal_velocity.z, 0.05)
		_state.set_linear_velocity(velocity)
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

func stop_motion():
	set_inertia(Vector3.ZERO)
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
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
		canvas_layer.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(canvas_layer)
	var screen_size = get_viewport().get_visible_rect().size
	Global.jump_btn = preload("res://Scripts/Interface/draggable_button.gd").new()
	Global.jump_btn.name = "JumpButton"
	Global.jump_btn.position = Vector2(screen_size.x * 0.75, screen_size.y * 0.75)
	Global.jump_btn.ignore_texture_size = true
	Global.jump_btn.stretch_mode = TextureButton.STRETCH_SCALE
	Global.jump_btn.size = Vector2(screen_size.x * 0.15, screen_size.x * 0.15)
	Global.jump_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	Global.jump_btn.texture_normal = load("res://Assets/buttons/jump_button.png")
	Global.jump_btn.action_callable = Callable(self, "make_jump")
	canvas_layer.add_child(Global.jump_btn)
	
	Global.stop_btn = preload("res://Scripts/Interface/draggable_button.gd").new()
	Global.stop_btn.name = "StopButton"
	Global.stop_btn.position = Vector2(screen_size.x * 0.15, screen_size.y * 0.75)
	Global.stop_btn.ignore_texture_size = true
	Global.stop_btn.stretch_mode = TextureButton.STRETCH_SCALE
	Global.stop_btn.size = Vector2(screen_size.x * 0.15, screen_size.x * 0.15)
	Global.stop_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	Global.stop_btn.texture_normal = load("res://Assets/buttons/stop_button.png") 
	Global.stop_btn.action_callable = Callable(self, "_on_stop_button_event")
	canvas_layer.add_child(Global.stop_btn)
	
	Global.spin_btn = preload("res://Scripts/Interface/draggable_button.gd").new()
	Global.spin_btn.name = "SpinButton"
	Global.spin_btn.position = Vector2(screen_size.x * 0.15, screen_size.y * 0.65)
	Global.spin_btn.ignore_texture_size = true
	Global.spin_btn.stretch_mode = TextureButton.STRETCH_SCALE
	Global.spin_btn.size = Vector2(screen_size.x * 0.15, screen_size.x * 0.15)
	Global.spin_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	Global.spin_btn.texture_normal = load("res://Assets/buttons/spin_button.png")
	Global.spin_btn.action_callable = Callable(self, "_on_spin_button_event")
	canvas_layer.add_child(Global.spin_btn)

func _on_stop_button_event(event_type = ""):
	if event_type == "down":
		var horizontal_velocity = Vector3(linear_velocity.x, 0, linear_velocity.z)
		horizontal_velocity = horizontal_velocity.lerp(Vector3.ZERO, braking_factor)
		linear_velocity = Vector3(horizontal_velocity.x, linear_velocity.y, horizontal_velocity.z)
		angular_velocity = angular_velocity.lerp(Vector3.ZERO, braking_factor)
		physics_material_override.friction = 0.0
	elif event_type == "up":
		physics_material_override.friction = 1.0
		var lil_jump_magnitude = 0.6
		var lil_jump_impulse = lil_jump_magnitude * Vector3.ONE
		var final_boost_vector = lil_jump_impulse + (camera_3d.global_transform.basis.z * Vector3(1, 0, 1)).normalized()
		var spin_speed = get_angular_velocity().length()
		apply_central_impulse(spin_speed * final_boost_vector)

func _on_spin_button_event(event_type = ""):
	if event_type == "down":
		spin_charging = true
	elif event_type == "up" and spin_charging:
		spin_charging = false
		var charge_factor = clamp(spin_charge_timer, 0.0, 2.0)
		var cam_horizontal = (camera_3d.global_transform.basis.x * Vector3(1, 0, 1)).normalized()
		apply_torque_impulse(-cam_horizontal * spin_boost_factor * charge_factor)
		spin_charge_timer = 0.0

func make_jump(event_type = ""):
	if event_type == "down" and is_on_ground:
		apply_impulse(Vector3(0, jump_force, 0))
		is_on_ground = false
	elif is_on_ground:
		apply_impulse(Vector3(0, jump_force, 0))
		is_on_ground = false
	if canvas_layer and canvas_layer.has_node("StopButton") and canvas_layer.get_node("StopButton").is_pressed():
		var cam_horizontal = (camera_3d.global_transform.basis.x * Vector3(1, 0, 1)).normalized()
		apply_torque_impulse(-cam_horizontal * spin_boost_factor)

func show_hide_btns():
	if Global.is_paused:
		if Global.jump_btn.visible:
			Global.jump_btn.visible = false
			Global.stop_btn.visible = false
			Global.spin_btn.visible = false
	else:
		if not Global.jump_btn.visible:
			Global.jump_btn.visible = true
			Global.stop_btn.visible = true
			Global.spin_btn.visible = true
