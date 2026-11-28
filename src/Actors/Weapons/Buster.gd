extends Weapon
class_name Buster

# X 가 차지샷(차지 단계 1 이상)을 쏠 때 나오는 보이스 (캐릭터 루트 노드 이름 기준: X)
const CHARGE_VOICES := [
	"res://src/Actors/Player/AttackVoice/x_buster_attack1.wav",
	"res://src/Actors/Player/AttackVoice/x_buster_attack2.wav"
]
# 태그 보이스와 같은 음량(실제 재생 기준 약 -21.7dBFS RMS)으로 맞춘 파일별 볼륨
const CHARGE_VOICE_VOLUMES_DB := [-9.7, -10.6]
var _charge_voice_streams: Array = []
var _charge_voice_player: AudioStreamPlayer = null

func _ready() -> void :
	._ready()
	Event.listen("shot_lemon", self, "on_lemon_shot_created")
	setup_charge_voice()

func setup_charge_voice() -> void :
	if character == null or character.name != "X":
		return
	for path in CHARGE_VOICES:
		var stream = load(path)
		if stream != null:
			_charge_voice_streams.append(stream)
	if _charge_voice_streams.empty():
		return
	_charge_voice_player = AudioStreamPlayer.new()
	_charge_voice_player.bus = "Voice"
	add_child(_charge_voice_player)

func play_charge_voice() -> void :
	if _charge_voice_player == null or _charge_voice_streams.empty():
		return
	# 이전 보이스가 아직 재생 중이면 겹쳐서 끊기지 않게 새로 재생하지 않는다
	if _charge_voice_player.playing:
		return
	var index: int = randi() % _charge_voice_streams.size()
	_charge_voice_player.stream = _charge_voice_streams[index]
	_charge_voice_player.volume_db = CHARGE_VOICE_VOLUMES_DB[index]
	_charge_voice_player.play()

func on_lemon_shot_created(emitter, shot: KinematicBody2D) -> void :
	if emitter != self:
		connect_shot_event(shot)

func add_projectile_to_scene(charge_level: int):
	var shot: KinematicBody2D = .add_projectile_to_scene(charge_level)
	if charge_level < 1:
		Event.emit_signal("shot_lemon", self, shot)
	else:
		play_charge_voice()
	shot.damage *= extra_damage
	shot.damage_to_bosses *= extra_damage
	shot.damage_to_weakness *= extra_damage

func has_ammo() -> bool:
	return shots_currently_alive < max_shots_alive

func connect_charged_shot_event(_shot: KinematicBody2D) -> void :
	_shot.connect("projectile_started", self, "on_charged_shot_created")
	_shot.connect("projectile_end", self, "on_charged_shot_end")
	if _shot.has_method("set_creator"):
		_shot.set_creator(arm_cannon.character)
	if _shot.has_method("initialize"):
		_shot.call_deferred("initialize", arm_cannon.character.get_facing_direction())
