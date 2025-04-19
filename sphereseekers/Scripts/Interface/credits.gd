extends Node2D

const SECTION_TIME := 1.0
const LINE_TIME := 0.3
const BASE_SPEED := 100
const SPEED_UP_MULTIPLIER := 10.0
const TITLE_COLOR := Color(173 / 255.0, 216 / 255.0, 230 / 255.0)

var title_font_size : int
var regular_font_size: int
var scroll_speed := BASE_SPEED
var speed_up := false

@onready var line := $credits_container/line
@onready var color_rect := $ColorRect
@onready var container := $credits_container

var started := false
var finished := false

var section = []
var section_next := true
var section_timer := 0.0
var line_timer := 0.0
var curr_line := 0
var lines: Array[Label] = []

var credits = [
	["A game by Sphereseekers"],
	["Programming", "", "Kenet Ortiz", "", "Dev Patel", "", "Ernesto Rendon", "", "Scott Willard"],
	["Game Design", "", "Kenet Ortiz", "", "Dev Patel", "", "Ernesto Rendon", "", "Scott Willard"],
	["Team Lead", "", "Scott Willard"],
	["QA Test", "", "Kenet Ortiz"],
	["Sound Design", "", "Scott Willard"],
	["Art", "", "Ernesto Rendon"],
	["Testers", "", "Kenet Ortiz", "", "Dev Patel", "", "Ernesto Rendon", "", "Scott Willard"],
	["Advisor", "", "Carsten Thue-Bludworth"],
	[
		"Tools used", "",
		"Developed with Godot Engine", "",
		"https://godotengine.org/license",
		"",
		"Designed in Blender", "",
		"https://blender.org/about/license/",
		"",
		"Hosted in Vercel", "",
		"https://vercel.com/about", "",
		"",
		"Audio created with GuitarPro 8", "",
		"https://www.guitar-pro.com/",
		""
	],
	["Special thanks", "", "Our Families", "", "Our friends", "", "Our Advisor"],
	[""],
	[""],
	["Thank you for playing!"]
]

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_set_font_size()
	var screen_size = get_viewport().get_visible_rect().size
	color_rect.size = screen_size
	color_rect.color = Color(0, 0, 0)
	container.size = screen_size
	line.visible = false

func _process(delta):
	var current_scroll = BASE_SPEED * delta
	if speed_up:
		current_scroll *= SPEED_UP_MULTIPLIER

	if section_next:
		section_timer += delta * (SPEED_UP_MULTIPLIER if speed_up else 1)
		if section_timer >= SECTION_TIME:
			section_timer -= SECTION_TIME

			if credits.size() > 0:
				started = true
				section = credits.pop_front()
				curr_line = 0
				add_line()
	else:
		line_timer += delta * (SPEED_UP_MULTIPLIER if speed_up else 1)
		if line_timer >= LINE_TIME:
			line_timer -= LINE_TIME
			add_line()

	if lines.size() > 0:
		for l in lines.duplicate():
			l.position.y -= current_scroll
			if l.position.y < -l.size.y:
				lines.erase(l)
				l.queue_free()
	elif started:
		finish()

func add_line():
	var screen_size = get_viewport().get_visible_rect().size
	var new_line = line.duplicate() as Label
	new_line.visible = true
	new_line.text = section.pop_front()
	new_line.position.y = screen_size.y
	new_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	new_line.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	if curr_line == 0:
		new_line.add_theme_color_override("font_color", TITLE_COLOR)
		new_line.add_theme_font_size_override("font_size", title_font_size)
	else:
		new_line.add_theme_font_size_override("font_size", regular_font_size)

	container.add_child(new_line)
	lines.append(new_line)

	new_line.call_deferred("set_position", Vector2(
		(screen_size.x - new_line.size.x) / 2,
		new_line.position.y
	))

	if section.size() > 0:
		curr_line += 1
		section_next = false
	else:
		section_next = true

func finish():
	if not finished:
		finished = true
		Global.control_button_created = false
		MusicPlayer.find_child("AudioStreamPlayer2D").play()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_file("res://Scenes/Interface/MainMenu.tscn")

func _unhandled_input(event):
	if event.is_action_pressed("ui_down") and not event.is_echo():
		speed_up = true
	if event.is_action_released("ui_down") and not event.is_echo():
		speed_up = false

func _set_font_size():
	if Global.is_mobile:
		title_font_size = 56
		regular_font_size = 48
	else:
		print("not mobile")
		title_font_size = 36
		regular_font_size = 30
			
