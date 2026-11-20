extends AttackAbility

onready var main: = get_parent()

onready var tween: = TweenController.new(self, false)
onready var damage: Node2D = $"../Damage"
onready var damage_on_touch: Node2D = $"../DamageOnTouch"
onready var boss_2_bar: Node2D = $"../HPSprite"

onready var disappear: AudioStreamPlayer2D = $disappear
onready var asobiwaowarida: AudioStreamPlayer = $asobiwaowarida
onready var awaken_end: AudioStreamPlayer = $awaken_end
onready var boom: AudioStreamPlayer = $boom

onready var boss_ai = get_parent().get_node("BossAI")
onready var death = get_parent().get_node("BossDeath")
onready var effect = animatedSprite.get_node("effectSprite")
onready var genmu_effect = effect.get_node("genmu_effect")

var first_awakened: bool = false
var can_awakened_time: float = 0.0
var use_awakened_time: float = 0.0
var play_sound: bool = false
var time_offset: float = 0.0
var amplitude: float = 16.0
var speed: float = 1.0

func _ready() -> void :
	Tools.timer(1, "check_mode", self)

func check_mode() -> void :
	use_awakened_time = 0
	if main.only_x:
		can_awakened_time += 1
		
	if not main.only_x:
		first_awakened = true
		character.emit_signal("damage_reduction", 0.5)
		
	if "X" in CharacterManager.team:
		if CharacterManager.infinite_x_activated:
			can_awakened_time += 1
	if "Zero" in CharacterManager.team:
		if CharacterManager.awakened_zero_armor and CharacterManager.awakened_zero_full_power_max:
			can_awakened_time += 1
	if "Axl" in CharacterManager.team:
		if CharacterManager.cheat_axl_activated:
			can_awakened_time += 1
		
	if CharacterManager.nightshade_zero_armor:
		can_awakened_time += 1
		
	if can_awakened_time > 0:
		death.awakened = false
	else:
		death.awakened = true
		
	print("will awakened " + String(can_awakened_time) + " time")

func _Setup() -> void :
	play_sound = false
	damage.deactivate()
	damage_on_touch.deactivate()
	death.deactivate()
	character.set_horizontal_speed(0)
	character.set_vertical_speed(0)
	disappear.play()
	effect.visible = false
	play_animation("vanish")

func set_scale_x():
	scale.x = get_facing_direction()

func _Update(delta: float) -> void :
	if attack_stage == 0:
		next_attack_stage()
		
	elif attack_stage == 1 and timer > 0.5:
		character.global_position = GameManager.camera.get_camera_screen_center()
		if not first_awakened:
			play_animation("awakened_ready")
			next_attack_stage()
		else:
			go_to_attack_stage(3)
	
	elif attack_stage == 2 and timer > 5:
		next_attack_stage()
	
	elif attack_stage == 3:
		if not first_awakened:
			play_animation("awakened_ready_end")
		else:
			play_animation("awakened_ready")
		boom.play()
		Event.emit_signal("screenshake", 1000)
		timer = 0
		next_attack_stage()
	
	elif attack_stage == 4 and timer > 0.2:
		if not first_awakened:
			effect.scale.x = 1.5
			effect.scale.y = 1.5
			play_animation("awakened_ready_loop")
		else:
			play_animation("awakened2_loop")
		awaken_end.play()
		effect.visible = true
		effect.speed_scale = 10/3
		genmu_effect.visible = true
		Event.emit_signal("boss_health_hide")
		character.current_health = character.max_health
		if not CharacterManager.fight_boss_2:
			Event.emit_signal("boss_health_appear", character)
		if CharacterManager.fight_boss_2:
			boss_2_bar.boss_hp_filled = false
			boss_2_bar.boss_filling_hp = 0
		character.emitted_zero_health = false
		next_attack_stage()

	elif attack_stage == 5:
		if not first_awakened:
			time_offset += delta * speed * 7
			animatedSprite.position.y = -4 + amplitude * sin(time_offset)
			effect.scale.x = clamp(effect.scale.x - delta * 0.3, 1, 1.5)
			effect.scale.y = clamp(effect.scale.y - delta * 0.3, 1, 1.5)
		else:
			Event.emit_signal("screenshake", 1)
			animatedSprite.position.y = -4
		if animatedSprite.position.y >= -5 and animatedSprite.position.y <= -3:
			if timer > 1.5:
				if not play_sound:
					play_sound = true
					if not first_awakened:
						asobiwaowarida.play()
					else:
						next_attack_stage()
			if timer > 3:
				next_attack_stage()
		
	elif attack_stage == 6:
		process_gravity(delta)
		play_animation("fall")
		effect.scale.x = 1
		effect.scale.y = 1
		if not main.only_x:
			effect.visible = false
		if not first_awakened:
			effect.speed_scale = 1
			genmu_effect.visible = false
		animatedSprite.position.y = -4
		animatedSprite.frame = 2
		next_attack_stage()
		
	elif attack_stage == 7:
		process_gravity(delta)
		if character.is_on_floor():
			next_attack_stage()
		
	elif attack_stage == 8:
		play_animation("idle")
		EndAbility()

func _Interrupt():
	._Interrupt()
	reset_state()

func reset_state():
	if play_sound:
		play_sound = false
		reset_attack()
		first_awakened = true
		can_awakened_time -= 1
		if not can_awakened_time > 0:
			death.awakened = true
		use_awakened_time += 1
		if use_awakened_time <= 2:
			character.emit_signal("damage_reduction", 0.5)
		else:
			character.emit_signal("damage_reduction", 0.1)

func reset_attack():
	damage.activate()
	damage_on_touch.activate()
	damage_on_touch.can_hit = true
	death.activate()
	boss_ai.used_desperation = true
	animatedSprite.position.y = -4
	effect.scale.x = 1
	effect.scale.y = 1
	
	$"../animatedSprite/7SlashCombo/catch_player".can_hit = true
	$"../animatedSprite/7SlashCombo/saber1".can_hit = true
	$"../animatedSprite/7SlashCombo/saber2".can_hit = true
	$"../animatedSprite/7SlashCombo/saber3".can_hit = true
	$"../animatedSprite/7SlashCombo/saber4".can_hit = true
	$"../animatedSprite/7SlashCombo/saber5".can_hit = true
	$"../animatedSprite/7SlashCombo/saber6".can_hit = true
	$"../animatedSprite/7SlashCombo/risingsaber".can_hit = true
	
	$"../animatedSprite/SaberCombo/risingsaber".can_hit = true
	$"../animatedSprite/SaberCombo/spinslash".can_hit = true
	
	$"../animatedSprite/SaberCombo/saber1".can_hit = true
	$"../animatedSprite/SaberCombo/saber2".can_hit = true
	$"../animatedSprite/SaberCombo/saber3".can_hit = true
	$"../animatedSprite/SaberCombo/chargesaber".can_hit = true






