extends Node2D

export  var song_intro: AudioStream
export  var song_loop: AudioStream
export  var song2_intro: AudioStream
export  var song2_loop: AudioStream
onready var musicplayer: AudioStreamPlayer = $Music_Player
onready var dialog_box: Label = $DialogBox
onready var problem_demake: AudioStream = preload("res://Remix/Songs/Problem.mp3")
onready var fate_to_fight_demake: AudioStream = preload("res://Remix/Songs/Fate to Fight.ogg")#Not ready
export  var text_second_dialog: Resource
var second_dialog: = false

var cutscene_stage = 0

onready var tween: = TweenController.new(self, false)
onready var tween2: = TweenController.new(self, false)
onready var tween3: = TweenController.new(self, false)
onready var visuals: Node2D = $Visuals
onready var screencover: Sprite = $screencover
onready var bottom_cover: Sprite = $bottom_cover
onready var top_cover: Sprite = $top_cover
onready var elevator_walls = $Visuals / ElevatorWalls
onready var loop: AudioStreamPlayer2D = $Visuals / ElevatorPlatform / loop
onready var x: AnimatedSprite = get_node("Visuals").get_node("ElevatorPlatform").get_node("X")
onready var axl: AnimatedSprite = get_node("Visuals").get_node("ElevatorPlatform").get_node("Axl")
onready var zero: AnimatedSprite = get_node("Visuals").get_node("ElevatorPlatform").get_node("Zero")
onready var x_sprites: Resource = preload("res://src/Actors/Player/x_sprites/x.res")
onready var x_x8_sprites: Resource = preload("res://X_mod/X8/Sprites/X_X8.tres")

onready var victory_sfx = $victory

var fade_out_duration = 3.0

signal movement_finished(sprite, animation)

func axl_credits():
	CharacterManager.set_axl_normal_colors(axl)

func zero_credits():
	CharacterManager.set_zeroX8_normal_colors(zero)

func _ready() -> void :
	axl_credits()
	zero_credits()
	CharacterManager.white_axl_armor = false
	CharacterManager.black_zero_armor = false
	screencover.visible = true
	Tools.timer(1, "fade_in", self)
	Tools.timer(4, "start_dialog", self)
	Tools.timer(0.1, "start_music", self)
	Event.connect("character_talking", self, "on_talk")
	if CharacterManager.use_old_sprite:
		x.frames = x_sprites
	else:
		x.frames = x_x8_sprites

func on_talk(character_name: String):
		if character_name == "Zero":
			zero.play("talk")
		else:
			zero.play("blink")

func start_music():
	#song_loop.loop = false
	if Configurations.exists("SongRemix"):
		if Configurations.get("SongRemix"):
			musicplayer.play_song(problem_demake, false)
		else:
			musicplayer.play_song(song_loop, false)

func start_dialog():
	dialog_box.startup()

func start_second_dialog():
	#song2_loop.loop = false
	musicplayer.fast_fade_out = false
	musicplayer.volume_db = 0
	musicplayer.playing = true
	if Configurations.exists("SongRemix"):
		if Configurations.get("SongRemix"):
			musicplayer.play_song(fate_to_fight_demake, false)
		else:
			musicplayer.play_song(song2_loop, false)
	second_dialog = true
	dialog_box.dialog_tree = text_second_dialog
	dialog_box.startup()

func _on_dialog_concluded() -> void :
	if not second_dialog:
		zero.flip_h = false
		var params = {
			"sprite": zero, 
			"animation": "walk", 
			"x": - 12, 
			"y": zero.position.y, 
			"duration": 1
		}
		Tools.timer_array(self, 1.0, "move_to_position", params)
		musicplayer.fast_fade_out = true
	else:
		#go_to_credits_position()
		cutscene_stage += 1
		fade_out_covers()
		tween.attribute("volume_db", - 80, 3.0, musicplayer)
		finished_movement(null,null)

func move_to_position(data: Dictionary):
	var sprite = data["sprite"]
	var animation = data["animation"]
	var x = data["x"]
	var y = data["y"]
	var duration = data["duration"]
	if animation != null:
		sprite.animation = animation
	tween.attribute("position:x", x, duration, sprite)
	tween.attribute("position:y", y, duration, sprite)
	var callback_data = {"sprite": sprite, "animation": "recover"}
	tween.add_callback("on_movement_completed", self, [callback_data])
	connect("movement_finished", self, "finished_movement")

func on_movement_completed(callback_data):
	var sprite = callback_data["sprite"]
	var animation = callback_data["animation"]
	emit_signal("movement_finished", sprite, animation)

func finished_movement(sprite, animation):
	match cutscene_stage:
		0:
			zero_talking()
		1:
			start_second_dialog()
		2:
			cutscene_stage += 1
			var params = {
			"sprite": visuals, 
			"animation": null, 
			"x": 0, 
			"y": 0, 
			"duration": 1
			}
			Tools.timer_array(self, 1.0, "move_to_position", params)
		3:
			Tools.timer(0.2, "go_to_credits", self)

func zero_talking():
	cutscene_stage += 1
	var params = {
		"sprite": zero, 
		"animation": "blink", 
		"x": zero.position.x, 
		"y": zero.position.y, 
		"duration": 0.5
	}
	move_to_position(params)

func go_to_credits_position():
	cutscene_stage += 1
	x.flip_h = false
	var params = {
		"sprite": x, 
		"animation": "walk", 
		"x": 46, 
		"y": - 30, 
		"duration": 1
	}
	Tools.timer_array(self, 1.0, "move_to_position", params)
	zero.flip_h = true
	params = {
		"sprite": zero, 
		"animation": "walk", 
		"x": - 53, 
		"y": - 31, 
		"duration": 1
	}
	Tools.timer_array(self, 1.0, "move_to_position", params)
	params = {
		"sprite": axl, 
		"animation": "walk", 
		"x": - 4, 
		"y": - 31, 
		"duration": 1
	}
	Tools.timer_array(self, 1.0, "move_to_position", params)
	Tools.timer(1.0, "flip_axl", self)
	params = {
		"sprite": visuals, 
		"animation": null, 
		"x": 0, 
		"y": 0, 
		"duration": 1
	}
	Tools.timer_array(self, 1.0, "move_to_position", params)

func flip_axl():
	axl.flip_h = true

func turn_everyone_around():
	cutscene_stage += 1
	x.flip_h = true
	var params = {
		"sprite": x, 
		"animation": "idle", 
		"x": x.position.x, 
		"y": x.position.y, 
		"duration": 0.5
	}
	move_to_position(params)
	zero.flip_h = true
	params = {
		"sprite": zero, 
		"animation": "idle", 
		"x": zero.position.x, 
		"y": zero.position.y, 
		"duration": 0.5
	}
	move_to_position(params)
	axl.flip_h = true
	params = {
		"sprite": axl, 
		"animation": "idle", 
		"x": axl.position.x, 
		"y": axl.position.y, 
		"duration": 0.5
	}
	move_to_position(params)

func fade_out_covers():
	tween2.attribute("modulate:a", 0.0, 2.0, top_cover)
	tween3.attribute("modulate:a", 0.0, 2.0, bottom_cover)

func fade_in():
	screencover.visible = true
	screencover.modulate = Color.black
	tween.attribute("modulate:a", 0.0, 3.0, screencover)

func fade_out():
	screencover.visible = true
	tween.attribute("modulate:a", 1.0, fade_out_duration, screencover)
	tween.add_wait(3)
	tween.attribute("volume_db", - 80, fade_out_duration, loop)
	tween.add_callback("go_to_credits", GameManager)
	
func go_to_credits():
	CharacterManager.elevator_walls_y = elevator_walls.region_rect.position.y
	GameManager.go_to_credits()
