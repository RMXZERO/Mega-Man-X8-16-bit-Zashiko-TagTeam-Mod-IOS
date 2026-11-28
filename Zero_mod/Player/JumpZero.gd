extends FallZero
class_name JumpZero

export  var max_jump_time: = 0.625
export  var leeway_time: = 0.1
export  var fullspeed_proportion: = 0.19
export  var minimum_upwards_time: = 0.0
var fullspeed_time: = 0.0
var slowdown_time: = 0.0
var stopped_input: = false
onready var jumpanimatedSprite = get_parent().get_node("animatedSprite")

func _ready() -> void :
	if active:
		character.listen("headbump", self, "on_headbump")

func _StartCondition() -> bool:
	var _animation = get_parent().get_animation()
	if _animation in character.saber_animations:
		return false
	if character.has_just_been_on_floor(leeway_time) and character.get_last_used_ability() != "DashJump":
		return true
	return false

func _EndCondition() -> bool:
	var _animation = get_parent().get_animation()
	if _animation in character.saber_animations:
		if "saber_jump" in _animation:
			return false
		if "saber_ensuizan" in _animation:
			return false
		if "charge_saber_jump" in _animation:
			return false
		return true
	if character.is_on_floor() and changed_animation:
		on_touch_floor()
		return true
	return false
func get_activation_leeway_time() -> float:
	if not character.is_executing("Jump"):
		return leeway_time
	return 0.0

# Zero 가 점프할 때 나오는 보이스 (캐릭터 루트 노드 이름 기준: Zero)
# 태그 보이스와 같은 음량(실제 재생 기준 약 -19.8dBFS RMS)으로 맞춘 볼륨
const JUMP_VOICE_PATH := "res://src/Actors/Player/JumpVoice/zero_jump.wav"
const JUMP_VOICE_VOLUME_DB := -9.1

func play_jump_voice() -> void :
	if character == null or character.name != "Zero":
		return
	# 점프 / 대시점프 / 벽차기 등이 같은 플레이어 노드를 공유한다
	var voice_player = character.get_node_or_null("JumpVoice")
	if voice_player == null:
		var stream = load(JUMP_VOICE_PATH)
		if stream == null:
			return
		voice_player = AudioStreamPlayer.new()
		voice_player.name = "JumpVoice"
		voice_player.stream = stream
		voice_player.bus = "Voice"
		voice_player.volume_db = JUMP_VOICE_VOLUME_DB
		character.add_child(voice_player)
	voice_player.play()

func _Setup() -> void :
	emit_jump_signal()
	play_jump_voice()
	fullspeed_time = 0
	slowdown_time = 0
	changed_animation = false
	stopped_input = false
	character.set_vertical_speed(0)
	zero_bonus_horizontal_speed()

func emit_jump_signal():
	character.emit_signal("jump")

func _Update(_delta: float) -> void :
	if_no_input_zero_vertical_speed()
	ascent_with_slowdown_after_delay(_delta)
	._Update(_delta)
	if jumpanimatedSprite.animation == "jump":
		if jumpanimatedSprite.frame >= 15:
			jumpanimatedSprite.frame = 3

func if_no_input_zero_vertical_speed() -> void :
	if character.get_vertical_speed() < 0:
		if no_input_after_minimum_time():
			character.set_vertical_speed(0)
			stopped_input = true

func no_input_after_minimum_time() -> bool:
	return timer > minimum_upwards_time and Input.get_action_strength(actions[0]) == 0

func change_animation_if_falling(_s) -> void :
	if not changed_animation:
		if character.get_animation() != "fall":
			if character.get_vertical_speed() > 0:
				EndAbility()
				
func ascent_with_slowdown_after_delay(_delta: float) -> void :
	if not stopped_input and calculate_slowdown_value() != 0:
		if can_go_up_at_full_velocity():
			character.set_vertical_speed( - jump_plus_ground_velocity)
			fullspeed_time = fullspeed_time + _delta
		else:
			character.set_vertical_speed( - jump_plus_ground_velocity * calculate_slowdown_value())
			slowdown_time = slowdown_time + _delta

func can_go_up_at_full_velocity() -> bool:
	return fullspeed_time / max_jump_time < fullspeed_proportion

func calculate_slowdown_value() -> float:
	var sv = (max_jump_time - fullspeed_time) - slowdown_time / (max_jump_time - fullspeed_time)
	if sv < 0:
		return 0.0
	return sv

func on_headbump() -> void :
	if executing:
		character.set_vertical_speed(0)
		stopped_input = true

func play_animation_on_initialize():
	if animation:
		character.play_animation(animation)

func emit_land_sounds_on_event():
	pass
