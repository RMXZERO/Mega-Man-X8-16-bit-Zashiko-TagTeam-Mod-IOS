extends AttackAbility

onready var boss_ai = get_parent().get_node("BossAI")

export var light_beam = preload("res://Zero_mod/Boss_Omega/Projectile/Light_Beam.tscn")

onready var damage: Node2D = $"../Damage"

onready var catch_player: Node2D = $"../animatedSprite/7SlashCombo/catch_player"
onready var saber1: Node2D = $"../animatedSprite/7SlashCombo/saber1"
onready var saber2: Node2D = $"../animatedSprite/7SlashCombo/saber2"
onready var saber3: Node2D = $"../animatedSprite/7SlashCombo/saber3"
onready var saber4: Node2D = $"../animatedSprite/7SlashCombo/saber4"
onready var saber5: Node2D = $"../animatedSprite/7SlashCombo/saber5"
onready var saber6: Node2D = $"../animatedSprite/7SlashCombo/saber6"
onready var saber7: Node2D = $"../animatedSprite/7SlashCombo/risingsaber"

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

var is_catch_player: bool = false
var dash_speed: = 400
var chance = randf() * 100
var crash_beam_damage: float = 8

func _ready() -> void :
	catch_player.connect("touch_target",self,"on_catch_player")
	beam_1.visible = false
	beam_2.visible = false
	beam_3.visible = false

func on_catch_player() -> void:
	if is_instance_valid(GameManager.player):
		if GameManager.player.is_invulnerable():
			if GameManager.player.animatedSprite.animation == "damage":
				is_catch_player = true
			elif GameManager.player.invulnerability > 0 and GameManager.player.toggleable_invulnerabilities.size() == 0:
				is_catch_player = true
			else:
				is_catch_player = false
		elif not GameManager.player.is_invulnerable():
			is_catch_player = true

func _Setup() -> void :
	turn_and_face_player()
	play_animation("idle")
	chance = randf() * 100
	dash_speed = 400 + awakened.use_awakened_time * 50
	default_gravity = 300
	saber1.damage = 2 + awakened.use_awakened_time
	saber2.damage = 2 + awakened.use_awakened_time
	saber3.damage = 2 + awakened.use_awakened_time
	saber4.damage = 3 + awakened.use_awakened_time
	saber5.damage = 3 + awakened.use_awakened_time
	saber6.damage = 4 + awakened.use_awakened_time
	saber7.damage = 5 + awakened.use_awakened_time
	crash_beam_damage = 8 + awakened.use_awakened_time
	if not main.only_x:
		saber1.scale.x = 1.2
		saber2.scale.x = 1.2
		saber3.scale.x = 1.2
		saber4.scale.x = 1.2
		saber5.scale.x = 1.2
		saber6.scale.x = 1.2
		saber7.scale.x = 1.2
		saber1.scale.y = 1.2
		saber2.scale.y = 1.2
		saber3.scale.y = 1.2
		saber4.scale.y = 1.2
		saber5.scale.y = 1.2
		saber6.scale.y = 1.2
		saber7.scale.y = 1.2
	else:
		saber1.scale.x = 1.0
		saber2.scale.x = 1.0
		saber3.scale.x = 1.0
		saber4.scale.x = 1.0
		saber5.scale.x = 1.0
		saber6.scale.x = 1.0
		saber7.scale.x = 1.0
		saber1.scale.y = 1.0
		saber2.scale.y = 1.0
		saber3.scale.y = 1.0
		saber4.scale.y = 1.0
		saber5.scale.y = 1.0
		saber6.scale.y = 1.0
		saber7.scale.y = 1.0
	if not awakened.first_awakened:
		EndAbility()

func _Update(delta: float) -> void :
	process_gravity(delta)
	
	if attack_stage == 0:
		default_gravity = 300
		is_catch_player = false
		catch_player.activate()
		kill_tweens(tween_list)
		turn_and_face_player()
		play_animation("jump")
		set_vertical_speed(-75)
		force_movement(dash_speed)
		sfx_jump.play()
		timer = 0
		next_attack_stage()
	
	elif attack_stage == 1:
		force_movement(dash_speed)
		if is_catch_player:
			if GameManager.player.is_invulnerable():
				if GameManager.player.animatedSprite.animation == "damage":
					go_to_attack_stage(7)
				elif GameManager.player.invulnerability > 0 and GameManager.player.toggleable_invulnerabilities.size() == 0:
					go_to_attack_stage(7)
				else:
					is_catch_player = false
					catch_player.deactivate()
					go_to_attack_stage(18)
			elif not GameManager.player.is_invulnerable():
				go_to_attack_stage(7)
		else:
			if character.is_on_floor() and timer > 0.1:
				catch_player.deactivate()
				force_movement(0)
				play_animation("idle")
				if not is_player_nearby_horizontally(192):
					go_to_attack_stage(17)
				else:
					next_attack_stage()
		
	elif attack_stage == 2 and timer > 0.1:
		force_movement(0)
		set_vertical_speed(200)
		if character.is_on_floor():
			play_animation("idle")
			sfx_land.play()
			if is_player_above(128) or not is_player_nearby_horizontally(384.0):
				go_to_attack_stage(21)
			else:
				go_to_attack_stage(20)
	
	elif attack_stage == 7 and timer > 0.1:
		force_movement(0)
		set_vertical_speed(5000)
		play_animation("idle")
		catch_player.deactivate()
		player_less_control()
		next_attack_stage()
	
	elif attack_stage == 8 and timer > 0.1:
		play_animation("7_slash_1")
		sfx_saber1.play()
		if not main.only_x:
			sfx_oz_voice_1.play()
		saber1.activate()
		player_less_control()
		next_attack_stage()
	
	elif attack_stage == 9 and timer > 0.1 and has_finished_last_animation():
		play_animation("7_slash_2")
		sfx_saber2.play()
		if not main.only_x:
			sfx_oz_voice_2.play()
		saber2.activate()
		saber1.deactivate()
		player_less_control()
		next_attack_stage()
	
	elif attack_stage == 10 and timer > 0.1 and has_finished_last_animation():
		play_animation("7_slash_3")
		sfx_saber3.play()
		if not main.only_x:
			sfx_oz_charge_saber.play()
		saber3.activate()
		saber2.deactivate()
		player_less_control()
		next_attack_stage()

	elif attack_stage == 11 and timer > 0.1 and has_finished_last_animation():
		play_animation("7_slash_4")
		sfx_saber2.play()
		sfx_oz_charge_saber.stop()
		if not main.only_x:
			sfx_oz_voice_2.play()
		saber4.activate()
		saber3.deactivate()
		player_less_control()
		next_attack_stage()
	
	elif attack_stage == 12 and timer > 0.1 and has_finished_last_animation():
		play_animation("7_slash_5")
		sfx_saber3.play()
		if not main.only_x:
			sfx_oz_voice_3.play()
		saber5.activate()
		saber4.deactivate()
		player_less_control()
		next_attack_stage()
	
	elif attack_stage == 13 and timer > 0.1 and has_finished_last_animation():
		play_animation("7_slash_6")
		sfx_saber2.play()
		if not main.only_x:
			sfx_oz_charge_saber.play()
		saber6.activate()
		saber5.deactivate()
		player_less_control()
		next_attack_stage()
	
	elif attack_stage == 14 and timer > 0.1 and has_finished_last_animation():
		saber6.deactivate()
		play_animation("dash")
		sfx_dash.play()
		if not main.only_x:
			sfx_oz_dash.play()
		next_attack_stage()
		
	elif attack_stage == 15 and timer > 0.05:
		if is_player_nearby_horizontally(64.0):
			pass
		else:
			dash_smoke.emitting = true
			force_movement(dash_speed)
		if is_player_nearby_horizontally(64.0) or timer > 1:
			if is_player_nearby_vertically(32) or facing_a_wall() or timer > 1:
				force_movement(0)
				sfx_dash.stop()
				sfx_oz_charge_saber.stop()
				play_animation("risingaber_ready")
				next_attack_stage()

	elif attack_stage == 16 and timer > 0.1 and has_finished_last_animation():
		player_less_control()
		hyouryuushou_slash()
		next_attack_stage()

	elif attack_stage == 17 and timer > 0.1:
		if get_vertical_speed() > 0:
			saber7.deactivate()
			play_animation("fall")
			if awakened.use_awakened_time >= 2:
				default_gravity = 7200
			next_attack_stage()
			
	elif attack_stage == 18 and timer > 0.1:
		if character.is_on_floor():
			play_animation("idle")
			force_movement(0)
			if not is_player_nearby_horizontally(192):
				go_to_attack_stage(0)
			else:
				go_to_attack_stage(20)
	
	elif attack_stage == 20:
		EndAbility()

	elif attack_stage == 21 and timer > 0.1:
		play_animation("messenkou_start")
		max_beam_offset = 32
		beam_1_offset = 0
		beam_2_offset = 1.57
		beam_3_offset = 3.14
		next_attack_stage()
			
	elif attack_stage == 22 and timer > 0.1:
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
	
	elif attack_stage == 23 and timer > 0.1 and has_finished_last_animation():
		next_attack_stage()

	elif attack_stage == 24:
		damage.activate()
		go_to_attack_stage(20)

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
	catch_player.deactivate()
	saber1.deactivate()
	saber2.deactivate()
	saber3.deactivate()
	saber4.deactivate()
	saber5.deactivate()
	saber6.deactivate()
	saber7.deactivate()
	dash_smoke.emitting = false
	if is_catch_player:
		if is_instance_valid(GameManager.player):
			GameManager.player.stop_forced_movement()

func hyouryuushou_slash():
	default_gravity = 900
	saber7.activate()
	play_animation("risingaber")
	force_movement(dash_speed * 0.5)
	set_vertical_speed( - 450)
	call_deferred("decay_speed", 1, 1.25)
	sfx_saber3.play()
	sfx_oz_charge_saber.stop()
	if not main.only_x:
		sfx_oz_rising_saber.play()
	dash_smoke.emitting = false

func player_less_control() -> void :
	if is_instance_valid(GameManager.player):
		if GameManager.player.is_executing("Ride"):
			GameManager.player.get_parent().void_touch()
	if not animatedSprite.animation == "dash" and not animatedSprite.animation == "hyouryuushou" and not animatedSprite.animation == "risingaber_ready" and not animatedSprite.animation == "risingaber":
		if is_instance_valid(GameManager.player):
			if GameManager.player.has_health():
				GameManager.player.global_position.y = character.global_position.y - 0
				character.global_position.x = GameManager.player.global_position.x - 48 * get_facing_direction()
				GameManager.player.interrupt_all_moves()
				GameManager.player.play_animation("damage")
				GameManager.player.animatedSprite.set_frame(0)
				GameManager.player.force_movement()
			else:
				GameManager.player.stop_forced_movement()
	else:
		if is_instance_valid(GameManager.player):
			GameManager.player.stop_forced_movement()

func create_crash_beam(ground_position) -> void :
	var instance = light_beam.instance()
	ground_position.y += -7
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.get_node("DamageOnTouch").damage = crash_beam_damage
	instance.set_global_position(ground_position)
	instance.initialize(1)

