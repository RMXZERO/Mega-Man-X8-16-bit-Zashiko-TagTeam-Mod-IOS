extends AttackAbility

onready var boss_ai = get_parent().get_node("BossAI")

export var z_buster = preload("res://Zero_mod/Boss_Omega/Projectile/Charge_Z_Buster.tscn")
export var shingetsurin = preload("res://Zero_mod/Boss_Omega/Projectile/Charge_Shingetsurin.tscn")
export var mid_buster = preload("res://Zero_mod/Boss_Omega/Projectile/Charge_Mid_Buster.tscn")
export var charge_buster = preload("res://Zero_mod/Boss_Omega/Projectile/Charge_Buster.tscn")
export var charge_wave = preload("res://Zero_mod/Boss_Omega/Projectile/Charge_Wave.tscn")
export var beamwave = preload("res://Zero_mod/Boss_Omega/Projectile/BeamWave.tscn")
export var fallen_stone = preload("res://Zero_mod/Boss_Omega/Projectile/Fallen_Stone.tscn")

onready var saberwave: Node2D = $"../animatedSprite/SaberCombo/saber3"
onready var saber1: Node2D = $"../animatedSprite/7SlashCombo/saber1"
onready var saber2: Node2D = $"../animatedSprite/7SlashCombo/saber2"
onready var saber3: Node2D = $"../animatedSprite/7SlashCombo/saber3"
onready var chargesaber: Node2D = $"../animatedSprite/SaberCombo/chargesaber"
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

onready var charging_particle = character.get_node("animatedSprite").get_node("ChargingParticle")
onready var charged_particle = character.get_node("animatedSprite").get_node("ChargedParticle")
onready var charge_saber_effect = character.get_node("animatedSprite").get_node("charge_saber")

var first_signal: bool = false
var dash_speed: = 400
var chance = randf() * 100
var mid_damage: float = 2
var max_damage: float = 4
var slash_damage: float = 6

func _ready() -> void :
	visible = true

func _Setup() -> void :
	turn_and_face_player()
	play_animation("idle")
	dash_speed = 400 + awakened.use_awakened_time * 50
	chance = randf() * 100
	saberwave.damage = 5 + awakened.use_awakened_time
	saber1.damage = 3 + awakened.use_awakened_time
	saber2.damage = 4 + awakened.use_awakened_time
	saber3.damage = 5 + awakened.use_awakened_time
	mid_damage = 3 + awakened.use_awakened_time
	max_damage = 6 + awakened.use_awakened_time
	slash_damage = 8 + awakened.use_awakened_time
	if not main.only_x:
		saberwave.scale.x = 1.2
		saber1.scale.x = 1.2
		saber2.scale.x = 1.2
		saber3.scale.x = 1.2
		saberwave.scale.y = 1.2
		saber1.scale.y = 1.2
		saber2.scale.y = 1.2
		saber3.scale.y = 1.2
	else:
		saberwave.scale.x = 1.0
		saber1.scale.x = 1.0
		saber2.scale.x = 1.0
		saber3.scale.x = 1.0
		saberwave.scale.y = 1.0
		saber1.scale.y = 1.0
		saber2.scale.y = 1.0
		saber3.scale.y = 1.0
	sfx_oz_charge.stream.loop = true
	var camera_position = GameManager.camera.get_camera_screen_center()
	if character.global_position.x >= camera_position.x - 224 and character.global_position.x <= camera_position.x + 224:
		pass
	else:
		EndAbility()

func _Update(delta: float) -> void :
	process_gravity(delta)
	
	if attack_stage == 0:
		if main.only_x:
			go_to_attack_stage(2)
			timer = 0.4
		else:
			sfx_oz_charge.play()
			charging_particle.visible = true
			charged_particle.visible = false
			turn_and_face_player()
			next_attack_stage()
	
	elif attack_stage == 1 and timer > 0.2:
		charging_particle.visible = false
		charged_particle.visible = true
		turn_and_face_player()
		next_attack_stage()
	
	elif attack_stage == 2 and timer > 0.4:
		turn_and_face_player()
		if not is_player_nearby_horizontally(96) and is_player_nearby_horizontally(160) and is_player_in_front() and not is_player_above(64) and chance > 60:
			play_animation("dash")
			sfx_dash.play()
			if not main.only_x:
				sfx_oz_dash.play()
			dash_smoke.emitting = true
			force_movement(dash_speed)
			go_to_attack_stage(17)
		elif is_player_nearby_horizontally(96) and is_player_in_front() and not is_player_above(64) and chance > 60:
			play_animation("charge_saber_ready")
			charging_particle.visible = false
			charged_particle.visible = false
			sfx_oz_charge.stop()
			go_to_attack_stage(18)
		elif not is_player_nearby_horizontally(160) or is_player_above(64) or chance <= 60:
			charging_particle.visible = false
			charged_particle.visible = false
			if chance <= 60 and chance >= 10:
				sfx_oz_charge.stop()
				next_attack_stage()
			elif chance <= 10:
				sfx_oz_charge.stop()
				go_to_attack_stage(19)
			else:
				chance = randf() * 100
			
	elif attack_stage == 3:
		force_movement(0)
		dash_smoke.emitting = false
		if awakened.first_awakened:
			if awakened.use_awakened_time <= 1:
				if character.current_health/character.max_health > 0.5 and not first_signal:
					next_attack_stage()
				elif character.current_health/character.max_health < 0.5 or first_signal:
					first_signal = true
					go_to_attack_stage(7)
			elif awakened.use_awakened_time >= 2:
				go_to_attack_stage(10)
		else:
			next_attack_stage()
		
	elif attack_stage == 4 and timer > 0.1:
		if main.only_x:
			play_animation("buster_normal")
			if awakened.first_awakened:
				sfx_shingetsurin.play()
				beam_wave(shingetsurin, max_damage)
			else:
				beam_wave(z_buster, mid_damage)
				sfx_zbuster.play()
		else:
			play_animation("buster_normal_mid")
			beam_wave(mid_buster, mid_damage)
			sfx_oz_buster.play()
		next_attack_stage()

	elif attack_stage == 5 and timer > 0.1 and has_finished_last_animation():
		play_animation_again("buster_normal")
		if main.only_x:
			if awakened.first_awakened:
				sfx_shingetsurin.play()
				beam_wave(shingetsurin, max_damage)
			else:
				beam_wave(z_buster, mid_damage)
				sfx_zbuster.play()
		else:
			beam_wave(charge_buster, max_damage)
			sfx_oz_buster.play()
		next_attack_stage()
			
	elif attack_stage == 6 and timer > 0.1 and has_finished_last_animation():
		if main.only_x:
			play_animation("saber_3")
			saberwave.activate()
			beam_wave(beamwave, slash_damage)
			sfx_swordwave.play()
		else:
			play_animation("7_slash_3")
			saber3.activate()
			beam_wave(charge_wave, slash_damage)
			sfx_oz_charge_saber.play()
		go_to_attack_stage(20)
		
	elif attack_stage == 7 and timer > 0.1:
		play_animation("buster_fast_1")
		if main.only_x:
			if awakened.first_awakened:
				sfx_shingetsurin.play()
				beam_wave(shingetsurin, max_damage)
			else:
				beam_wave(z_buster, mid_damage)
				sfx_zbuster.play()
		else:
			beam_wave(mid_buster, mid_damage)
			sfx_oz_buster.play()
		timer = 0
		next_attack_stage()

	elif attack_stage == 8 and timer > 0.2 and has_finished_last_animation():
		play_animation("buster_fast_2")
		if main.only_x:
			if awakened.first_awakened:
				sfx_shingetsurin.play()
				beam_wave(shingetsurin, max_damage)
			else:
				beam_wave(z_buster, mid_damage)
				sfx_zbuster.play()
		else:
			beam_wave(charge_buster, max_damage)
			sfx_oz_buster.play()
		timer = 0
		next_attack_stage()
			
	elif attack_stage == 9 and timer > 0.3 and has_finished_last_animation():
		if main.only_x:
			play_animation("saber_3")
			saberwave.activate()
			beam_wave(beamwave, slash_damage)
			sfx_swordwave.play()
		else:
			play_animation("7_slash_3")
			saber3.activate()
			beam_wave(charge_wave, slash_damage)
			sfx_oz_charge_saber.play()
		go_to_attack_stage(20)
		
	elif attack_stage == 10 and timer > 0.1:
		play_animation("buster_fast_3")
		if main.only_x:
			if awakened.first_awakened:
				sfx_shingetsurin.play()
				beam_wave(shingetsurin, max_damage)
			else:
				beam_wave(z_buster, mid_damage)
				sfx_zbuster.play()
		else:
			beam_wave(charge_buster, max_damage)
			sfx_oz_buster.play()
		next_attack_stage()
		
	elif attack_stage == 11 and timer > 0.1 and has_finished_last_animation():
		play_animation("buster_fast_1")
		if main.only_x:
			if awakened.first_awakened:
				sfx_shingetsurin.play()
				beam_wave(shingetsurin, max_damage)
			else:
				beam_wave(z_buster, mid_damage)
				sfx_zbuster.play()
		else:
			beam_wave(charge_buster, max_damage)
			sfx_oz_buster.play()
		next_attack_stage()
			
	elif attack_stage == 12 and timer > 0.1 and has_finished_last_animation():
		play_animation("buster_normal_fast")
		if main.only_x:
			if awakened.first_awakened:
				sfx_shingetsurin.play()
				beam_wave(shingetsurin, max_damage)
			else:
				beam_wave(z_buster, mid_damage)
				sfx_zbuster.play()
		else:
			beam_wave(charge_buster, max_damage)
			sfx_oz_buster.play()
		next_attack_stage()
			
	elif attack_stage == 13 and timer > 0.1:
		turn_and_face_player()
		next_attack_stage()
			
	elif attack_stage == 14 and timer > 0.1 and has_finished_last_animation():
		play_animation("7_slash_1")
		saber1.activate()
		sfx_saber1.play()
		if main.only_x:
			beam_wave(beamwave, slash_damage)
			sfx_swordwave.play()
		else:
			beam_wave(charge_wave, slash_damage)
			sfx_oz_voice_1.play()
		next_attack_stage()
		
	elif attack_stage == 15 and timer > 0.1 and has_finished_last_animation():
		play_animation("7_slash_2")
		saber2.activate()
		saber1.deactivate()
		sfx_saber2.play()
		if main.only_x:
			beam_wave(beamwave, slash_damage)
			sfx_swordwave.play()
		else:
			beam_wave(charge_wave, slash_damage)
			sfx_oz_voice_2.play()
		next_attack_stage()
			
	elif attack_stage == 16 and timer > 0.1 and has_finished_last_animation():
		play_animation("7_slash_3")
		saber3.activate()
		saber2.deactivate()
		sfx_saber3.play()
		if main.only_x:
			beam_wave(beamwave, slash_damage)
			sfx_swordwave.play()
		else:
			beam_wave(charge_wave, slash_damage)
			sfx_oz_charge_saber.play()
		go_to_attack_stage(20)
		
	elif attack_stage == 17 and timer > 0.1:
		if is_player_nearby_horizontally(96):
			sfx_oz_charge.stop()
			force_movement(0)
			play_animation("charge_saber_ready")
			dash_smoke.emitting = false
			charging_particle.visible = false
			charged_particle.visible = false
			next_attack_stage()
		else:
			force_movement(dash_speed)
			turn_and_face_player()
		
	elif attack_stage == 18 and timer > 0.1 and has_finished_last_animation():
		charge_saber()
		go_to_attack_stage(20)
		
	elif attack_stage == 19 and timer > 0.1:
		play_animation_again("buster_normal")
		create_nightmare_buster()
		Tools.timer(0.1, "create_nightmare_buster", self)
		Tools.timer(0.2, "create_nightmare_buster", self)
		Tools.timer(0.3, "create_nightmare_buster", self)
		Tools.timer(0.4, "create_nightmare_buster", self)
		Tools.timer(0.5, "create_nightmare_buster", self)
		Tools.timer(0.6, "create_nightmare_buster", self)
		Tools.timer(0.7, "create_nightmare_buster", self)
		Tools.timer(0.8, "create_nightmare_buster", self)
		Tools.timer(0.9, "create_nightmare_buster", self)
		go_to_attack_stage(20)
		
	elif attack_stage == 20 and has_finished_last_animation():
		EndAbility()

func _Interrupt() -> void :
	._Interrupt()
	sfx_oz_charge.stop()
	dash_smoke.emitting = false
	saberwave.deactivate()
	saber1.deactivate()
	saber2.deactivate()
	saber3.deactivate()
	chargesaber.deactivate()
	charging_particle.visible = false
	charged_particle.visible = false
	$stone_particles.emitting = false
	$stone_particles2.emitting = false

func create_nightmare_buster():
	if animatedSprite.animation == "buster_normal":
		play_animation_again("buster_normal")
		sfx_zbuster.stop()
		if main.only_x:
			if character.facing_right:
				create_beamwave(global_position, z_buster, 420, 0.1, 0)
			else:
				create_beamwave(global_position, z_buster, 420, 0.1, 180)
		else:
			sfx_oz_buster.play()
			if character.facing_right:
				create_beamwave(global_position, mid_buster, 420, 0.1, 0)
			else:
				create_beamwave(global_position, mid_buster, 420, 0.1, 180)

func beam_wave(buster_name, damage: float):
	if character.facing_right:
		create_beamwave(global_position, buster_name, dash_speed, damage, 0)
	else:
		create_beamwave(global_position, buster_name, dash_speed, damage, 180)

func charge_saber():
	play_animation("charge_saber")
	sfx_break.play()
	sfx_saber3.play()
	chargesaber.activate()
	charge_saber_effect.visible = true
	charge_saber_effect.frame = 0
	if not main.only_x:
		sfx_oz_charge_saber.play()
	if character.facing_right:
		$stone_particles.emitting = true
	else:
		$stone_particles2.emitting = true
	Tools.timer(0.2, "create_fallen_stone", self)
	Tools.timer(0.4, "create_fallen_stone", self)
	Tools.timer(0.6, "create_fallen_stone", self)
	Event.emit_signal("screenshake", 1)

func create_fallen_stone() -> void :
	var instance = fallen_stone.instance()
	var chance2 = randf() * 64
	instance.can_deflect = true
	instance.set_vertical_speed(400)
	instance.next_speed = 400
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.z_index = character.z_index + 10
	instance.get_node("DamageOnTouch").damage = 2
	instance.set_global_position(global_position + Vector2(float(chance2) * get_facing_direction(), -192))
	instance.initialize(1)

func create_beamwave(ground_position, buster_name, xspeed: float, damage: float, degrees: float) -> void :
	var instance = buster_name.instance()
	var spawn_position = Vector2(position.x * character.get_facing_direction(), position.y)
	var target_dir = get_player_angle(character.global_position + spawn_position)
	var beamwave_sprite = instance.get_node_or_null("animatedSprite")
	ground_position.y += -7
	instance.rotate_degrees(degrees)
	instance.can_deflect = false
	instance.set_horizontal_speed(xspeed * get_facing_direction())
	instance.next_speed = xspeed
	
	if buster_name == charge_buster:
		if awakened.use_awakened_time == 1:
			if character.current_health/character.max_health < 0.5 or first_signal:
				instance.set_horizontal_speed(xspeed * get_facing_direction() * 1.1)
		elif awakened.use_awakened_time >= 2:
			instance.set_horizontal_speed(xspeed * get_facing_direction() * 1.1)
	
	if buster_name == charge_wave:
		if degrees == 180:
			if beamwave_sprite:
				beamwave_sprite.flip_v = true
		if awakened.use_awakened_time == 1:
			if character.current_health/character.max_health < 0.5 or first_signal:
				instance.set_horizontal_speed(xspeed * get_facing_direction() * 1.2)
		elif awakened.use_awakened_time >= 2:
			instance.set_horizontal_speed(xspeed * get_facing_direction() * 1.2)
		instance.get_node("DamageOnTouch").hit_through_invulnerability = true
	
	if buster_name == z_buster or buster_name == mid_buster:
	#	instance.can_deflect = true
		if xspeed == 420:
			instance.set_vertical_speed((0 + rand_range( - 50, 50))* get_facing_direction())
	
	if buster_name == beamwave:
		if is_player_in_front():
			instance.set_horizontal_speed(xspeed * target_dir.x)
			instance.set_vertical_speed(xspeed * target_dir.y)
			instance.set_rotation(Vector2(xspeed * target_dir.x, xspeed * target_dir.y).angle())
		else:
			instance.set_horizontal_speed(xspeed * get_facing_direction())
		instance.get_node("DamageOnTouch").hit_through_invulnerability = true
	
	if buster_name == shingetsurin:
		if is_player_in_front():
			instance.set_horizontal_speed(xspeed * target_dir.x * 0.5)
			instance.set_vertical_speed(xspeed * target_dir.y * 0.5)
		else:
			instance.set_horizontal_speed(xspeed * get_facing_direction() * 0.5)
		if degrees == 180:
			if beamwave_sprite:
				beamwave_sprite.flip_v = true
		instance.next_speed = xspeed * 0.5
	
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.z_index = character.z_index + 10
	instance.get_node("DamageOnTouch").damage = damage
	instance.set_global_position(ground_position)
	instance.initialize(1)

func get_player_angle(global_position : Vector2) -> Vector2:
	var speed = clamp(GameManager.player.get_horizontal_speed(),-30,30)
	var player_pos = GameManager.get_player_position() + Vector2(speed,-5)
	return ((player_pos) - global_position).normalized()



