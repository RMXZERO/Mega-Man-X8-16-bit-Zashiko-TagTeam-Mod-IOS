extends Node2D

const beats: Array = [0.01, 1.66, 3.32, 4.97, 5.59, 10.8]

# 보스 이름이 뜨는 순간(5.59초, final_beat)에 재생되는 보스 보이스
# name_id(StageInfo) -> 보이스 파일 이름
const BOSS_VOICE_DIR := "res://src/Actors/Bosses/BossIntro/BossVoice/"
const BOSS_VOICES := {
	"PANDA": "BambooPandamonium",
	"YETI": "AvalancheYeti",
	"MANOWAR": "GigaboltManowar",
	"ROOSTER": "BurnRooster",
	"TRILOBYTE": "EarthrockTrilobyte",
	"MANTIS": "DarkMantis",
	"ANTONION": "GravityAntonion",
	"SUNFLOWER": "OpticSunflower",
}
# BGM(약 -19 dB) 위로 들리도록 맞춘 값. 크면 올리고 작으면 내린다
const BOSS_VOICE_VOLUME_DB := -2.0

export  var stage_info: Resource
export  var debug_logs: bool = false

onready var flash_bg: Sprite = $white_flash
onready var fadeout: Sprite = $fadeout
onready var red_bg: AnimatedSprite = $red_bg
onready var sparks: AnimatedSprite = $sparks
onready var boss: AnimatedSprite = $boss

onready var objects: Node2D = $objects
onready var ring: Sprite = $objects / ring
onready var triangle: Sprite = $objects / triangle
onready var sigma: Sprite = $objects / sigma

onready var boss_name: Label = $ui_anchor / boss_name
onready var boss_name_shadow: Label = $ui_anchor / shadow

onready var tween: TweenController = TweenController.new(self)
onready var music: AudioStreamPlayer = $music
onready var music2: AudioStreamPlayer = $music2
onready var shake: AnimationPlayer = $animationPlayer

var ending: bool = false
var animations: Array
var _boss_voice_stream = null
var _boss_voice_player: AudioStreamPlayer = null

signal start
signal stop


func _input(event: InputEvent) -> void :
	if event.is_action_pressed("pause"):
		skip()

func skip() -> void :
	if not ending:
		tween.reset()
		if _boss_voice_player != null and is_instance_valid(_boss_voice_player):
			_boss_voice_player.stop()
		end()

func _ready() -> void :
	if GameManager.current_stage_info:
		stage_info = GameManager.current_stage_info
	call_deferred("prepare")
	Tools.timer(0.25, "start", self)

func prepare() -> void :
	if not stage_info.should_play_intro:
		stop()
		return
	Log("loading " + stage_info.get_name() + " intro sequence")
	toggle(sparks)
	toggle(boss_name)
	toggle(boss_name_shadow)
	toggle(boss)
	toggle(objects)
	toggle(red_bg)
	boss_name.text = stage_info.get_boss()
	boss_name_shadow.text = stage_info.get_boss()
	_load_boss_voice()
	boss.frames = stage_info.sprite_frames
	animations = stage_info.animation_beats
	if stage_info.inverse_sprites:
		boss.scale.x = - 1

func start() -> void :
	if ending:
		return
	emit_signal("start")
	tween.callback("zero_beat", beats[0])
	tween.callback("first_beat", beats[1])
	tween.callback("second_beat", beats[2])
	tween.callback("third_beat", beats[3])
	tween.callback("final_beat", beats[4])
	tween.callback("end", beats[5])
	if Configurations.exists("SongRemix"):
		if Configurations.get("SongRemix"):
			music2.play()
		else:
			music.play()

func zero_beat() -> void :
	Log("initial beat")
	toggle(red_bg)
	fade_in(red_bg)
	toggle(objects)
	move_in(ring, - 224)
	move_in(triangle)
	move_in(sigma, 224 * 2)
	flash_obj(ring, 0.1, 1.4)
	flash_obj(triangle, 0.25, 1)
	flash_obj(sigma, 3, 1.35)

func first_beat() -> void :
	Log("first beat")
	flash()
	shake.play("screenshake")
	sparks.visible = true

func second_beat() -> void :
	Log("second beat")
	objects.modulate = Color(0.75, 0.75, 0.75, 1)
	sprite_fade_in()

func third_beat() -> void :
	Log("third beat")
	boss.modulate = Color(1, 1, 1, 1)
	objects.modulate = Color(0.5, 0.5, 0.5, 1)
	fade_out_obj(sparks, 1.5)
	play_animation(1)
	Tools.timer(0.3, "extra_animation", self)
	flash(false)

func extra_animation() -> void :
	if animations.size() > 3:
		play_animation(2)

func final_beat() -> void :
	Log("final beat")
	toggle(sparks)
	toggle(boss_name)
	toggle(boss_name_shadow)
	objects.modulate = Color(0.25, 0.25, 0.25, 1)
	red_bg.modulate = Color(0.75, 0.75, 0.75, 1)
	play_animation(animations.size() - 1)
	flash()
	play_boss_voice()

func _load_boss_voice() -> void:
	_boss_voice_stream = null
	var voice_name = BOSS_VOICES.get(stage_info.name_id, "")
	if voice_name == "":
		return
	var path = BOSS_VOICE_DIR + voice_name + ".ogg"
	if ResourceLoader.exists(path):
		_boss_voice_stream = load(path)

func play_boss_voice() -> void:
	if _boss_voice_stream == null or ending:
		return
	_boss_voice_player = AudioStreamPlayer.new()
	_boss_voice_player.pause_mode = Node.PAUSE_MODE_PROCESS
	_boss_voice_player.stream = _boss_voice_stream
	_boss_voice_player.bus = "SFX"
	_boss_voice_player.volume_db = BOSS_VOICE_VOLUME_DB
	add_child(_boss_voice_player)
	_boss_voice_player.connect("finished", _boss_voice_player, "queue_free")
	_boss_voice_player.play()

func end() -> void :
	Log("end")
	ending = true
	fade_out_music()
	fade_out()

func fade_out_music() -> void :
	tween.attribute("volume_db", - 80.0, 1.0, music)
	tween.attribute("volume_db", - 80.0, 1.0, music2)

func flash(horizontal: bool = true) -> void :
	flash_bg.modulate = Color(70, 50, 30, 0.75)
	flash_bg.self_modulate.a = 1.0
	flash_bg.scale.y = 1.5
	flash_bg.scale.x = 1.5
	tween.create(Tween.EASE_OUT, Tween.TRANS_QUINT, true)
	if horizontal:
		tween.add_attribute("scale:y", 0.0, 0.4, flash_bg)
	else:
		tween.add_attribute("scale:x", 0.0, 0.4, flash_bg)
	tween.get_last().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.add_attribute("modulate", Color(30, 0, 0, 0.75), 0.2, flash_bg)
	tween.attribute("self_modulate:a", 0.0, 0.6, flash_bg)

func sprite_fade_in() -> void :
	toggle(boss)
	boss.modulate = Color(0, 0, 0, 1)
	fade_in(boss)
	play_animation(0)

func fade_out() -> void :
	fadeout.z_index = 100
	fadeout.scale.y = 1
	fadeout.modulate = Color(0, 0, 0, 0)
	tween.attribute("modulate", Color(0, 0, 0, 1), 0.5, fadeout)
	tween.add_callback("stop")

func stop() -> void :
	emit_signal("stop")
	Tools.timer(0.5, "start_level", self)

func start_level() -> void :
	GameManager.start_level(stage_info.get_load_name())

func move_in(obj: Node2D, initial_pos_y: = - 224 * 2) -> void :
	var original_y = obj.global_position.y
	obj.global_position.y = initial_pos_y
	tween.create(Tween.EASE_IN_OUT, Tween.TRANS_CUBIC)
	tween.add_attribute("global_position:y", original_y - initial_pos_y * 0.1, 1.1, obj)
	tween.get_last().set_ease(Tween.EASE_IN)
	tween.add_attribute("global_position:y", original_y, 0.5, obj)
	tween.add_callback("flash_obj", self, [obj, 3.0, 0.75])

func flash_obj(obj: Node2D, force: = 3.0, duration: = 0.5) -> void :
	var original_m = obj.modulate
	obj.modulate = Color(force, force, force, 1)
	tween.attribute("modulate", original_m, duration, obj)
	
func fade_in(obj: Node2D, duration: = 0.25) -> void :
	var original_m = obj.modulate
	obj.modulate = Color(0, 0, 0, 0)
	tween.attribute("modulate", original_m, duration, obj)

func fade_out_obj(obj: Node2D, duration: = 0.25) -> void :
	tween.attribute("modulate:a", 0.0, duration, obj)

func play_animation(index: int) -> void :
	if index < animations.size():
		boss.play(animations[index])

func toggle(obj) -> void :
	obj.visible = not obj.visible

func Log(message) -> void :
	if debug_logs:
		print("BossIntro: " + str(message))
