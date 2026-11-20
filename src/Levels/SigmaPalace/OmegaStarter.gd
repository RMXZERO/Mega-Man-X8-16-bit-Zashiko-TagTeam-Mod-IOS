extends Area2D

var activated: = false
var camera_signal: bool = false
onready var next_limit: Area2D = $"../../Limits/omegastart"
onready var fight_limit: Area2D = $"../../Limits/omegafight"
onready var djsigma_song: AudioStreamPlayer = $"../../DJSigmaStarter/IntroSong"
onready var music: AudioStreamPlayer = $"../../Music Player"
onready var foreground: ParallaxLayer = $"../../parallaxBackground2/foreground"
onready var not_sound_change: = preload("res://Zero_mod/SFX/no_sound.ogg")
onready var invisible_wall1: CollisionShape2D = $invisible_wall/collisionShape2D
onready var invisible_wall2: CollisionShape2D = $invisible_wall/collisionShape2D2
onready var background_oz: AnimatedSprite = $Cannon_Ball_Background
onready var background_zero: AnimatedSprite = $SecretBossBackgroundx5
onready var background_black_hole: AnimatedSprite = $Cannon_Ball_Background/Blackhole

func _ready() -> void:
	Event.connect("boss_start",self,"on_boss_start")
	Event.connect("boss_health_appear",self,"on_boss_start")
	Event.connect("is_boss_2",self,"on_boss_start_2")

func on_boss_start(boss) -> void:
	if "Omega_Zero" in boss.name and not camera_signal:
		camera_signal = true
		Event.disconnect("boss_start",self,"on_boss_start")
		Event.disconnect("boss_health_appear",self,"on_boss_start")
		Event.disconnect("is_boss_2",self,"on_boss_start")
		background_oz.playing = true
		update_fight_limit()

func on_boss_start_2(boss) -> void:
	if boss is String:
		if "Omega_Zero" in boss and not camera_signal:
			camera_signal = true
			Event.disconnect("boss_start",self,"on_boss_start")
			Event.disconnect("boss_health_appear",self,"on_boss_start")
			Event.disconnect("is_boss_2",self,"on_boss_start")
			background_oz.playing = true
			update_fight_limit()

func set_background() -> void:
	background_zero.visible = false
	background_oz.visible = false
	if CharacterManager.player_character == "X":
		background_zero.visible = true
	else:
		background_oz.visible = true

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
		Tools.timer(3.0, "disabled_wall", self)

func handle_player() -> void:
	if is_instance_valid(GameManager.player):
		if GameManager.player.is_executing("Ride"):
			GameManager.player.get_parent().void_touch()

func disabled_wall() -> void :
	invisible_wall1.set_deferred("disabled", true)
	invisible_wall2.set_deferred("disabled", true)

func update_fight_limit() -> void :
	fight_limit.disabled = false
	next_limit.disabled = true
	disabled_wall()
	GameManager.camera.update_area_limits(fight_limit)
	GameManager.camera.start_door_translate(fight_limit.global_position, fight_limit, false)
