extends MeshInstance3D

@export var is_left_to_right: bool
@export var is_up_and_down: bool
@export var movement_speed: float = 5.0
@export var distance: float = 20.0
@export var direction: float = 1

var starting_position: Vector3


func _ready():
	starting_position = position
	if is_left_to_right and is_up_and_down:
		print("only one movement is possible")
		return
	
func _process(delta: float) -> void:
	if is_left_to_right:
		if position.z >= starting_position.z + distance:
			direction = -1
		elif position.z <= starting_position.z - distance:
			direction = 1
		position.z += (delta * movement_speed * direction)
	elif is_up_and_down:
		if position.y >= starting_position.y + distance:
			direction = -1
		elif position.y <= starting_position.y - distance:
			direction = 1
		position.y += (delta * movement_speed * direction)
	else:
		if position.x >= starting_position.x + distance:
			direction = -1
		elif position.x <= starting_position.x - distance:
			direction = 1
		position.x += (delta * movement_speed * direction)
