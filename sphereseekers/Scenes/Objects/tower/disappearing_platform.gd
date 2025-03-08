extends MeshInstance3D

@export var disappear_delay: float = 2.0

@onready var static_body = $StaticBody3D
@onready var collision_shape = $StaticBody3D/CollisionShape3D 

func _ready():
	var area = Area3D.new()
	add_child(area)
	
	var area_collision = CollisionShape3D.new()
	area_collision.shape = collision_shape.shape.duplicate()
	area.add_child(area_collision)
	
	area.connect("body_entered", Callable(self, "_on_body_entered"))
	

func _on_body_entered(body):
	if body.is_in_group("player"):
		var timer = get_tree().create_timer(disappear_delay)
		timer.connect("timeout", Callable(self, "_on_disappear_timer_timeout"))
		
func _on_disappear_timer_timeout():
	visible = false
	collision_shape.disabled = true
	var timer = get_tree().create_timer(disappear_delay * 2)
	timer.connect("timeout", Callable(self, "_on_vanished_timeout"))

func _on_vanished_timeout():
	visible = true
	collision_shape.disabled = false
