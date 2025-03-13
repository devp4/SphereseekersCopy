extends Node3D

@export var rotation_degree: float = 90.0
@export var rotation_speed: float = 2.0
@onready var axis: MeshInstance3D = $axis
var time_elapsed: float = 0.0

func _process(delta: float):
	if axis:
		time_elapsed += delta * rotation_speed
		var angle = rotation_degree * sin(time_elapsed)
		axis.rotation_degrees.x = angle
	
