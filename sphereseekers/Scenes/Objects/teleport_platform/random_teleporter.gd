extends Node3D

var possible_positions = [
	Vector3(-360,-10,271),
	Vector3(-43, -10, 144),
	Vector3(48, -10, 144),
	Vector3(426, -10, 48),
	Vector3(298, -10, -107),
	Vector3(56, -10, -191),
	Vector3(43, -7, -325),
	Vector3(-265, -10, -24)
]
var rng = RandomNumberGenerator.new()
var random_position: int
@onready var music = $AudioStreamPlayer3D

func _ready() -> void:
	select_random_position()
	self.position = possible_positions[random_position]
	music.position = possible_positions[random_position]
	music.position.z = music.position.z + 5
	
func select_random_position():
	var my_random_number = rng.randf_range(0, 7)
	random_position = my_random_number
