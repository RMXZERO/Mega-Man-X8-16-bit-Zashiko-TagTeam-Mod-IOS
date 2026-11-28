extends EventAbility
class_name CharacterSwitchWarpOut

# Edited version of "Finish.gd"

export  var beam_speed: = 690.0
var ascending: = false
onready var animatedSprite = get_parent().get_node("animatedSprite")

# 교대로 빠질 때 재생되는 캐릭터별 보이스 (목록/볼륨은 CharacterSwitchWarpIn 과 공유)
var _tag_voice_streams: Array = []
var _tag_rng := RandomNumberGenerator.new()


func _ready() -> void :
	animatedSprite.connect("animation_finished", self, "on_animation_finished")
	Event.listen("character_switch_end", self, "on_character_switch_end")
	_tag_rng.randomize()
	for path in CharacterSwitchWarpIn.TAG_VOICES.get(character.name, []):
		var stream = load(path)
		if stream != null:
			_tag_voice_streams.append(stream)

func on_character_switch_end() -> void:
	EndAbility()
	character.interrupt_all_moves()
	
func _Setup():
	character.deactivate()
	character.play_animation_backwards("beam_in")
	if CharacterSwitchWarpIn.TAG_VOICE_ON_WARP_OUT:
		play_tag_voice()

func play_tag_voice() -> void:
	if _tag_voice_streams.empty():
		return
	var player := AudioStreamPlayer.new()
	player.pause_mode = Node.PAUSE_MODE_PROCESS   # 교대 중 정지 상태에서도 재생
	player.stream = _tag_voice_streams[_tag_rng.randi() % _tag_voice_streams.size()]
	player.bus = "Voice"
	player.volume_db = CharacterSwitchWarpIn.TAG_VOICE_VOLUME_DB
	# 이 능력 노드는 교대 후 정지/숨김될 수 있으므로 현재 씬에 붙여 끝까지 재생
	get_tree().current_scene.add_child(player)
	player.connect("finished", player, "queue_free")
	player.play()

func _Update(_delta):
	if ascending:
		if animatedSprite.global_position.y <= character.global_position.y-224:
			character.hide()
			character.active = false
			ascending = false
			CharacterManager.try_character_switch_end()
		else:
			animatedSprite.global_position.y -= beam_speed * _delta
	
func on_animation_finished():
	if executing:
		if character.get_animation() == "beam_in":
			play_animation_once("beam")
			timer = 0
			ascending = true

func _EndCondition() -> bool:
	return false

func is_high_priority() -> bool:
	return true
