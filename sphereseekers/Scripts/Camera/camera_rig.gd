extends Node3D

@export_category("configurables")
@export var cam_v_max : float = 110.0
@export var cam_v_min : float = -75.0
@export var camzoom_max : float = 11.0
@export var camzoom_min : float = 2.0

@export var h_sensitivity : float = 0.1
@export var v_sensitivity : float = 0.1

@export var h_acceleration : float = 15.0
@export var v_acceleration : float = 15.0

# ================================================== #

var camrot_h : float = 0.0
var camrot_v : float = 0.0
var camzoom : float = 5.0

@onready var marble: RigidBody3D = $"../Marble"
@onready var h_rotation: Node3D = $HRotation
@onready var v_rotation: Node3D = $HRotation/VRotation
@onready var spring_arm_3d: SpringArm3D = $HRotation/VRotation/SpringArm3D

func _ready():
	pass
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _physics_process(delta: float) -> void:
	global_position = lerp(global_position, marble.get_node("MeshInstance3D").global_position, 0.3)
	camrot_v = clamp(camrot_v, cam_v_min, cam_v_max)
	
	h_rotation.rotation_degrees.y = lerp(h_rotation.rotation_degrees.y, camrot_h, delta * h_acceleration)
	v_rotation.rotation_degrees.x = lerp(v_rotation.rotation_degrees.x, camrot_v, delta * v_acceleration)
	spring_arm_3d.spring_length = lerp(spring_arm_3d.spring_length, camzoom, delta * h_acceleration)
	
	rotation_degrees.z = 0
	
	
func _input(event):
	if (event is InputEventMouseMotion and not Global.dragging_button):
		camrot_h += -event.relative.x * h_sensitivity
		camrot_v += -event.relative.y * v_sensitivity
	if (event is InputEventMouseButton):
		if (event.button_index == MOUSE_BUTTON_WHEEL_UP):
			if (camzoom < camzoom_max):
				camzoom += 1
				print("wheel up")
		elif (event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			if (camzoom > camzoom_min):
				camzoom -= 1
				print("wheel down")
	
