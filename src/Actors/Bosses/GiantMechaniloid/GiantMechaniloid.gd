extends Panda

func _ready() -> void :
	Event.listen("moved_player_to_checkpoint", self, "on_checkpoint")
	listen("zero_health", self, "_on_zero_health")

func on_checkpoint(checkpoint: CheckpointSettings) -> void :
	if checkpoint.id >= 4:
		destroy()

func _physics_process(_delta: float) -> void :
	var new_x = GameManager.camera.get_camera_screen_center().x - global_position.x
	animatedSprite.position.x = new_x / 3.4

func _on_rising_platform_at_max() -> void :
	Event.emit_signal("play_miniboss_music")
	Event.emit_signal("boss_start", self)
	emit_signal("intro_concluded")

func _on_zero_health() -> void :
	GameManager.music_player.start_fade_out()
	Tools.timer(2.0, "start_music", self)

func start_music() -> void :
	var current_scene = get_tree().current_scene
	var remix = current_scene.get_node_or_null("Remix")
	if current_scene and remix:
		if Configurations.exists("SongRemix"):
			if Configurations.get("SongRemix"):
				GameManager.music_player.play_song(remix._metalvalley2_loop, remix._metalvalley2_intro)
			else:
				GameManager.music_player.play_song(remix._original_alt_stage_loop, remix._original_alt_stage_intro)

func _on_rising_platform_started() -> void :
	GameManager.music_player.start_fade_out()
