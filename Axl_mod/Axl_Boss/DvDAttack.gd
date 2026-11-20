extends AttackAbility

onready var boss_ai = get_parent().get_node("BossAI")
onready var main = get_parent()
onready var space = $"../Space"

onready var bullet_sfx = $shot
onready var bullet = preload("res://Axl_mod/Axl_Boss/BossBullet.tscn")
onready var dvd_ball = preload("res://src/Actors/Bosses/BambooPandamonium/BambooGrenade.tscn")
onready var bouncing_ball = preload("res://src/Actors/Bosses/GravityAntonion/BouncingProjectile.tscn")
onready var crystal_bouncer_ball = preload("res://src/Actors/Bosses/GravityAntonion/BouncingProjectile.tscn")

onready var dash_smoke: Particles2D = $"../animatedSprite/Dash Smoke Particles"

onready var sfx_dash: AudioStreamPlayer = get_parent().get_node("dash")
onready var sfx_jump: AudioStreamPlayer = get_parent().get_node("jump")
onready var sfx_land: AudioStreamPlayer = get_parent().get_node("land")

var fire_laser: bool = false
var shot_time: = 0.1
var chance = randf() * 100
var dvd_throw: bool = false
var movement_speed = 250
var jump_speed = 250

func _Setup() -> void :
	turn_and_face_player()
	fire_laser = false
	dvd_throw = false
	shot_time = 0.1
	movement_speed = 250
	jump_speed = 250
	if boss_ai.used_desperation:
		shot_time = 0.075
		movement_speed = 311
		jump_speed = 435
	if CharacterManager.nightshade_zero_armor:
		shot_time = 0.05
		movement_speed = 311
		jump_speed = 435

func dvd_attack() -> void :
	chance = randf() * 100
	if not dvd_throw:
		dvd_throw = true
		create_dvd_ball(250, 50)
		create_dvd_ball(150,50)
		create_dvd_ball(50, 50)
		create_dvd_ball(-50, 50)
		create_dvd_ball(-150, 50)

func is_between(c, _min, _max) -> bool:
	return c > _min and c <= _max

func fire_again() -> void :
	fire_laser = false

func next_attack_stage() -> void :
	.next_attack_stage()

func _Update(delta: float) -> void :
	process_gravity(delta)
	if not fire_laser:
		if animatedSprite.animation == "rolling":
			fire_bullet_lock_player()
			Tools.timer(shot_time, "fire_again", self)
			fire_laser = true
	
	if attack_stage == 0:
		turn_and_face_player()
		play_animation("throw")
		next_attack_stage()
	
	elif attack_stage == 1 and has_finished_last_animation():
		play_animation("throw_end")
		chance = 1
		create_dvd_ball(250, 300)
		create_dvd_ball(250,350)
		create_dvd_ball(250, 400)
		create_dvd_ball(250, 450)
		create_dvd_ball(250, 500)
		next_attack_stage()
			
	elif attack_stage == 2 and has_finished_last_animation():
		dvd_throw = false
		turn_and_face_player()
		play_animation("rolling")
		sfx_jump.play()
		force_movement(movement_speed)
		set_vertical_speed(-jump_speed)
		next_attack_stage()
		
	elif attack_stage == 3:
		if boss_ai.used_desperation:
			if get_vertical_speed() > 0:
				dvd_attack()
		turn_and_face_player()
		if character.is_on_floor() or global_position.y >  main.land_position.y -4:
			set_vertical_speed(50)
			sfx_land.play()
			next_attack_stage()

	elif attack_stage == 4:
		dvd_throw = false
		turn_and_face_player()
		play_animation("rolling")
		sfx_jump.play()
		force_movement(movement_speed)
		set_vertical_speed(-jump_speed)
		next_attack_stage()
			
	elif attack_stage == 5:
		if boss_ai.used_desperation:
			if get_vertical_speed() > 0:
				dvd_attack()
		turn_and_face_player()
		if character.is_on_floor() or global_position.y >  main.land_position.y -4:
			set_vertical_speed(50)
			sfx_land.play()
			next_attack_stage()
			
	elif attack_stage == 6:
		dvd_throw = false
		turn_and_face_player()
		play_animation("rolling")
		sfx_jump.play()
		force_movement(movement_speed)
		set_vertical_speed(-jump_speed)
		next_attack_stage()
	
	elif attack_stage == 7:
		if boss_ai.used_desperation:
			if get_vertical_speed() > 0:
				dvd_attack()
		turn_and_face_player()
		if character.is_on_floor() or global_position.y >  main.land_position.y -4:
			set_vertical_speed(50)
			sfx_land.play()
			next_attack_stage()
			
	elif attack_stage == 8:
		dvd_throw = false
		turn_and_face_player()
		play_animation("rolling")
		sfx_jump.play()
		force_movement(movement_speed)
		set_vertical_speed(-jump_speed)
		next_attack_stage()
	
	elif attack_stage == 9:
		if boss_ai.used_desperation:
			if get_vertical_speed() > 0:
				dvd_attack()
		turn_and_face_player()
		if character.is_on_floor() or global_position.y >  main.land_position.y -4:
			set_vertical_speed(50)
			sfx_land.play()
			next_attack_stage()
			
	elif attack_stage == 10:
		dvd_throw = false
		turn_and_face_player()
		play_animation("rolling")
		sfx_jump.play()
		force_movement(movement_speed)
		set_vertical_speed(-jump_speed)
		next_attack_stage()
	
	elif attack_stage == 11:
		if boss_ai.used_desperation:
			if get_vertical_speed() > 0:
				dvd_attack()
		if character.is_on_floor() or global_position.y >  main.land_position.y -4:
			set_vertical_speed(50)
			timer = 0
			play_animation("beam_equip_3")
			sfx_land.play()
			next_attack_stage()

	elif attack_stage == 12 and timer > 0.3:
		play_animation("beam_equip_2")
		next_attack_stage()
		
	elif attack_stage == 13 and has_finished_last_animation():
		EndAbility()

func _Interrupt() -> void :
	._Interrupt()
	main.use_desperation += 1
	dash_smoke.emitting = false

func fire_bullet_lock_player() -> void :
	bullet_sfx.play()
	create_bullet_lock_player(global_position)

func create_bullet_lock_player(ground_position) -> void :
	var instance = instantiate_projectile(bullet)
	var spawn_position = Vector2(position.x * character.get_facing_direction(), position.y)
	var target_dir = get_player_angle(character.global_position + spawn_position)
	
	instance.global_position = character.global_position + spawn_position
	instance.set_horizontal_speed( 450 * target_dir.x)
	instance.set_vertical_speed( 450 * target_dir.y)
	instance.set_rotation(Vector2(450 * target_dir.x, 450 * target_dir.y).angle())
	if animatedSprite.animation == "shot_1":
		instance.set_global_position(global_position + Vector2( 2 * get_facing_direction(), -36))
	elif animatedSprite.animation == "shot_2":
		instance.set_global_position(global_position + Vector2( 26 * get_facing_direction(), -30))
	elif animatedSprite.animation == "shot_3":
		instance.set_global_position(global_position + Vector2( + 36 * get_facing_direction(), -8))
	elif animatedSprite.animation == "shot_4":
		instance.set_global_position(global_position + Vector2( 30 * get_facing_direction(), 14))
	elif animatedSprite.animation == "shot_5":
		instance.set_global_position(global_position + Vector2( 10 * get_facing_direction(), 28))
	else:
		instance.set_global_position(global_position + Vector2( -8 * get_facing_direction(), 0))
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)

func create_dvd_ball(x_speed, y_speed) -> void :
	if is_between(chance, 0, 10):
		var instance = instantiate_projectile(dvd_ball)
		instance.global_position = character.global_position
		instance.set_horizontal_speed( x_speed * character.get_facing_direction())
		instance.set_vertical_speed( - y_speed)
		instance.get_node("DamageOnTouch").damage = 6
		get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	elif is_between(chance, 10, 100):
		var instance = instantiate_projectile(bouncing_ball)
		instance.global_position = character.global_position
		instance.set_horizontal_speed( x_speed * character.get_facing_direction())
		instance.set_vertical_speed( - y_speed)
		instance.get_node("DamageOnTouch").damage = 3
		get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)

func get_player_angle(global_position : Vector2) -> Vector2:
	var speed = clamp(GameManager.player.get_horizontal_speed(),-30,30)
	var player_pos = GameManager.get_player_position() + Vector2(speed,-5)
	return ((player_pos) - global_position).normalized()
