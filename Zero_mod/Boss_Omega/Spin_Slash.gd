extends AttackAbility

onready var boss_ai = get_parent().get_node("BossAI")

export var beamwave = preload("res://Zero_mod/Boss_Omega/Projectile/BeamWave.tscn")
export var beamwave_omega = preload("res://Zero_mod/Boss_Omega/Projectile/BeamWave_Omega.tscn")
export var beamwave_omega_big = preload("res://Zero_mod/Boss_Omega/Projectile/BeamWave_Omega_Big.tscn")
export var light_beam = preload("res://Zero_mod/Boss_Omega/Projectile/Light_Beam.tscn")

onready var damage: Node2D = $"../Damage"

onready var spinslash: Node2D = $"../animatedSprite/SaberCombo/spinslash"
onready var saber1: Node2D = $"../animatedSprite/SaberCombo/saber1"
onready var saber2: Node2D = $"../animatedSprite/SaberCombo/saber2"
onready var saber3: Node2D = $"../animatedSprite/SaberCombo/saber3"

onready var dash_smoke: Particles2D = $"../animatedSprite/Dash Smoke Particles"

onready var main = get_parent()
onready var awakened = get_parent().get_node("Desperation")
onready var sfx_saber1: AudioStreamPlayer = get_parent().get_node("saber")
onready var sfx_saber2: AudioStreamPlayer = get_parent().get_node("saber2")
onready var sfx_saber3: AudioStreamPlayer = get_parent().get_node("saber3")
onready var sfx_dash: AudioStreamPlayer = get_parent().get_node("dash")
onready var sfx_jump: AudioStreamPlayer = get_parent().get_node("jump")
onready var sfx_land: AudioStreamPlayer = get_parent().get_node("land")
onready var sfx_break: AudioStreamPlayer = get_parent().get_node("break")
onready var sfx_zbuster: AudioStreamPlayer = get_parent().get_node("zbuster")
onready var sfx_swordwave: AudioStreamPlayer = get_parent().get_node("swordwave")
onready var sfx_shingetsurin: AudioStreamPlayer = get_parent().get_node("shingetsurin")
onready var sfx_recover: AudioStreamPlayer = get_parent().get_node("heal_sound")
onready var sfx_oz_dash: AudioStreamPlayer = get_parent().get_node("oz_dash")
onready var sfx_oz_voice_1: AudioStreamPlayer = get_parent().get_node("oz_voice_1")
onready var sfx_oz_voice_2: AudioStreamPlayer = get_parent().get_node("oz_voice_2")
onready var sfx_oz_voice_3: AudioStreamPlayer = get_parent().get_node("oz_voice_3")
onready var sfx_oz_rising_saber: AudioStreamPlayer = get_parent().get_node("oz_rising_saber")
onready var sfx_oz_charge_saber: AudioStreamPlayer = get_parent().get_node("oz_charge_saber")
onready var sfx_oz_buster: AudioStreamPlayer = get_parent().get_node("oz_shot")
onready var sfx_oz_charge: AudioStreamPlayer = get_parent().get_node("oz_charge")
onready var sfx_oz_messenkou: AudioStreamPlayer = get_parent().get_node("oz_messenkou")
onready var sfx_oz_tenshouha: AudioStreamPlayer = get_parent().get_node("oz_tenshouha")
onready var sfx_oz_tenshouha_crash: AudioStreamPlayer = get_parent().get_node("oz_tenshouha_crash")

var dash_speed: = 400
var chance = randf() * 100
var slash_damage: float = 4
var crash_beam_damage: float = 8

func _ready():
	beam_1.visible = false
	beam_2.visible = false
	beam_3.visible = false

func _Setup() -> void :
	turn_and_face_player()
	play_animation("idle")
	chance = randf() * 100
	dash_speed = 400 + awakened.use_awakened_time * 50
	spinslash.damage = 5 + awakened.use_awakened_time
	saber1.damage = 3 + awakened.use_awakened_time
	saber2.damage = 4 + awakened.use_awakened_time
	saber3.damage = 5 + awakened.use_awakened_time
	slash_damage = 5 + awakened.use_awakened_time
	crash_beam_damage = 8 + awakened.use_awakened_time
	if not main.only_x:
		spinslash.scale.x = 1.2
		saber1.scale.x = 1.2
		saber2.scale.x = 1.2
		saber3.scale.x = 1.2
		spinslash.scale.y = 1.2
		saber1.scale.y = 1.2
		saber2.scale.y = 1.2
		saber3.scale.y = 1.2
	else:
		spinslash.scale.x = 1.0
		saber1.scale.x = 1.0
		saber2.scale.x = 1.0
		saber3.scale.x = 1.0
		spinslash.scale.y = 1.0
		saber1.scale.y = 1.0
		saber2.scale.y = 1.0
		saber3.scale.y = 1.0

func _Update(delta: float) -> void :
	if animatedSprite.animation == "fall" and awakened.use_awakened_time >= 2:
		default_gravity = 7200
	else:
		default_gravity = 900

	if not animatedSprite.animation == "dash":
		process_gravity(delta)
	
	if attack_stage == 0:
		if chance <= 20 and is_player_nearby_horizontally(128.0) or is_player_above(128):
			go_to_attack_stage(12)
		else:
			play_animation("jump")
			force_movement(dash_speed * 0.75)
			set_vertical_speed( - 300)
			sfx_jump.play()
			call_deferred("decay_speed", 1, 1.25)
			next_attack_stage()
	
	elif attack_stage == 1 and timer > 0.1:
		if get_vertical_speed() > 0:
			if is_player_nearby_horizontally(192.0) and chance > 70:
				play_animation("dash")
				sfx_dash.play()
				if not main.only_x:
					sfx_oz_dash.play()
				force_movement(dash_speed)
				timer = 0
				go_to_attack_stage(6)
			else:
				play_animation("jump")
				force_movement(dash_speed * 0.75)
				set_vertical_speed( - 300)
				sfx_jump.play()
				call_deferred("decay_speed", 1, 1.25)
				next_attack_stage()
	
	elif attack_stage == 2 and timer > 0.1:
		if get_vertical_speed() > 0:
			if is_player_nearby_horizontally(128.0):
				play_animation_again("saber_ensuizan")
				sfx_saber3.play()
				if not main.only_x:
					sfx_oz_charge_saber.play()
				spinslash.activate()
				beamwave_1()
				next_attack_stage()
			else:
				go_to_attack_stage(4)
		
	elif attack_stage == 3 and timer > 0.1:
		force_movement(0)
		set_vertical_speed(0)
		if has_finished_last_animation():
			kill_tweens(tween_list)
			spinslash.deactivate()
			play_animation("fall")
			next_attack_stage()
		
	elif attack_stage == 4 and timer > 0.1:
		if get_vertical_speed() > 0:
			kill_tweens(tween_list)
			play_animation("fall")
			next_attack_stage()
		
	elif attack_stage == 5 and timer > 0.1:
		if character.is_on_floor():
			play_animation("recover")
			sfx_land.play()
			force_movement(0)
			go_to_attack_stage(20)
	
	elif attack_stage == 6:
		if timer > 0.5 or is_player_nearby_horizontally(24) and not is_player_above(20):
			kill_tweens(tween_list)
			force_movement(200)
			if chance > 75:
				play_animation_again("saber_ensuizan")
				sfx_saber3.play()
				if not main.only_x:
					sfx_oz_charge_saber.play()
				spinslash.activate()
			else:
				play_animation("fall")
			go_to_attack_stage(7)
		else:
			force_movement(dash_speed)
	
	elif attack_stage == 7 and timer > 0.1:
		if character.is_on_floor():
			turn_and_face_player()
			play_animation("recover")
			sfx_land.play()
			force_movement(0)
			spinslash.deactivate()
			chance = randf() * 100
			if chance <= 20 and is_player_nearby_horizontally(128.0):
				go_to_attack_stage(12)
			else:
				if is_player_nearby_horizontally(128):
					next_attack_stage()
				else:
					go_to_attack_stage(20)
	
	elif attack_stage == 8 and timer > 0.1 and has_finished_last_animation():
		play_animation("saber_1")
		sfx_saber1.play()
		if not main.only_x:
			sfx_oz_voice_1.play()
		saber1.activate()
		next_attack_stage()
	
	elif attack_stage == 9 and timer > 0.1 and has_finished_last_animation():
		play_animation("saber_2")
		sfx_saber2.play()
		if not main.only_x:
			sfx_oz_voice_2.play()
		saber2.activate()
		saber1.deactivate()
		next_attack_stage()
	
	elif attack_stage == 10 and timer > 0.1 and has_finished_last_animation():
		play_animation("saber_3")
		sfx_saber3.play()
		if not main.only_x:
			sfx_oz_voice_3.play()
		saber3.activate()
		saber2.deactivate()
		next_attack_stage()
	
	elif attack_stage == 11 and timer > 0.1 and has_finished_last_animation():
		saber3.deactivate()
		chance = randf() * 100
		if chance >= 80:
			next_attack_stage()
		else:
			go_to_attack_stage(20)
	
	elif attack_stage == 12 and timer > 0.1:
		play_animation("messenkou_start")
		max_beam_offset = 32
		beam_1_offset = 0
		beam_2_offset = 1.57
		beam_3_offset = 3.14
		next_attack_stage()
			
	elif attack_stage == 13 and timer > 0.1:
		if animatedSprite.animation == "messenkou_start":
			crash_beam_rotation(delta)
		if has_finished_last_animation():
			play_animation("messenkou_long")
			beam_1.visible = false
			beam_2.visible = false
			beam_3.visible = false
			damage.deactivate()
			create_crash_beam(global_position)
			if not main.only_x:
				sfx_oz_tenshouha.play()
			sfx_oz_tenshouha_crash.play()
			if awakened.first_awakened:
				main.crash_beam_recover_health()
			next_attack_stage()
	
	elif attack_stage == 14 and timer > 0.1 and has_finished_last_animation():
		go_to_attack_stage(20)
	
	elif attack_stage == 20:
		damage.activate()
		EndAbility()

var max_beam_offset: float = 32
var beam_1_offset: float = 0
var beam_2_offset: float = 1.57
var beam_3_offset: float = 3.14

onready var beam_1 = animatedSprite.get_node("crash_beam")
onready var beam_2 = animatedSprite.get_node("crash_beam2")
onready var beam_3 = animatedSprite.get_node("crash_beam3")

func crash_beam_rotation(delta: float) -> void :
	if max_beam_offset > 0:
		max_beam_offset -= delta * 100
		beam_1_offset -= delta * 15
		beam_2_offset -= delta * 15
		beam_3_offset -= delta * 15
		beam_1.visible = true
		beam_2.visible = true
		beam_3.visible = true
	beam_1.position.x = 0 + max_beam_offset * sin(beam_1_offset)
	beam_2.position.x = 0 + max_beam_offset * sin(beam_2_offset)
	beam_3.position.x = 0 + max_beam_offset * sin(beam_3_offset)

func _Interrupt() -> void :
	._Interrupt()
	damage.activate()
	spinslash.deactivate()
	saber1.deactivate()
	saber2.deactivate()
	saber3.deactivate()
	dash_smoke.emitting = false

func beamwave_1():
	if character.facing_right:
		create_beamwave(global_position, 300, 0, 0)
	else:
		create_beamwave(global_position, 300, 0, 180)
	Tools.timer(0.03, "beamwave_2", self)

func beamwave_2():
	if character.facing_right:
		create_beamwave(global_position, 259, 150, 30)
	else:
		create_beamwave(global_position, 259, 150, 150)
	Tools.timer(0.03, "beamwave_3", self)

func beamwave_3():
	if character.facing_right:
		create_beamwave(global_position, 150, 259, 60)
	else:
		create_beamwave(global_position, 150, 259, 120)
	Tools.timer(0.03, "beamwave_4", self)

func beamwave_4():
	create_beamwave(global_position, 0, 300, 90)
	Tools.timer(0.03, "beamwave_5", self)

func beamwave_5():
	if character.facing_right:
		create_beamwave(global_position, -150, 259, 120)
	else:
		create_beamwave(global_position, -150, 259, 60)
	Tools.timer(0.03, "beamwave_6", self)

func beamwave_6():
	if character.facing_right:
		create_beamwave(global_position, -259, 150, 150)
	else:
		create_beamwave(global_position, -259, 150, 30)
	Tools.timer(0.03, "beamwave_7", self)

func beamwave_7():
	if character.facing_right:
		create_beamwave(global_position, -300, 0, 180)
	else:
		create_beamwave(global_position, -300, 0, 0)

func create_beamwave(ground_position, xspeed: float, yspeed: float, degrees: float) -> void :
	var instance = beamwave.instance()
	var beamwave_sprite = instance.get_node_or_null("animatedSprite")
	instance.can_deflect = false
	instance.get_node("DamageOnTouch").hit_through_invulnerability = false
	if main.only_x:
		instance = beamwave.instance()
	else:
		if awakened.use_awakened_time > 0:
			instance = beamwave_omega_big.instance()
		else:
			instance = beamwave_omega.instance()
	ground_position.y += 5
	instance.rotate_degrees(degrees)
	instance.set_horizontal_speed(xspeed * get_facing_direction())
	instance.set_vertical_speed(yspeed)
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.get_node("DamageOnTouch").damage = slash_damage
	instance.set_global_position(ground_position)
	instance.initialize(1)

func create_crash_beam(ground_position) -> void :
	var instance = light_beam.instance()
	ground_position.y += -7
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.get_node("DamageOnTouch").damage = crash_beam_damage
	instance.set_global_position(ground_position)
	instance.initialize(1)
