extends Area2D

var activated: = false
var camera_signal: bool = false
onready var next_limit: Area2D = $"../../Limits/djsigma"
onready var fight_limit: Area2D = $"../../Limits/djsigmafight"
onready var music: AudioStreamPlayer = $"../../Music Player"
onready var foreground: ParallaxLayer = $"../../parallaxBackground2/foreground"
onready var not_sound_change: = preload("res://Zero_mod/SFX/no_sound.ogg")
onready var invisible_wall1: CollisionShape2D = $invisible_wall/collisionShape2D
onready var invisible_wall2: CollisionShape2D = $invisible_wall/collisionShape2D2
onready var djsigmaground: TileMap = $"../../Scenery/CollisionDJSigma/CollisionDJSigma"
onready var djsigmaground2: TileMap = $"../../Scenery/CollisionDJSigma/CollisionDJSigma2"
onready var boss_djsigma: Node2D = $"../DJSigmaSpawner"
onready var djsigma_background: Node2D = $"../../DJSigmaStarter"

func _ready() -> void:
	Event.connect("boss_start",self,"on_boss_start")
	Event.connect("boss_health_appear",self,"on_boss_start")
	Event.connect("is_boss_2",self,"on_boss_start_2")

func on_boss_start(boss) -> void:
	if "DJSigma" in boss.name and not camera_signal:
		camera_signal = true
		update_fight_limit()
		if djsigma_background:
			djsigma_background.queue_free()

func on_boss_start_2(boss) -> void:
	if "DJSigma" in boss and not camera_signal:
		camera_signal = true
		update_fight_limit()
		if djsigma_background:
			djsigma_background.queue_free()

func _on_body_entered(_body: Node) -> void :
	if not activated:
		activated = true
		if GameManager.has_beaten_the_game():
			foreground.visible = false
			music.start_fade_out()
			boss_djsigma.spawn()
			disabled_wall()
			handle_player()
			Event.emit_signal("show_warning")
			Tools.timer(3.5, "spawn_boss", self)

func handle_player() -> void:
	if is_instance_valid(GameManager.player):
		if GameManager.player.is_executing("Ride"):
			GameManager.player.get_parent().void_touch()
	if is_instance_valid(GameManager.player):
		GameManager.player.interrupt_all_moves()
		GameManager.player.cutscene_deactivate()
	GameManager.start_cutscene()

func spawn_boss() -> void :
	Event.emit_signal("teleport_to_dj_sigma")
	Event.emit_signal("end_teleport_to_dj_sigma")

func disabled_wall() -> void :
	djsigma_background.visible = false
	djsigmaground.visible = true
	djsigmaground2.visible = false
	invisible_wall1.set_deferred("disabled", false)
	invisible_wall2.set_deferred("disabled", false)
	
func update_fight_limit() -> void :
	fight_limit.disabled = false
	next_limit.disabled = true
	GameManager.camera.update_area_limits(fight_limit)
	GameManager.camera.start_door_translate(fight_limit.global_position, fight_limit, false)
