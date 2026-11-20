extends AttackAbility

onready var boss_ai = get_parent().get_node("BossAI")
onready var main = get_parent()
onready var bullet_sfx = $shot

onready var bullet = preload("res://Axl_mod/Axl_Boss/BossBullet.tscn")

onready var dash_smoke: Particles2D = $"../animatedSprite/Dash Smoke Particles"

onready var sfx_dash: AudioStreamPlayer = get_parent().get_node("dash")
onready var sfx_jump: AudioStreamPlayer = get_parent().get_node("jump")
onready var sfx_land: AudioStreamPlayer = get_parent().get_node("land")

var dash_speed: = 300
var fire_laser: bool = false
var shot_time: = 0.1
var next_movement: bool = false

func _Setup() -> void :
	turn_and_face_player()
	next_movement = false
	fire_laser = false
	shot_time = 0.1
	if boss_ai.used_desperation:
		shot_time = 0.075
	if CharacterManager.nightshade_zero_armor:
		dash_speed = 400
		shot_time = 0.05

func fire_again() -> void :
	fire_laser = false

func next_attack_stage() -> void :
	.next_attack_stage()
	next_movement = false

func _Update(delta: float) -> void :
	process_gravity(delta)
	if animatedSprite.animation == "shot_1" or animatedSprite.animation == "shot_2" or animatedSprite.animation == "shot_3" or animatedSprite.animation == "shot_4" or animatedSprite.animation == "shot_5":
		turn_and_face_player()
		force_movement(0)
		dash_smoke.emitting = false
	if not fire_laser:
		if animatedSprite.animation == "shot_1" or animatedSprite.animation == "shot_2" or animatedSprite.animation == "shot_3" or animatedSprite.animation == "shot_4" or animatedSprite.animation == "shot_5":
			if main.only_zero and not CharacterManager.track_bullet:
				fire_bullet()
			else:
				fire_bullet_lock_player()
			Tools.timer(shot_time, "fire_again", self)
			fire_laser = true
	if not fire_laser:
		if animatedSprite.animation == "rolling":
			fire_bullet_lock_player()
			Tools.timer(shot_time, "fire_again", self)
			fire_laser = true
	
	if attack_stage == 0:
		turn_and_face_player()
		if not is_player_above(32):
			play_animation("shot_3")
		elif is_player_nearby_horizontally(32) and is_player_above(32):
			play_animation("shot_1")
		else:
			play_animation("shot_2")
		if not next_movement:
			next_movement = true
			Tools.timer(1, "next_attack_stage", self)
	
	elif attack_stage == 1:
		timer = 0
		if main.only_zero and not boss_ai.used_desperation:
			play_animation("walk")
			force_movement(90)
		else:
			play_animation("dash")
			force_movement(dash_speed)
			dash_smoke.emitting = true
			sfx_dash.play()
		next_attack_stage()
				
	elif attack_stage == 2 and timer > 1.0 or attack_stage == 2 and facing_a_wall():
		turn_and_face_player()
		if not is_player_above(32):
			play_animation("shot_3")
		elif is_player_nearby_horizontally(32) and is_player_above(32):
			play_animation("shot_1")
		else:
			play_animation("shot_2")
		if not next_movement:
			next_movement = true
			Tools.timer(1, "next_attack_stage", self)
			
	elif attack_stage == 3:
		timer = 0
		if main.only_zero and not boss_ai.used_desperation:
			play_animation("walk")
			force_movement(90)
		else:
			play_animation("dash")
			force_movement(dash_speed)
			dash_smoke.emitting = true
			sfx_dash.play()
		next_attack_stage()
		
	elif attack_stage == 4 and timer > 1.0 or attack_stage == 2 and facing_a_wall():
		turn_and_face_player()
		if not is_player_above(32):
			play_animation("shot_3")
		elif is_player_nearby_horizontally(32) and is_player_above(32):
			play_animation("shot_1")
		else:
			play_animation("shot_2")
		if not next_movement:
			next_movement = true
			Tools.timer(1, "next_attack_stage", self)

	elif attack_stage == 5:
		timer = 0
		if boss_ai.used_desperation:
			go_to_attack_stage(7)
		else:
			if main.only_zero:
				play_animation("walk")
				force_movement(90)
			else:
				play_animation("dash")
				force_movement(dash_speed)
				dash_smoke.emitting = true
				sfx_dash.play()
			next_attack_stage()
			
	elif attack_stage == 6 and timer > 1.0 or attack_stage == 2 and facing_a_wall():
		turn_and_face_player()
		if not is_player_above(32):
			play_animation("shot_3")
		elif is_player_nearby_horizontally(32) and is_player_above(32):
			play_animation("shot_1")
		else:
			play_animation("shot_2")
		if not next_movement:
			next_movement = true
			Tools.timer(1, "next_attack_stage", self)
			
	elif attack_stage == 7:
		timer = 0
		play_animation("idle")
		turn_and_face_player()
		decay_speed_regardless_of_direction()
		next_attack_stage()
	
	elif attack_stage == 8 and timer > 0.5:
		timer = 0
		play_animation("rolling")
		sfx_jump.play()
		force_movement(311)
		set_vertical_speed(-435)
		next_attack_stage()

	elif attack_stage == 9 and character.is_on_floor() and timer > 0.3 or attack_stage == 9 and global_position.y > main.land_position.y -4 and timer > 0.3:
		set_vertical_speed(50)
		sfx_land.play()
		go_to_attack_stage(10)
		
	elif attack_stage >= 10:
		EndAbility()

func _Interrupt() -> void :
	._Interrupt()
	main.use_desperation += 1
	dash_smoke.emitting = false

func fire_bullet() -> void :
	bullet_sfx.play()
	create_bullet(global_position)

func fire_bullet_lock_player() -> void :
	bullet_sfx.play()
	create_bullet_lock_player(global_position)

func create_bullet(ground_position) -> void :
	var instance = bullet.instance()
	ground_position.y += 0
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)
	if animatedSprite.animation == "shot_1":
		instance.set_global_position(global_position + Vector2( 2 * get_facing_direction(), -36))
		instance.rotate_degrees(-90)
		instance.set_horizontal_speed(0)
		instance.set_vertical_speed(-450)
	elif animatedSprite.animation == "shot_2":
		instance.set_global_position(global_position + Vector2( 26 * get_facing_direction(), -30))
		instance.set_horizontal_speed(450 * sin(45) * get_facing_direction())
		instance.set_vertical_speed(-450 * sin(45))
		if character.facing_right:
			instance.rotate_degrees(-45)
		else:
			instance.rotate_degrees(-135)
	elif animatedSprite.animation == "shot_3":
		instance.set_global_position(global_position + Vector2( + 36 * get_facing_direction(), -8))
		if character.facing_right:
			instance.set_horizontal_speed(450)
			instance.scale.x = 1
		else:
			instance.set_horizontal_speed(-450)
			instance.scale.x = -1
	elif animatedSprite.animation == "shot_4":
		instance.set_global_position(global_position + Vector2( 30 * get_facing_direction(), 14))
		instance.set_horizontal_speed(450 * sin(45) * get_facing_direction())
		instance.set_vertical_speed(450 * sin(45))
		if character.facing_right:
			instance.rotate_degrees(45)
		else:
			instance.rotate_degrees(135)
	elif animatedSprite.animation == "shot_5":
		instance.set_global_position(global_position + Vector2( 10 * get_facing_direction(), 28))
		instance.rotate_degrees(90)
		instance.set_horizontal_speed(0)
		instance.set_vertical_speed(450)
	else:
		instance.set_global_position(global_position)
		if character.facing_right:
			instance.set_horizontal_speed(450)
			instance.scale.x = 1
		else:
			instance.set_horizontal_speed(-450)
			instance.scale.x = -1
	instance.initialize(1)

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
		instance.set_global_position(global_position)
	get_tree().current_scene.get_node("Objects").call_deferred("add_child", instance, true)

func get_player_angle(global_position : Vector2) -> Vector2:
	var speed = clamp(GameManager.player.get_horizontal_speed(),-30,30)
	var player_pos = GameManager.get_player_position() + Vector2(speed,-5)
	return ((player_pos) - global_position).normalized()
