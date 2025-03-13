extends Node3D

@export var tile_size: Vector3 = Vector3(4, 0.5, 2)
@export var scale_factor: float = 1.0
@export var tile_enabled: Dictionary = {
	"l1": true, "l2": true, "l3": true, "l4": true, "l5": true, 
	"l6": true, "l7": true, "l8": true, "l9": true, 
	"r1": true, "r2": true, "r3": true, "r4": true, "r5": true, 
	"r6": true, "r7": true, "r8": true, "r9": true
}
@export var tile_material = StandardMaterial3D

var segment_count: int = 9

func get_start_positions() -> Dictionary:
	var x_offset = tile_size.x / 2
	return {
		"left": Vector3(-x_offset, 0, -tile_size.z),
		"right": Vector3(x_offset, 0, -tile_size.z)
	}

func _ready() -> void:
	apply_scaling()

func apply_scaling():
	var start_positions = get_start_positions()
	
	for i in range(1, segment_count + 1):
		var l_name = "l" + str(i)
		var r_name = "r" + str(i)
		var l_segment = get_node_or_null(l_name)
		var r_segment = get_node_or_null(r_name)
		
		if l_segment and r_segment:
			var new_z = start_positions["left"].z + ((i - 1) * tile_size.z * scale_factor)
			
			l_segment.position = Vector3(
				start_positions["left"].x * scale_factor,
				start_positions["left"].y,
				new_z
			)
			r_segment.position = Vector3(
				start_positions["right"].x * scale_factor,
				start_positions["right"].y,
				new_z
			)
			
			if l_segment is CSGBox3D and r_segment is CSGBox3D:
				l_segment.size = tile_size * scale_factor
				r_segment.size = tile_size * scale_factor
				
				l_segment.scale = Vector3.ONE
				r_segment.scale = Vector3.ONE
				
				apply_material(l_segment)
				apply_material(r_segment)
			
			set_tile_state(l_name, tile_enabled.get(l_name, true))
			set_tile_state(r_name, tile_enabled.get(r_name, true))

func set_tile_state(tile_name: String, enabled: bool):
	var tile_node = get_node_or_null(tile_name)
	if tile_node:
		tile_node.visible = enabled
		if tile_node is CSGBox3D:
			tile_node.use_collision = enabled
			
func apply_material(tile: CSGBox3D):
	tile.material = tile_material
