extends AttackAbility

onready var main: = get_parent()

export  var damage_reduction: = 0.5
var images: Array
const move_duration: = 0.5
export  var _slash: PackedScene
onready var tween: = TweenController.new(self, false)
onready var damage: Node2D = $"../Damage"
onready var damage_on_touch: Node2D = $"../DamageOnTouch"
var angles = [0, 33, - 33, 90, 44, - 44, 25, - 25, 0, 90, 44, - 25, - 33]

onready var disappear: AudioStreamPlayer2D = $disappear
onready var charge: AudioStreamPlayer2D = $charge
onready var cuts_prepare: AudioStreamPlayer2D = $cuts_prepare

onready var boss_ai = get_parent().get_node("BossAI")
onready var deflect_skill = get_parent().get_node("Deflect")
onready var reflector: Node2D = $"../DamageReflector"
onready var effect = animatedSprite.get_node("effectSprite")


var l = 5
var i = 0.075
var h = 0
var deflects_before: int = 0

func _ready() -> void :
	for object in get_children():
		if object is AnimatedSprite:
			images.append(object)
			object.visible = false

func _Setup() -> void :
	damage_reduction = CharacterManager.boss_damage_reduction
	character.emit_signal("damage_reduction", damage_reduction)
	turn_and_face_player()
	play_animation("desperation_start")
	charge.play()
	call_deferred("set_scale_x")
	if CharacterManager.nightshade_zero_armor:
		l = CharacterManager.game_mode * 10 + 5
	else:
		l = 5 + CharacterManager.game_mode
	i = 0.075
	h = 0

func set_scale_x():
	scale.x = get_facing_direction()

func _Update(delta: float) -> void :
	process_gravity(delta)
	if attack_stage == 0 and timer > 0.4:
		force_movement(0)
		call_deferred("decay_speed", 1, 1.5)
		next_attack_stage()
	
	elif attack_stage == 1 and timer > 0.85:
		play_animation("vanish")
		disappear.play()
		damage.deactivate()
		damage_on_touch.deactivate()
		if reflector.deflects > 0:
			deflects_before = reflector.deflects
			reflector.deactivate()
		effect.visible = false
		force_movement(0)
		next_attack_stage()
	
	elif attack_stage == 2 and timer > 1.0:
		create_desperation_slash()
		if CharacterManager.nightshade_zero_armor:
			go_to_attack_stage(10)
		else:
			next_attack_stage()

	elif attack_stage == 3 and timer > l + 1:
		play_animation("vanish")
		damage.activate()
		damage_on_touch.activate()
		decay_speed(1, 0.25)
		next_attack_stage()
		
	elif attack_stage == 4 and has_finished_last_animation():
		play_animation("saber_recover")
		next_attack_stage()
		
	elif attack_stage == 5 and has_finished_last_animation():
		EndAbility()
		
	elif attack_stage == 10:
		damage.activate()
		damage_on_touch.activate()
		decay_speed(1, 0.25)
		EndAbility()
		_Interrupt()

func _Interrupt():
	character.emit_signal("damage_reduction", 1.0)
	._Interrupt()
	damage.activate()
	damage_on_touch.activate()
	if deflects_before > 0:
		reflector.deflects_max = deflects_before
		reflector.reset()
		reflector.activate()
		deflects_before = 0

func emit_clones():
	var clone_pos: = Vector2.ZERO
	var wait_time: = 0.05
	for clone in images:
		clone.visible = false
		if "_vanish" in clone.animation:
			clone.play(clone.animation.substr(0, 2))
		clone_pos = clone.position
		clone.position = Vector2.ZERO
		tween.create(Tween.EASE_OUT, Tween.TRANS_CUBIC)
		tween.add_wait(wait_time)
		tween.add_callback("set_visible", clone, [true])
		tween.add_attribute("position", clone_pos, move_duration, clone)
		wait_time += 0.12

func vanish_clones():
	for clone in images:
		clone.play(clone.animation + "_vanish")

func create_desperation_slash():
	create_slash(0)
	while i < l:
		Tools.timer_p(i, "create_slash", self, angles[h])
		i += 0.075
		h += 1
		if h > angles.size() - 1:
			h = 0

func create_slash(degrees: float):
	var slash = _slash.instance()
	get_tree().current_scene.add_child(slash, true)
	if main.only_x:
		CharacterManager.set_zeroX8_normal_colors(slash.get_node("animatedSprite"))
		CharacterManager.set_saberX8_green(slash.get_node("animatedSprite"))
	if main.only_zero:
		CharacterManager.set_omega_zeroX8_colors(slash.get_node("animatedSprite"))
		CharacterManager.set_saber_omega_pink(slash.get_node("animatedSprite"))
	if main.only_axl:
		CharacterManager.set_new_betazero_fake_colors(slash.get_node("animatedSprite"))
		CharacterManager.set_saberX8_red(slash.get_node("animatedSprite"))
	slash.set_global_position(GameManager.get_player_position())
	slash.rotate_degrees(degrees)
	Tools.timer(0.35, "activate", slash)






