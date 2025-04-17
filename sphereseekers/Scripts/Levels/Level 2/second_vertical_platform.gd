extends AnimatableBody3D

@export var is_left_to_right: bool
@export var is_up_and_down: bool
@export var movement_speed: float = 5.0
@export var distance: float = 20.0
@export var direction: float = -1.0

var starting_position: Vector3
var previous_position: Vector3
var platform_velocity: Vector3 = Vector3.ZERO

func _ready():
	starting_position = global_position
	previous_position = global_position
	if is_left_to_right and is_up_and_down:
		print("only one movement is possible")
		return

func get_platform_velocity() -> Vector3:
	return platform_velocity

func _physics_process(delta: float) -> void:
	var pos = global_position
	
	if is_left_to_right:
		if pos.z >= starting_position.z + distance:
			direction = -1.0
		elif pos.z <= starting_position.z - distance:
			direction = 1.0
		pos.z += (delta * movement_speed * direction)
	elif is_up_and_down:
		if pos.y >= starting_position.y + distance:
			direction = -1.0
		elif pos.y <= starting_position.y - distance:
			direction = 1.0
		pos.y += (delta * movement_speed * direction)
	else:
		if pos.x >= starting_position.x + distance:
			direction = -1.0
		elif pos.x <= starting_position.x - distance:
			direction = 1.0
		pos.x += (delta * movement_speed * direction)

	global_position = pos
	
	# Calculate velocity for the current frame
	platform_velocity = (global_position - previous_position) / delta
	previous_position = global_position
