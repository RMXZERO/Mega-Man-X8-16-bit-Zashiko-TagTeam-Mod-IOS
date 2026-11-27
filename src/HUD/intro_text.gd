extends AnimatedSprite

export var duration := 1.2
export var warning_duration := 1.75
export var debug_mode := false
var timer := 0.0
onready var alert = $audioStreamPlayer2

# 스테이지 시작 시 READY 가 뜰 때 재생되는 소리 (SFX 버스)
const READY_SOUND_PATH := "res://src/HUD/ready.wav"
const READY_SOUND_VOLUME_DB := -4.0
# 검은 화면이 걷히며 READY 글자가 실제로 보이기 시작할 때까지 소리를 늦춘다 (초)
# 소리가 아직 이르면 값을 키우고, 늦으면 줄인다
const READY_SOUND_DELAY := 0.35
var _ready_stream = null

func _ready() -> void:
	_ready_stream = load(READY_SOUND_PATH)
	Event.listen("stage_start", self, "display_ready")
	Event.listen("show_warning",self,"display_warning")
	Event.listen("warning_done",self,"on_warning_done")

func _process(delta: float) -> void:
	if timer > 0:
		timer += delta
		handle_text()

func handle_text() -> void:
	if "ready" in animation:
		handle_intro_text()
	elif "warning" in animation:
		handle_boss_text() 

func handle_intro_text() -> void:
	if timer > duration:
		GameManager.emit_intro_signal()
		deactivate()

func handle_boss_text() -> void:
	if timer > warning_duration:
		Event.emit_signal("warning_done")

func on_warning_done() -> void:
	GameManager.start_boss()
	deactivate()
	

func deactivate():
	set_visible(false)
	timer = 0

func display_ready():
	set_visible(true)
	play("ready")
	_play_ready_sound()

func _play_ready_sound() -> void:
	if _ready_stream == null:
		return
	get_tree().create_timer(READY_SOUND_DELAY).connect("timeout", self, "_play_ready_sound_now")

func _play_ready_sound_now() -> void:
	if _ready_stream == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = _ready_stream
	player.bus = "SFX"
	player.volume_db = READY_SOUND_VOLUME_DB
	add_child(player)
	player.connect("finished", player, "queue_free")
	player.play()

func display_warning():
	if debug_mode:
		GameManager.start_boss()
		return
	set_visible(true)
	play("warning")
	alert.play()

func _on_animatedSprite_animation_finished() -> void:
	if not "blink" in get_animation():
		play (get_animation() + "_blink")
		timer = 0.01
