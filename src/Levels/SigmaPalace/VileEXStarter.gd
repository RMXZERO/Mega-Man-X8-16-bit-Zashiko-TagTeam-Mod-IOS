extends Area2D

var activated: = false
onready var next_limit: Area2D = $"../../Limits/vile2"
onready var djsigma_song: AudioStreamPlayer = $"../../DJSigmaStarter/IntroSong"
onready var music: AudioStreamPlayer = $"../../Music Player"
onready var foreground: ParallaxLayer = $"../../parallaxBackground2/foreground"
onready var not_sound_change: = preload("res://Zero_mod/SFX/no_sound.ogg")

func _on_body_entered(_body: Node) -> void :
	if not activated:
		activated = true
		foreground.visible = false
		music.start_fade_out()
		handle_player()
		Event.emit_signal("call_fade_out_intro")
		if djsigma_song:
			djsigma_song.stop()
			djsigma_song.fade_out()
			djsigma_song.volume_db = -80
			djsigma_song.base_volume = -80
			djsigma_song.stream = not_sound_change
			djsigma_song.loop.stream = not_sound_change
			djsigma_song.loop.stream.loop = false

func handle_player() -> void:
	if is_instance_valid(GameManager.player):
		if GameManager.player.is_executing("Ride"):
			GameManager.player.get_parent().void_touch()
