extends Node3D

@export var arm1: bool = true
@export var arm2: bool = true
@export var arm3: bool = true
@export var arm4: bool = true
@export var rotation_speed: float = 2.0
@export var rotate_direction: int = 1

@onready var base: MeshInstance3D = $base

var time_elapsed: float = 0.0

func _ready():
	check_if_visible()
	
func _process(delta: float):
	if base:
		time_elapsed += delta * 1
		var angle = rotation_speed * time_elapsed * rotate_direction
		base.rotation_degrees.y = angle

func check_if_visible():
	var arms = [
		[arm1, $"base/arm1", $"base/base_arm1"],
		[arm2, $"base/arm2", $"base/base_arm2"],
		[arm3, $"base/arm3", $"base/base_arm3"],
		[arm4, $"base/arm4", $"base/base_arm4"]
	]

	for arm_data in arms:
		var arm_enabled = arm_data[0]
		var arm_node = arm_data[1]
		var base_arm_node = arm_data[2]

		if not arm_enabled:
			arm_node.visible = false
			arm_node.get_node("StaticBody3D/CollisionShape3D").disabled = true

			base_arm_node.visible = false
			base_arm_node.get_node("StaticBody3D/CollisionShape3D").disabled = true
