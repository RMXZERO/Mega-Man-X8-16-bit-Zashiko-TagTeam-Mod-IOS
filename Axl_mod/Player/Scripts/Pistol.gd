extends WeaponAxl
class_name Pistol

export  var weapon: Resource
export  var _sprites_weapon: SpriteFrames
export  var _sprites_weapon_B: SpriteFrames

var bullet_count: int = 0

# AXL 이 기본 공격(총알)을 쏠 때 나오는 보이스 (캐릭터 루트 노드 이름 기준: Axl)
const ATTACK_VOICES := [
	"res://src/Actors/Player/AttackVoice/axl_gun_attack1.wav",
	"res://src/Actors/Player/AttackVoice/axl_gun_attack2.wav"
]
# 기존 전투 보이스(제로 콤보 보이스, 실제 재생 기준 약 -14.6dBFS RMS)와 체감 음량을 맞춘 파일별 볼륨
const ATTACK_VOICE_VOLUMES_DB := [-2.5, 0.0]
# 총알이 나갈 때 보이스가 나올 확률 (1.0 = 매번, 0.5 = 절반)
const ATTACK_VOICE_CHANCE := 1.0
var _attack_voice_streams: Array = []
var _attack_voice_player: AudioStreamPlayer = null


func _ready() -> void :
	._ready()
	Event.listen("shot_lemon", self, "on_lemon_shot_created")
	setup_attack_voice()

func setup_attack_voice() -> void :
	if character == null or character.name != "Axl":
		return
	for path in ATTACK_VOICES:
		var stream = load(path)
		if stream != null:
			_attack_voice_streams.append(stream)
	if _attack_voice_streams.empty():
		return
	_attack_voice_player = AudioStreamPlayer.new()
	_attack_voice_player.bus = "Voice"
	add_child(_attack_voice_player)

func play_attack_voice() -> void :
	if _attack_voice_player == null or _attack_voice_streams.empty():
		return
	# 연사 중 보이스가 겹치지 않게, 재생 중이면 새로 재생하지 않는다
	if _attack_voice_player.playing:
		return
	if ATTACK_VOICE_CHANCE < 1.0 and randf() > ATTACK_VOICE_CHANCE:
		return
	var index: int = randi() % _attack_voice_streams.size()
	_attack_voice_player.stream = _attack_voice_streams[index]
	_attack_voice_player.volume_db = ATTACK_VOICE_VOLUMES_DB[index]
	_attack_voice_player.play()

func fire(_charge_level: = 0) -> void :
	add_projectile_to_scene(0)
	play_attack_voice()
	reduce_ammo(ammo_per_shot)
	Event.emit_signal("shot", self)
	
func add_projectile_to_scene(charge_level: int) -> void :
	var shot_direction_node = character.get_node("ShotDirection")
	var _shot
	_shot = shots[charge_level].instance()
	var horizontal_dir = character.get_facing_direction()
	var vertical_dir = - 1
	if Input.is_action_pressed("move_up"):
		vertical_dir = - 1
	elif Input.is_action_pressed("move_down"):
		vertical_dir = 1
		
	character.get_node("offset manager").get_offset()
	shot_direction_node.projectile_speed_control(_shot, bullet_speed * extra_speed, horizontal_dir, vertical_dir)
	bullet_count += 1
	if bullet_count >= 8:
		_shot.blue_bullet = true
		bullet_count = 0
	get_tree().current_scene.add_child(_shot, true)
	position_shot(_shot)
	connect_shot_event(_shot)
	_shot.damage = projectile_damage * extra_damage
	_shot.damage_to_bosses = projectile_damage_to_bosses * extra_damage
	_shot.damage_to_weakness = projectile_damage_to_weakness * extra_damage
	Event.emit_signal("shot_lemon", self, _shot)

func on_lemon_shot_created(emitter, shot) -> void :
	if emitter != self:
		connect_shot_event(shot)

func has_ammo() -> bool:
	return shots_currently_alive < max_shots_alive

func connect_charged_shot_event(_shot) -> void :
	_shot.connect("projectile_started", self, "on_charged_shot_created")
	_shot.connect("projectile_end", self, "on_charged_shot_end")
	if _shot.has_method("set_creator"):
		_shot.set_creator(arm_cannon.character)
	if _shot.has_method("initialize"):
		_shot.call_deferred("initialize", arm_cannon.character.get_facing_direction())
