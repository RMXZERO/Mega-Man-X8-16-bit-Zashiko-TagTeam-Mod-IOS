extends Node2D

export  var active: bool = false

onready var mubarrier: AnimatedSprite = $"../animatedSprite/mu_barrier"
onready var character = get_parent()
onready var damage: = $"../Damage"
onready var on_sound = $mubarrieron
onready var off_sound: = $mubarrieroff

var allow_summon_barrier: bool = true
var rotation_speed: int = 15

func _Update(delta: float) -> void :
	._Update(delta)

func _ready() -> void :
	if active:
		deactivate()
		allow_summon_barrier = true
		character.listen("equipped_armor", self, "check")
		character.listen("zero_health", self, "deactivate")
		Event.connect("player_death", self, "deactivate")
		Event.listen("character_switch", self, "deactivate")
		Event.listen("character_switch_end", self, "check")
		Event.listen("weapon_select_left", self, "check")
		Event.listen("weapon_select_right", self, "check")
		Event.connect("pause_menu_closed", self, "check")
		Event.listen("weapon_select_buster", self, "check")
		Event.listen("ridearmor_activate", self, "deactivate")
		Event.listen("ridearmor_deactivate", self, "check")
		Event.listen("collected", self, "check")
		Event.listen("select_weapon", self, "check")
		character.listen("damage", self, "deactivate2")
		character.listen("weapon_selected", self, "check")

func check(_d = null) -> void :
	if CharacterManager.player_character == "Zero":
		if character.saber_node.current_weapon.name != "Rogue-Blade":
			deactivate()
		else:
			activate()

func _physics_process(delta: float) -> void :
	if active:
		mubarrier.get_node("mu_barrier").rotation_degrees += delta * rotation_speed
		mubarrier.get_node("mu_barrier2").rotation_degrees -= delta * rotation_speed
		mubarrier.get_node("mu_barrier3").rotation_degrees += delta * rotation_speed

func activate() -> void :
	if allow_summon_barrier:
		if not active:
			active = true
			damage.active = false
			mubarrier.show()
			on_sound.play()
			allow_summon_barrier = false

func deactivate() -> void :
	if active:
		active = false
		damage.active = true
		mubarrier.hide()
		allow_summon_barrier = true

func deactivate2(_damage_value: float, _inflicter: Object) -> void :
	if active:
		active = false
		deflect_damage()
		damage.active = true
		mubarrier.hide()
		off_sound.play()
		Tools.timer(5.0, "reset", self)
		Tools.timer(5.0, "check", self)

func deflect_damage() -> void :
	character.flash()
	character.set_invulnerability(damage.invulnerability_time)
	character.last_hit_time = 0
	character.apply_invulnerability_shader()
	character.emit_signal("received_damage", character)
	Event.emit_signal("damage")
	Event.emit_signal("mu_barrier_break")

func reset() -> void :
	allow_summon_barrier = true

