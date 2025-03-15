extends Control

var scene_path: String = "" 
var loading_complete = false

func _ready():
	var background = $background
	var image = $image
	
	set_objects(background, image)
	
	var texture_size = image.texture.get_size()
	image.pivot_offset = texture_size / 2
	
	scene_path = get_path_to_level()
	ResourceLoader.load_threaded_request(scene_path)

func _process(delta):
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(scene_path, progress)

	# Checks what is actually being loaded for the level	
	#for dependency in ResourceLoader.get_dependencies(scene_path):
		#print(dependency.get_slice("::", 0)) # Prints the UID.
		#print(dependency.get_slice("::", 2)) # Prints the path.
		
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		$image.rotation_degrees += 360 * delta
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(scene_path))
		
func set_objects(background, image):
	var screen_size = get_viewport_rect().size
	var width = screen_size.x
	var height = screen_size.y

	# Background (ColorRect)
	background.set_size(Vector2(width * 0.4, height * 0.8))
	background.set_position(Vector2(width * 0.3, height * 0.1))
	background.color = Color(77 / 255.0, 77 / 255.0, 77 / 255.0)

	# Background size & position
	var bg_size = background.size

	# Image (TextureRect) - Remove label & center image
	image.texture = load("res://Assets/Interface/loading_screen/gear.png")
	var image_scale_factor = 0.4
	var max_image_height = bg_size.y * 0.3

	if image.texture:
		var texture_size = image.texture.get_size()
		var aspect_ratio = texture_size.x / float(texture_size.y)

		var new_width = bg_size.x * image_scale_factor
		var new_height = new_width / aspect_ratio

		if new_height > max_image_height:
			new_height = max_image_height
			new_width = new_height * aspect_ratio

		image.set_size(Vector2(new_width, new_height))
		image.pivot_offset = image.size / 2  # Center rotation pivot

	# Center image in the middle of the screen
	image.set_position(Vector2(
		(width - image.size.x) / 2,
		(height - image.size.y) / 2
	))
			
func get_path_to_level() -> String:
	match Global.level_to_play:
		Global.levels.TUTORIAL:
			return "res://Scenes/Levels/Tutorial.tscn"
		Global.levels.LEVEL1:
			return "res://Scenes/Levels/level_1.tscn"
		Global.levels.LEVEL2:
			return "res://Scenes/Levels/level_2.tscn"
	return "res://Scenes/Interface/MainMenu.tscn"
