extends Control

# UI References
var bg_rect: ColorRect
var gear_image: TextureRect

# Loading control
var scene_path: String = ""
var loading_complete := false

func _ready() -> void:
	bg_rect = $background
	gear_image = $image

	setup_ui()

	# Begin async loading
	scene_path = get_path_to_level()
	ResourceLoader.load_threaded_request(scene_path)

func _process(delta: float) -> void:
	var progress := []
	var status = ResourceLoader.load_threaded_get_status(scene_path, progress)

	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			gear_image.rotation_degrees += 360 * delta
		ResourceLoader.THREAD_LOAD_LOADED:
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(scene_path))

func setup_ui() -> void:
	var screen_size = get_viewport_rect().size
	var w = screen_size.x
	var h = screen_size.y

	# Setup background
	bg_rect.set_size(screen_size)
	bg_rect.set_position(Vector2.ZERO)
	bg_rect.color = Color(173 / 255.0, 216 / 255.0, 230 / 255.0)

	# Load gear texture
	gear_image.texture = load("res://Assets/Interface/ui_images/gear.png")

	if gear_image.texture:
		var texture_size = gear_image.texture.get_size()
		var aspect_ratio = texture_size.x / float(texture_size.y)

		var max_height = h * 0.3
		var desired_width = w * 0.4
		var desired_height = desired_width / aspect_ratio

		if desired_height > max_height:
			desired_height = max_height
			desired_width = desired_height * aspect_ratio
		
		gear_image.set_size(Vector2(desired_width, desired_height))
		gear_image.pivot_offset = gear_image.size / 2

		# Center the image
		gear_image.set_position(Vector2(
			(w - gear_image.size.x) / 2,
			(h - gear_image.size.y) / 2
		))

func get_path_to_level() -> String:
	PlayerClass.current_level_time = 0
	match Global.level_to_play:
		Global.levels.TUTORIAL:
			return "res://Scenes/Levels/Tutorial.tscn"
		Global.levels.LEVEL1:
			return "res://Scenes/Levels/level_1.tscn"
		Global.levels.LEVEL2:
			return "res://Scenes/Levels/level_2.tscn"
		_:
			return "res://Scenes/Interface/MainMenu.tscn"
