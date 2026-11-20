extends AttackAbility

onready var boss_ai = get_parent().get_node("BossAI")
onready var main = get_parent()

onready var dash_smoke: Particles2D = $"../animatedSprite/Dash Smoke Particles"
onready var dive_sfx = $dive
onready var shot_sfx = $shot

onready var laser = preload("res://X_mod/X_Boss/XSoulBody.tscn")
onready var frosttower = preload("res://X_mod/X_Boss/XFrostTower.tscn")

onready var sfx_saber1: AudioStreamPlayer = get_parent().get_node("saber")
onready var sfx_saber2: AudioStreamPlayer = get_parent().get_node("saber2")
onready var sfx_saber3: AudioStreamPlayer = get_parent().get_node("saber3")
onready var sfx_dash: AudioStreamPlayer = get_parent().get_node("dash")
onready var sfx_jump: AudioStreamPlayer = get_parent().get_node("jump")
onready var sfx_land: AudioStreamPlayer = get_parent().get_node("land")

var dash_speed: = 300
var camera_position: Vector2
var create_soul_body: bool = false
var shot_time: = 0.3
var ready_time: = 0

func _Setup() -> void :
	turn_and_face_player()
	play_animation("idle")
	create_soul_body = false
	shot_time = 0.3
	if boss_ai.used_desperation:
		shot_time = 0.25
	if CharacterManager.nightshade_zero_armor:
		dash_speed = 400
		shot_time = 0.25
	ready_time = rand_range( - 50, 50)

func _Update(delta: float) -> void :
	if not animatedSprite.animation == "soul_body" and not animatedSprite.animation == "soul_body_start":
		process_gravity(delta)
	if animatedSprite.animation == "soul_body" or animatedSprite.animation == "soul_body_start":
		turn_and_face_player()
		set_vertical_speed(0)
		set_horizontal_speed(0)

	if attack_stage == 0:
		if is_player_above(48):
			play_animation("jump")
			force_movement(dash_speed * 0.75)
			set_vertical_speed( - 300)
			sfx_jump.play()
			if ready_time > -15 and ready_time < 15:
				if boss_ai.used_desperation:
					main.set_x_boss_frost_tower_colors(animatedSprite)
				go_to_attack_stage(2)
			else:
				main.set_x_boss_soul_body_colors(animatedSprite)
				go_to_attack_stage(6)
		else:
			play_animation("dash")
			sfx_dash.play()
		
			dash_smoke.emitting = true
			force_movement(dash_speed)
			if ready_time > 35 or ready_time < -35:
				main.set_x_boss_soul_body_colors(animatedSprite)
				go_to_attack_stage(5)
			else:
				next_attack_stage()
	
	elif attack_stage == 1 and timer > 0.1:
		if is_player_nearby_horizontally(48) and is_player_nearby_vertically(32) or timer > 1 or facing_a_wall():
			play_animation("jump")
			force_movement( - dash_speed * 0.75)
			set_vertical_speed( - 300)
				
			sfx_jump.play()
			call_deferred("decay_speed", 1, 1.25)
			dash_smoke.emitting = false
			if boss_ai.used_desperation:
				main.set_x_boss_frost_tower_colors(animatedSprite)
			next_attack_stage()
	
	elif attack_stage == 2 and timer > 0.1:
		if get_vertical_speed() > 0:
			if boss_ai.used_desperation:
				play_animation("soul_body_start")
				next_attack_stage()
			else:
				go_to_attack_stage(8)
			
	elif attack_stage == 3 and has_finished_last_animation():
		camera_position = GameManager.camera.get_camera_screen_center()
		if not create_soul_body:
			play_animation("soul_body")
			create_soul_body = true
			create_frost_tower(camera_position)
			dive_sfx.play()
			Tools.timer(shot_time * 2, "frost_tower_2", self)
			Tools.timer(shot_time * 4, "frost_tower_3", self)
			Tools.timer(shot_time * 6, "frost_tower_4", self)
			Tools.timer(shot_time * 8, "attack_strage_8", self)
	
	elif attack_stage == 5 and timer > 0.1:
		if is_player_nearby_horizontally(48) and is_player_nearby_vertically(32) or timer > 1 or facing_a_wall():
			play_animation("jump")
			force_movement( - dash_speed * 0.75)
			set_vertical_speed( - 300)
				
			sfx_jump.play()
			call_deferred("decay_speed", 1, 1.25)
			dash_smoke.emitting = false
			next_attack_stage()
	
	elif attack_stage == 6 and timer > 0.1:
		if get_vertical_speed() > 0:
			play_animation("soul_body_start")
			next_attack_stage()
			
	elif attack_stage == 7 and has_finished_last_animation():
		if not create_soul_body:
			play_animation("soul_body")
			create_soul_body = true
			create_soul_body()
			Tools.timer(shot_time, "create_soul_body", self)
			Tools.timer(shot_time * 2, "create_soul_body", self)
			Tools.timer(shot_time * 3, "create_soul_body", self)
			Tools.timer(shot_time * 4, "create_soul_body", self)
			Tools.timer(shot_time * 5, "create_soul_body", self)
			Tools.timer(shot_time * 6, "create_soul_body", self)
			Tools.timer(shot_time * 7, "attack_strage_8", self)
		
	elif attack_stage == 8 and timer > 0.1:
		kill_tweens(tween_list)
		main.set_x_boss_normal_colors(animatedSprite)
		play_animation("fall")
		if character.is_on_floor():
			go_to_attack_stage(10)
	
	elif attack_stage == 10:
		EndAbility()

func _Interrupt() -> void :
	._Interrupt()
	dash_smoke.emitting = false
	main.set_x_boss_normal_colors(animatedSprite)

func attack_stage_6() -> void :
	if has_finished_last_animation():
		go_to_attack_stage(10)

func create_soul_body() -> void :
	if not animatedSprite.animation == "soul_body":
		return
	shot_sfx.play()
	create_soul_body_lock_player(global_position, 0)

func create_soul_body_lock_player(ground_position,y_speed) -> void :
	var instance = instantiate_projectile(laser)
	var spawn_position = Vector2(position.x * character.get_facing_direction(), position.y)
	var target_dir = get_player_angle(character.global_position + spawn_position)
	if character.facing_right:
		instance.scale.y = 1
	else:
		instance.scale.y = -1
	instance.can_deflect = true
	instance.global_position = character.global_position + spawn_position
	instance.set_horizontal_speed( 600 * target_dir.x)
	instance.set_vertical_speed( 600 * target_dir.y)
	instance.set_rotation(Vector2(600 * target_dir.x, 600 * target_dir.y).angle())
	instance.get_node("DamageOnTouch").damage = 8

func get_player_angle(global_position : Vector2) -> Vector2:
	var speed = clamp(GameManager.player.get_horizontal_speed(),-30,30)
	var player_pos = GameManager.get_player_position() + Vector2(speed,-5)
	
	return ((player_pos) - global_position).normalized()

func attack_strage_8() -> void :
	go_to_attack_stage(8)

func frost_tower_2() -> void :
	if not animatedSprite.animation == "soul_body":
		return
	dive_sfx.play()
	create_frost_tower(camera_position + Vector2(50, 0))
	create_frost_tower(camera_position + Vector2(-50, 0))

func frost_tower_3() -> void :
	if not animatedSprite.animation == "soul_body":
		return
	dive_sfx.play()
	create_frost_tower(camera_position + Vector2(0, 0))
	create_frost_tower(camera_position + Vector2(100, 0))
	create_frost_tower(camera_position + Vector2(-100, 0))

func frost_tower_4() -> void :
	if not animatedSprite.animation == "soul_body":
		return
	dive_sfx.play()
	create_frost_tower(camera_position + Vector2(50, 0))
	create_frost_tower(camera_position + Vector2(-50, 0))
	create_frost_tower(camera_position + Vector2(-150, 0))
	create_frost_tower(camera_position + Vector2(150, 0))

func create_frost_tower(ground_position) -> void :
	var instance = frosttower.instance()
	ground_position.y += -64
	instance.set_horizontal_speed(0)
	instance.set_vertical_speed(0)
	instance.z_index = character.z_index + 10
	instance.get_node("DamageOnTouch").damage = 8
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	instance.set_global_position(ground_position)
	instance.initialize(1)
