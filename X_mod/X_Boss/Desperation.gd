extends AttackAbility

export  var damage_reduction: = 0.5
var images: Array
const move_duration: = 0.5
export  var _slash: PackedScene
onready var tween: = TweenController.new(self, false)
onready var damage: Node2D = $"../Damage"
onready var damage_on_touch: Node2D = $"../DamageOnTouch"
onready var nova_strike_sfx: AudioStreamPlayer = $nova_strike_sfx
onready var victory = $victory
var angles = [0, 45, 90, 135, 180, 225, 270, 315]

onready var disappear: AudioStreamPlayer2D = $disappear
onready var charge: AudioStreamPlayer2D = $charge
onready var cuts_prepare: AudioStreamPlayer2D = $cuts_prepare

onready var boss_ai = get_parent().get_node("BossAI")

onready var novastrike = $"../NovaStrike/nova_strike"
var next_time_nova_strike_damage = 16
var end: bool = false

var last_position: Vector2
var l = 5
var i = 0.125
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
	last_position = character.global_position
	turn_and_face_player()
	play_animation("victory")
	victory.play()
	charge.play()
	call_deferred("set_scale_x")
	damage.remove_weaknesses()
	l = 5 + CharacterManager.game_mode
	i = 0.125
	h = 0
	end = false

func set_scale_x():
	scale.x = get_facing_direction()

func _Update(delta: float) -> void :
	process_gravity(delta)
	
	if attack_stage == 0 and timer > 0.4:
		call_deferred("decay_speed", 1, 1.5)
		next_attack_stage()
	
	elif attack_stage == 1 and timer > 0.85:
		play_animation("nova_strike_start")
		set_vertical_speed(-250)
		force_movement(250)
		disappear.play()
		damage.deactivate()
		damage_on_touch.deactivate()
		next_attack_stage()
	
	elif attack_stage == 2 and has_finished_last_animation():
		play_animation("empty")
		create_nova_strike()
		next_attack_stage()

	elif attack_stage == 3 and timer > l + 1:
		character.global_position = last_position
		play_animation("shot_recover")
		damage.activate()
		damage_on_touch.activate()
		decay_speed(1, 0.25)
		novastrike_update()
		next_attack_stage()
		
	elif attack_stage == 4 and has_finished_last_animation():
		EndAbility()
		
	elif attack_stage == 10:
		damage.activate()
		damage_on_touch.activate()
		decay_speed(1, 0.25)
		EndAbility()
		_Interrupt()

func novastrike_update() -> void :
	if not end:
		end = true
		novastrike.damage += 16
		next_time_nova_strike_damage += 16
		if CharacterManager.nightshade_zero_armor:
			novastrike.damage += 16
			next_time_nova_strike_damage += 16

func _Interrupt():
	character.emit_signal("damage_reduction", 1.0)
	._Interrupt()
	damage.activate()
	damage_on_touch.activate()
	boss_ai.decide_time_for_next_attack()

func vanish_clones():
	for clone in images:
		clone.play(clone.animation + "_vanish")

func create_nova_strike():
	while i < l:
		Tools.timer_p(i, "create_slash", self, angles[h])
		i += 0.125
		h += 1
		if h > angles.size() - 1:
			h = 0

func create_slash(degrees: float) -> void :
	nova_strike_sfx.play()
	var instance = _slash.instance()
	if degrees == 0:
		instance.set_vertical_speed(800)
	if degrees == 45:
		instance.set_vertical_speed(800 * sin(45))
		instance.set_horizontal_speed(- 800 * sin(45))
	if degrees == 90:
		instance.set_horizontal_speed(- 800)
	if degrees == 135:
		instance.set_vertical_speed(- 800 * sin(45))
		instance.set_horizontal_speed(- 800 * sin(45))
	if degrees == 180:
		instance.set_vertical_speed(- 800)
	if degrees == 225:
		instance.set_vertical_speed(- 800 * sin(45))
		instance.set_horizontal_speed(800 * sin(45))
	if degrees == 270:
		instance.set_horizontal_speed(800)
	if degrees == 315:
		instance.set_vertical_speed(800 * sin(45))
		instance.set_horizontal_speed(800 * sin(45))
	instance.get_node("DamageOnTouch").damage = next_time_nova_strike_damage
	get_tree().current_scene.add_child(instance, true)
	instance.set_global_position(GameManager.get_player_position())
	instance.rotate_degrees(degrees)
	instance.initialize(1)
