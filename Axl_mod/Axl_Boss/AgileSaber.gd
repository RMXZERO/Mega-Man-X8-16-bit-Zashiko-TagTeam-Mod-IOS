extends AttackAbility

onready var agile_wave = preload("res://Axl_mod/Axl_Boss/Agile_Wave.tscn")

onready var boss_ai = get_parent().get_node("BossAI")
onready var main = get_parent()
onready var highslash: Node2D = $highslash
onready var dashslash: Node2D = $dashslash
onready var smoke_dash: Particles2D = $"../animatedSprite/Dash Smoke Particles"
onready var dash: AudioStreamPlayer = $"../dash"
onready var slash: AudioStreamPlayer = $"../saber"
onready var slash3: AudioStreamPlayer = $"../saber3"
var chance = randf() * 100
var diagonal_dash_speed: = 500
var play_sound: bool = false
var idle_time: = 0.4

func _Setup() -> void:
	turn_and_face_player()
	chance = randf() * 100
	play_sound = false
	diagonal_dash_speed = 500
	idle_time = 0.5 - CharacterManager.game_mode * 0.1
	if boss_ai.used_desperation:
		diagonal_dash_speed = 600
	if CharacterManager.nightshade_zero_armor:
		diagonal_dash_speed = 600

func reset_sound() -> void:
	play_sound = false

func is_between(c, _min, _max) -> bool:
	return c > _min and c <= _max

func _Update(_delta) -> void:
	process_gravity(_delta)
	
	if animatedSprite.animation == "saber_dash" and not play_sound:
		play_sound = true
		slash.play()
		Tools.timer(0.1, "reset_sound", self)
	
	if attack_stage == 0:
		if is_between(chance, 0, 80):
			turn_and_face_player()
			play_animation("saber_dash")
			force_movement(diagonal_dash_speed)
			dashslash.activate()
			dash.play()
			smoke_dash.emitting = true
			next_attack_stage()
		elif is_between(chance, 80, 100):
			rising_saber()
			go_to_attack_stage(5)
			
	elif attack_stage == 1:
		if facing_a_wall():
			dashslash.deactivate()
			Tools.timer(idle_time, "next_attack_stage", self)
			next_attack_stage()
		elif is_player_above(128) and get_distance_from_player() <= 48:
			rising_saber()
			go_to_attack_stage(5)
	
	elif attack_stage == 2:
		turn_and_face_player()
		play_animation("idle")
		force_movement(0)
		smoke_dash.emitting = false

	elif attack_stage == 3:
		turn_and_face_player()
		play_animation("saber_dash")
		force_movement(diagonal_dash_speed)
		dashslash.activate()
		dash.play()
		smoke_dash.emitting = true
		next_attack_stage()
		
	elif attack_stage == 4:
		if facing_a_wall():
			dashslash.deactivate()
			go_to_attack_stage(7)
		elif is_player_above(128) and get_distance_from_player() <= 48:
			rising_saber()
			go_to_attack_stage(5)
		
	elif attack_stage == 5 and timer > 0.1:
		if get_vertical_speed() > 0:
			highslash.deactivate()
			play_animation("fall")
			next_attack_stage()
	
	elif attack_stage == 6 and timer > 0.1:
		if character.is_on_floor() or global_position.y >  main.land_position.y -4:
			play_animation("idle")
			go_to_attack_stage(20)
		
	elif attack_stage == 7:
		Tools.timer(idle_time, "next_attack_stage", self)
		next_attack_stage()
		
	elif attack_stage == 8:
		turn_and_face_player()
		play_animation("idle")
		force_movement(0)
		smoke_dash.emitting = false
		
	elif attack_stage == 9:
		turn_and_face_player()
		play_animation("diagonal_dash")
		force_movement(diagonal_dash_speed)
		dash.play()
		smoke_dash.emitting = true
		next_attack_stage()
		
	elif attack_stage == 10:
		if get_distance_from_player() <= 48:
			rising_saber()
			go_to_attack_stage(5)
		elif facing_a_wall():
			go_to_attack_stage(20)
		
	elif attack_stage == 20 and timer > 0.1:
		if not "axl_saber_combo" in GameManager.collectibles:
			Achievements.unlock("AXLBOSSSABER")
		EndAbility()

func rising_saber():
	dashslash.deactivate()
	highslash.activate()
	slash3.play()
	play_animation("rising_saber")
	force_movement(100)
	set_vertical_speed( - 450)
	call_deferred("decay_speed", 1, 1.25)
	smoke_dash.emitting = false
	Tools.timer(0.2, "create_agile_wave", self)

func create_agile_wave() -> void :
	var instance = agile_wave.instance()
	if main.only_zero:
		instance.only_zero = true
		instance.get_node("animatedSprite").animation = "agile_wave_2"
	if character.facing_right:
		instance.set_horizontal_speed(500)
		instance.scale.x = 1
	else:
		instance.set_horizontal_speed(-500)
		instance.scale.x = -1
	if is_player_above(32):
		instance.set_global_position(global_position + Vector2( + 32 * get_facing_direction(), -32))
	else:
		instance.set_global_position(global_position + Vector2( + 32 * get_facing_direction(), 0))
	instance.z_index = character.z_index + 10
	instance.get_node("DamageOnTouch").damage = 8
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.initialize(1)

func _Interrupt() -> void:
	._Interrupt()
	main.use_desperation += 1
	smoke_dash.emitting = false

func turn_and_face_player():
	.turn_and_face_player()
	highslash.handle_direction()
	dashslash.handle_direction()
