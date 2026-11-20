extends AttackAbility

onready var boss_ai = get_parent().get_node("BossAI")

export var messenkou = preload("res://Zero_mod/Boss_Omega/Projectile/Messenkou.tscn")
export var messenkou_effect = preload("res://Zero_mod/Boss_Omega/Projectile/Messenkou_Effect.tscn")
export var messenkou_omega = preload("res://Zero_mod/Boss_Omega/Projectile/Messenkou_Omega.tscn")

onready var risingsaber: Node2D = $"../animatedSprite/SaberCombo/risingsaber"
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

onready var rekohouha_sound: AudioStreamPlayer = get_parent().get_node("RekohouhaShot")
onready var ground_sound: AudioStreamPlayer = get_parent().get_node("ground")

var dash_speed: = 400
var slash_speed: = 250
var chance = randf() * 100
var shot_time: float = 0
var messenkou_damage: float = 4

func _Setup() -> void :
	turn_and_face_player()
	play_animation("idle")
	dash_speed = 400 + awakened.use_awakened_time * 50
	slash_speed = 150 + awakened.use_awakened_time * 50
	chance = randf() * 100
	risingsaber.damage = 5 + awakened.use_awakened_time
	saber1.damage = 3 + awakened.use_awakened_time
	saber2.damage = 4 + awakened.use_awakened_time
	saber3.damage = 5 + awakened.use_awakened_time
	messenkou_damage = 5 + awakened.use_awakened_time
	if not main.only_x:
		risingsaber.scale.x = 1.2
		risingsaber.scale.y = 1.2
		saber1.scale.x = 1.2
		saber2.scale.x = 1.2
		saber3.scale.x = 1.2
		saber1.scale.y = 1.2
		saber2.scale.y = 1.2
		saber3.scale.y = 1.2
	else:
		risingsaber.scale.x = 1.0
		risingsaber.scale.y = 1.0
		saber1.scale.x = 1.0
		saber2.scale.x = 1.0
		saber3.scale.x = 1.0
		saber1.scale.y = 1.0
		saber2.scale.y = 1.0
		saber3.scale.y = 1.0

func _Update(delta: float) -> void :
	process_gravity(delta)
	if animatedSprite.animation == "fall" and awakened.use_awakened_time >= 2:
		default_gravity = 7200
	else:
		default_gravity = 900
		
	if character.facing_right and character.get_horizontal_speed() < 0 or not character.facing_right and character.get_horizontal_speed() > 0:
		if animatedSprite.animation == "dash":
			force_movement(dash_speed)
	
	if attack_stage == 0:
		if is_player_nearby_horizontally(64) and chance > 50:
			go_to_attack_stage(7)
		else:
			kill_tweens(tween_list)
			play_animation("dash")
			sfx_dash.play()
			if not main.only_x:
				sfx_oz_dash.play()
			dash_smoke.emitting = true
			force_movement(dash_speed)
			next_attack_stage()
	
	elif attack_stage == 1 and timer > 0.1:
		if is_player_nearby_horizontally(64.0) or timer > 0.4:
			if is_player_nearby_vertically(128) and is_player_nearby_horizontally(64.0) and is_player_in_front():
				force_movement(0)
				play_animation("risingaber_ready")
				go_to_attack_stage(5)
			elif facing_a_wall() or timer > 0.4:
				next_attack_stage()
	
	elif attack_stage == 2 and timer > 0.2 and has_finished_last_animation():
		kill_tweens(tween_list)
		turn_and_face_player()
		force_movement(0)
		play_animation("idle")
		dash_smoke.emitting = false
		next_attack_stage()
			
	elif attack_stage == 3 and timer > 0.1:
		kill_tweens(tween_list)
		play_animation("dash")
		sfx_dash.play()
		if not main.only_x:
			sfx_oz_dash.play()
		dash_smoke.emitting = true
		force_movement(dash_speed)
		timer = 0
		next_attack_stage()
		
	elif attack_stage == 4 and timer > 0.05:
		if timer <= 0.6:
			if is_player_nearby_horizontally(48) or facing_a_wall():
				force_movement(0)
				play_animation("risingaber_ready")
				next_attack_stage()
		else:
			EndAbility()

	elif attack_stage == 5 and timer > 0.1 and has_finished_last_animation():
		hyouryuushou_slash()
		next_attack_stage()
			
	elif attack_stage == 6 and timer > 0.1:
		if get_vertical_speed() > 0 and not character.is_on_floor():
			play_animation_once("fall")
		if character.is_on_floor():
			play_animation("recover")
			force_movement(0)
			if is_player_nearby_horizontally(96):
				go_to_attack_stage(7)
			else:
				go_to_attack_stage(20)

	elif attack_stage == 7 and timer > 0.1:
		turn_and_face_player()
		play_animation("recover")
		force_movement(0)
		chance = randf() * 100
		if chance > 70 or is_player_above(96) or not is_player_nearby_horizontally(384):
			play_animation("messenkou_start")
			go_to_attack_stage(12)
		else:
			next_attack_stage()
	
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
		if chance > 50 or is_player_above(96) or not is_player_nearby_horizontally(384):
			play_animation("messenkou_start")
			go_to_attack_stage(12)
		else:
			go_to_attack_stage(20)
			
	elif attack_stage == 12 and timer > 0.1 and has_finished_last_animation():
		chance = randf() * 100
		if not main.only_x or chance > 50:
			messenkou_wave()
		else:
			shin_messenkou_wave()
		if chance > 50:
			next_attack_stage()
		else:
			go_to_attack_stage(20)
		
	elif attack_stage == 13 and timer > 0.1 and has_finished_last_animation():
		play_animation("messenkou_start")
		next_attack_stage()
		
	elif attack_stage == 14 and timer > 0.1 and has_finished_last_animation():
		chance = randf() * 100
		if not main.only_x or chance > 50:
			messenkou_wave()
		else:
			shin_messenkou_wave()
		if chance > 70:
			next_attack_stage()
		else:
			go_to_attack_stage(20)
		
	elif attack_stage == 15 and timer > 0.1 and has_finished_last_animation():
		play_animation("messenkou_start")
		next_attack_stage()
			
	elif attack_stage == 16 and timer > 0.1 and has_finished_last_animation():
		if not main.only_x:
			messenkou_wave()
		else:
			shin_messenkou_wave()
		next_attack_stage()
		
	elif attack_stage == 17 and timer > 0.1 and has_finished_last_animation():
		go_to_attack_stage(20)
			
	elif attack_stage == 20 and has_finished_last_animation():
		EndAbility()

func _Interrupt() -> void :
	._Interrupt()
	dash_smoke.emitting = false
	saber1.deactivate()
	saber2.deactivate()
	saber3.deactivate()

func hyouryuushou_slash():
	risingsaber.activate()
	play_animation("risingaber")
	force_movement(slash_speed)
	set_vertical_speed( - 450)
	call_deferred("decay_speed", 1, 1.25)
	sfx_saber3.play()
	if not main.only_x:
		sfx_oz_rising_saber.play()
	dash_smoke.emitting = false

func messenkou_wave():
	play_animation("messenkou")
	rekohouha_sound.play()
	ground_sound.play()
	if not main.only_x:
		sfx_oz_messenkou.play()
	create_messenkou(global_position, 0)
	create_messenkou(global_position, 45)
	create_messenkou(global_position, 90)
	create_messenkou(global_position, -45)
	create_messenkou(global_position, -90)
	if main.only_x:
		create_messenkou(global_position, 22.5)
		create_messenkou(global_position, 67.5)
		create_messenkou(global_position, -22.5)
		create_messenkou(global_position, -67.5)

func shin_messenkou_wave():
	play_animation("messenkou")
	ground_sound.play()
	if not main.only_x:
		sfx_oz_messenkou.play()
	shot_time = 0
	shin_messenkou()
	Tools.timer(0.1, "shin_messenkou", self)
	Tools.timer(0.2, "shin_messenkou", self)
	Tools.timer(0.3, "shin_messenkou", self)
	Tools.timer(0.4, "shin_messenkou", self)
	Tools.timer(0.5, "shin_messenkou", self)
	Tools.timer(0.6, "shin_messenkou", self)
	
func shin_messenkou():
	rekohouha_sound.play()
	create_messenkou(global_position + Vector2(30 + shot_time * 60, 0), 0)
	create_messenkou(global_position + Vector2(-30 + shot_time * - 60, 0), 0)
	create_messenkou_effect(global_position + Vector2(30 + shot_time * 60, 0))
	create_messenkou_effect(global_position + Vector2(-30 + shot_time * - 60, 0))
	messenkou_effect
	shot_time += 1

func create_messenkou(ground_position, degrees: float) -> void :
	var instance = messenkou.instance()
	if main.only_x:
		instance = messenkou.instance()
		ground_position.y += 5
	else:
		instance = messenkou_omega.instance()
		ground_position.y += 10
	instance.get_node("DamageOnTouch").hit_through_invulnerability = false
	instance.rotate_degrees(degrees)
	instance.can_deflect = false
	if degrees == 0:
		instance.set_vertical_speed(-420)
	if degrees == 22.5:
		instance.set_vertical_speed(-366.78)
		instance.set_horizontal_speed(160.72)
	if degrees == 45:
		instance.set_vertical_speed(-296.94)
		instance.set_horizontal_speed(296.94)
	if degrees == 67.5:
		instance.set_vertical_speed(-160.72)
		instance.set_horizontal_speed(366.78)
	if degrees == 90:
		instance.set_horizontal_speed(420)
	if degrees == -22.5:
		instance.set_vertical_speed(-366.78)
		instance.set_horizontal_speed(-160.72)
	if degrees == -45:
		instance.set_vertical_speed(-296.94)
		instance.set_horizontal_speed(-296.94)
	if degrees == -67.5:
		instance.set_vertical_speed(-160.72)
		instance.set_horizontal_speed(-366.78)
	if degrees == -90:
		instance.set_horizontal_speed(-420)
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.get_node("DamageOnTouch").damage = messenkou_damage
	instance.set_global_position(ground_position)
	instance.initialize(1)
	Event.emit_signal("screenshake", 0.3)

func create_messenkou_effect(ground_position) -> void :
	var instance = messenkou_effect.instance()
	ground_position.y += -12
	instance.get_node("DamageOnTouch").hit_through_invulnerability = false
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.z_index = character.z_index + 1
	instance.get_node("DamageOnTouch").damage = messenkou_damage
	instance.set_global_position(ground_position)
	instance.initialize(1)
	Tools.timer(1.0, "destroy", instance)



