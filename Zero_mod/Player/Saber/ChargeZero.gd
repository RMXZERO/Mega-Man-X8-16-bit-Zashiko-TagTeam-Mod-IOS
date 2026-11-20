extends Ability

export  var super_charged_sound: AudioStream
var super_charge_time: = 3.0
var maximum_charge_time: = 5
export  var color: Color
export  var super_color: Color
var charged_time: float
var max_charge: bool
var mid_charge: bool
var charging: = false

export  var minimum_charge_time: = 0.5
export  var level_3_charge: = 1.75
export  var level_4_charge: = 2.75

export  var charge_time_reduction: = 0.0

var current_weapon
onready var audio2 = $audioStreamPlayer2
onready var charge1_volume = $audioStreamPlayer.volume_db
onready var charge2_volume = $audioStreamPlayer2.volume_db

onready var animatedSprite = character.get_node("animatedSprite")
onready var charging_particle = character.get_node("animatedSprite").get_node("ChargingParticle")
onready var charged_particle = character.get_node("animatedSprite").get_node("ChargedParticle")
onready var super_particle = character.get_node("animatedSprite").get_node("SuperChargeParticle")

onready var particles = [charging_particle, charged_particle, super_particle]

onready var tween: = TweenController.new(self)
signal stop
var only_ones_time: bool = false

func _ready() -> void :
	Event.listen("pause_menu_opened", self, "on_pause")
	Event.listen("pause_menu_closed", self, "on_unpause")
	audio = get_node("audioStreamPlayer")
	audio2 = get_node("audioStreamPlayer2")
	Tools.timer_p(0.1, "set_deferred", self, ["debug_logs", false])
	actions[0] = "fire"
	if CharacterManager.black_zero_armor or CharacterManager.awakened_zero_armor:
		charge_time_reduction = 0.5

func on_pause():
	if executing:
		audio.set_stream_paused(true)
		audio2.set_stream_paused(true)
		tween.pause()

func on_unpause():
	if executing:
		audio.set_stream_paused(false)
		audio2.set_stream_paused(false)
		tween.unpause()

	
func _Setup():
	setup_charge_fadeout()
	set_current_charge_button()

func setup_charge_fadeout() -> void :
	audio.volume_db = charge1_volume
	audio2.volume_db = charge2_volume
	sound.loop = true
	super_charged_sound.loop = true
	if Configurations.get("ChargeFadeOut"):
		tween.create(Tween.EASE_IN_OUT, Tween.TRANS_LINEAR, true)
		tween.add_attribute("volume_db", - 80.0, 65.0, audio)
		tween.add_attribute("volume_db", - 80.0, 65.0, audio2)
		tween.set_ignore_pause_mode()

func _process(_delta: float) -> void :
	BANDAID_stop_audio_if_not_executing()

func BANDAID_stop_audio_if_not_executing():
	if audio.playing or audio2.playing:
		if not executing:
			stop_vfx()
			Log("Forcefully stopped undesired playing sound")

func _StartCondition() -> bool:
	if not CharacterManager.extra_saber_combo:
		return false
	if not CharacterManager.extra_saber_06 and not CharacterManager.extra_saber_07:
		return false
	if animatedSprite.animation == "charge_sentsuizan" or animatedSprite.animation == "charge_saber_jump" or animatedSprite.animation == "charge_saber_land":
		return false
	if not CharacterManager.betazero_activated:
		if not character.saber_node.current_weapon.name == "Saber"and \
		not character.saber_node.current_weapon.name == "B-Fan" and \
		not character.saber_node.current_weapon.name == "D-Glaive" and \
		not character.saber_node.current_weapon.name == "Sigma-Blade":
			return false
	if character.is_executing("Ryuenjin") or character.is_executing("Hyouryuushou"):
		return false
	if not character.is_executing("Ride") and not character.block_charging:
		if get_charge_pressed():
			return true
	return false

func _Update(_delta: float) -> void :
	effect_position()
	cancel_charge()
	if get_charge_released() and character.listening_to_inputs or get_charge_just_pressed() and character.listening_to_inputs:
		if charged_time > minimum_charge_time * (1 - charge_time_reduction):
			emit_fire_charged_signal(get_charge_level())
		else:
			EndAbility()
	elif get_charge_pressed():
		charge(_delta)
	else:
		if character.listening_to_inputs:
			EndAbility()

#	if not character.is_executing("Ride"):
#		if CharacterManager.auto_charge:
#			if CharacterManager.black_zero_armor and not CharacterManager.awakened_zero_armor:
#				return
#			if character.get_action_pressed("fire"):
#				if not only_ones_time:
#					Input.action_release(actions[0])
#					only_ones_time = true
#			else:
#				only_ones_time = false
#			if not character.get_action_pressed(actions[0]):
#				Input.action_press(actions[0])
				
	if not _StartCondition():
		EndAbility()

func EndAbility() -> void :
	.EndAbility()

func effect_position() -> void :
	if animatedSprite.animation == "dash":
		for particle in particles:
			if CharacterManager.betazero_activated:
				particle.position.x = 8
				particle.position.y = 8
			else:
				particle.position.x = 4
				particle.position.y = 0
	elif animatedSprite.animation == "jump" or animatedSprite.animation == "walljump":
		if animatedSprite.animation == "walljump" and animatedSprite.frame < 5:
			for particle in particles:
				particle.position.x = -6
				particle.position.y = -4
		else:
			for particle in particles:
				particle.position.x = 2
				particle.position.y = -8
	elif animatedSprite.animation == "fall":
		for particle in particles:
			particle.position.x = 2
			particle.position.y = -8
	elif animatedSprite.animation == "slide":
		for particle in particles:
			if CharacterManager.betazero_activated:
				particle.position.x = 6
				particle.position.y = -4
			else:
				particle.position.x = 6
				particle.position.y = 0
	elif animatedSprite.animation == "walk":
		for particle in particles:
			particle.position.x = 4
			particle.position.y = -4
	else:
		for particle in particles:
			if CharacterManager.betazero_activated:
				particle.position.x = -4
				particle.position.y = 0
			else:
				particle.position.x = -2
				particle.position.y = -2
	set_colors()

func set_colors():
	var material = character.get_material()
	if material is ShaderMaterial:
		color = material.get_shader_param("R_MainColor2")
		super_color = material.get_shader_param("R_MainColor1")

func cancel_charge() -> void :
	if CharacterManager.black_zero_armor and not CharacterManager.awakened_zero_armor:
		if character.is_executing("Intro") or \
		character.is_executing("Finish") or \
		character.is_executing("Tenshouha") or \
		character.is_executing("Juuhazan") or \
		character.is_executing("Rasetsusen") or \
		character.is_executing("Raikousen") or \
		character.is_executing("Youdantotsu") or \
		character.is_executing("Hyouryuushou") or \
		character.is_executing("Enkoujin") or \
		character.is_executing("Genmuzero") or \
		character.is_executing("Desperation") or \
		character.is_executing("Rekuhouha") or \
		character.is_executing("Ryuenjin") or \
		character.is_executing("Enkoujin_Extra"):
			EndAbility()

onready var charge_button = get_default_charge_button()

func get_default_charge_button() -> String:
	return "fire"

func get_charge_pressed() -> bool:
	return get_action_pressed(actions[0])

func set_current_charge_button() -> void :
	if get_action_pressed(actions[0]):
		charge_button = actions[0]
	elif get_action_pressed(actions[1]):
		charge_button = actions[1]

func get_charge_just_pressed() -> bool:
	return get_action_just_pressed(charge_button)

func get_charge_released() -> bool:
	return not get_action_pressed(charge_button)

func get_charge_level() -> int:
	if charged_time < minimum_charge_time * (1 - charge_time_reduction):
		return 0
	if charged_time < level_3_charge * (1 - charge_time_reduction):
		return 1
	if charged_time < level_4_charge * (1 - charge_time_reduction):
		return 2
	if charged_time > level_4_charge * (1 - charge_time_reduction):
		return 3
	return 0

func _EndCondition() -> bool:
	if charged_time == 0 and timer > 0.1:
		return true
	if charged_time < minimum_charge_time * (1 - charge_time_reduction) and not get_charge_pressed():
		return true
	if character.is_executing("Ride"):
		return true
	return false
	
func charge(_delta: float):
	if charged_time < maximum_charge_time:
		charged_time += _delta
	if charged_time > minimum_charge_time * (1 - charge_time_reduction):
		if not charging:
			start_vfx()
	if get_charge_level() > 1:
		if not mid_charge:
				emit_charged_particle()
				mid_charge = true
	if not max_charge:
		if super_charge_time > 0 and charged_time > level_4_charge * (1 - charge_time_reduction):
			Log("Started super VFX")
			max_charge = true
			change_color(super_color)
			emit_supercharge_particle()
			play_super_sound()

func emit_fire_charged_signal(_charged_time):
	if character.listening_to_inputs:
		Log("Shot Release")
		Event.emit_signal("charged_shot_release", _charged_time)
	EndAbility()

func start_vfx():
	Log("Started VFX")
	play_sound(sound, false)
	emit_charging_particle()
	enable_charge_shader()
	change_color(color)
	charging = true

func stop_vfx():
	stop_sound()
	stop_emission()
	disable_charge_shader()
	change_color(color)
	charging = false
	mid_charge = false
	max_charge = false
	Log("Stopped VFX")

func play_super_sound():
	audio2.stream = super_charged_sound
	audio2.play()
	audio.stop()

func stop_sound():
	.stop_sound()
	audio2.stop()

func emit_charging_particle():
	for particle in particles:
		particle.visible = false
	charging_particle.visible = true
	
func emit_charged_particle():
	for particle in particles:
		particle.visible = false
	charged_particle.visible = true
	
func emit_supercharge_particle():
	for particle in particles:
		particle.visible = false
	super_particle.visible = true
	
func stop_emission():
	for particle in particles:
		particle.visible = false

func change_color(_color):
	character.animatedSprite.material.set_shader_param("Color", _color)
	
func enable_charge_shader():
	character.animatedSprite.material.set_shader_param("Charge", 1)

func disable_charge_shader():
	character.get_node("animatedSprite").material.set_shader_param("Charge", 0)

func _Interrupt():
	charged_time = 0
	stop_vfx()
	emit_signal("stop")

func play_sound_on_initialize() -> void :
		pass
		
func should_execute_on_hold() -> bool:
	return true

func should_always_listen_to_inputs() -> bool:
	return true
