extends Fall

onready var driftdiamond: = $"../Shot/DriftDiamond"
export  var hitbox: Resource = preload("res://X_mod/UltimateX/Player/NovaStrike/NovaStrike_Hitbox.tscn")

var current_hitbox = null
var hitbox_upleft = Vector2(0, 0)
var hitbox_downright = Vector2(0, 0)
var hitbox_damage = 0
var hitbox_damage_boss = 0
var hitbox_damage_weakness = 0
var hitbox_break_guard_value = 0.25
var hitbox_break_guards: bool = true
var hitbox_rehit_time = 0.075

var hitbox_upgraded: bool = true
var hitbox_extra_damage = 1
var hitbox_extra_damage_boss = 1
var hitbox_extra_damage_weakness = 1
var hitbox_extra_break_guard_value = 1

var deflectable: bool = true
var ending_saber_state: bool = true
onready var arm_cannon = character.get_node("Shot")

onready var animatedSprite = character.get_node("animatedSprite")

onready var vfx: AnimatedSprite = $break_vfx
var buffed: = false
onready var trail: Line2D = $node / trail
onready var activate: AudioStreamPlayer2D = $activate
onready var flash: Sprite = $flash
onready var particles_2d: Particles2D = $particles2D

func _ready():
	CharacterManager.xdrive = false
	animatedSprite.connect("animation_finished", self, "_on_animation_finished")
	Event.listen("character_switch", self, "remove_buff")

func _on_animation_finished() -> void :
	ending_saber_state = true

func end_state():
	return ending_saber_state

func apply_buff() -> void :
	if not buffed:
		activate.play()
		flash.start()
		particles_2d.emitting = true
		character.add_invulnerability("xdrive")
		vfx.frame = 0
		buffed = true
		Event.emit_signal("xdrive")
		CharacterManager.xdrive = true

func remove_buff() -> void :
	character.remove_invulnerability("xdrive")
	trail.visible = false
	buffed = false
	if is_instance_valid(particles_2d):
		particles_2d.emitting = false
	Event.emit_signal("special_end")
	CharacterManager.xdrive = false

func _StartCondition() -> bool:
	if not driftdiamond.has_max_ammo():
		return false
	if not arm_cannon.xdrive:
		return false
	if character.get_action_pressed("select_special"):
		return true
	return false

func _ResetCondition() -> bool:
	return false

func _EndCondition() -> bool:
	if not animatedSprite.animation == "damage":
		return true
	if end_state():
		return true
	return false

func _Setup() -> void :
	apply_buff()
	ending_saber_state = false

func _Update(_delta: float) -> void :
	pass

func change_animation_if_falling(_s) -> void :
	pass

func Initialize() -> void :
	executing = true
	timer = 0
	last_time_used = get_time()
	character.executing_moves.append(self)
	emit_signal("executed")
	play_sound_on_initialize()
	play_animation_on_initialize()

func BeforeEveryFrame(_delta: float) -> void :
	pass
