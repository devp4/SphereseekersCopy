extends Node
enum levels{TUTORIAL, LEVEL1, LEVEL2, LEVEL3, LEVEL4, LEVEL5}

var level_to_play :  levels
var controls_shown = false
var is_mobile = false
var is_paused = false
var in_main_menu = true
var stop_all_projectiles: bool = false
var player_skin: StandardMaterial3D = load("res://Assets/Materials/cartoon/orange_toon/orange_toon.tres")
var dragging_button = false
var allow_dragging = true
var is_muted = false

var is_falling = false

var volume_level = 100

var screen_size
var jump_btn
var stop_btn
