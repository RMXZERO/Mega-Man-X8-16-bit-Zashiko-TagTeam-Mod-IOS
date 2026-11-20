extends Area2D

onready var music: AudioStreamPlayer = $"../../Music Player"

export  var intro: AudioStream
export  var loop: AudioStream

var started: bool = false
var end: bool = false

func _ready() -> void :
	var demo_song: AudioStreamPlayer = $DemoSong
	if demo_song:
		demo_song.fade_out()
		end = false
		Event.connect("call_fade_out_intro",self,"fade_out_demo_song")

func fade_out_demo_song() -> void :
	if started:
		if not end:
			end = true
			Event.disconnect("call_fade_out_intro",self,"fade_out_demo_song")
			yield(get_tree().create_timer(2.0), "timeout")
			var demo_song: AudioStreamPlayer = $DemoSong
			if demo_song:
				demo_song.queue_free()

func _on_body_entered(body: Node) -> void :
	if not started:
		started = true
		var demo_song: AudioStreamPlayer = $DemoSong
		if demo_song:
			demo_song.stream = intro
			demo_song.get_node("loop").stream = loop
			demo_song.get_node("loop").stream.loop = true
			demo_song.play()
			demo_song.fade_in()
		else:
			music.play_song_wo_fadein(loop, intro)

