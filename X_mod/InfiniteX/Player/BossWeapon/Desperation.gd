extends Weapon

export  var recharge_rate: = 1.0
export  var weapon: Resource
onready var parent: = get_parent()
onready var animatedsprite: AnimatedSprite = $"../../animatedSprite"
onready var weapon_stasis: Node2D = $"../../WeaponStasis"
onready var nova_strike: Node2D = $"../../NovaStrike"
onready var jump_damage: Node2D = $"../../JumpDamage"

onready var vfx: AnimatedSprite = $break_vfx

onready var tween: SceneTreeTween

onready var air_dash: Node2D = $"../../AirDash"
onready var dash: Node2D = $"../../Dash"
onready var life_steal: Node2D = $"../../LifeSteal"
onready var charge: Node2D = $"../../Charge"
onready var trail: Line2D = $node / trail
onready var sprite: AnimatedSprite = $"../../animatedSprite"
onready var activate: AudioStreamPlayer2D = $activate
onready var flash: Sprite = $flash
onready var particles_2d: Particles2D = $particles2D

signal activated
signal deactivated

var timer: = 0.0
var last_time_hit: = 0.0
const minimum_time_between_recharges: = 0.2
var vfx_casted: bool = false
var stop_recover: bool = false

func _ready() -> void :
	character.listen("equipped_armor", self, "on_equip")
	character.listen("zero_health", self, "on_zero_health")
	Event.listen("hit_enemy", self, "recharge")
	Event.listen("enemy_kill", self, "recharge")
	current_ammo = max_ammo

func recharge(_d = null):
	if is_instance_valid(GameManager.player):
		if GameManager.player.ride:
			return
	if active and current_ammo < max_ammo and not stop_recover:
		if timer > last_time_hit + minimum_time_between_recharges:
			last_time_hit = timer
			current_ammo = clamp(current_ammo + 1.0, 0.0, max_ammo)

func _input(event: InputEvent) -> void :
	if active and has_ammo() and character.has_control() and not character.is_riding() and character.is_on_floor():
		if event.is_action_pressed("select_special") and event.is_action_pressed("move_up"):
			fire()

func fire_charged(_charge_level):
	if active and has_ammo() and character.has_control() and character.is_on_floor():
		if character.get_action_pressed("select_special") and character.get_action_pressed("move_up"):
			vfx_casted = false
			jump_damage.effect.visible = false
			reduce_ammo(ammo_per_shot)

func fire(_charge_level: = 0) -> void :
	if active and has_ammo() and character.has_control() and character.is_on_floor():
		if character.get_action_pressed("select_special") and character.get_action_pressed("move_up"):
			vfx_casted = false
			jump_damage.effect.visible = false
			reduce_ammo(ammo_per_shot)

func on_equip():
	if character.is_full_armor() == "infinite":
		active = true
		Event.emit_signal("special_activated", self, character)
	else:
		active = false
		Event.emit_signal("special_deactivated", self, character)
		if parent.current_weapon == self:
			parent.set_buster_as_weapon()
	parent.update_list_of_weapons()
	set_physics_process(active)

func has_ammo() -> bool:
	return current_ammo >= max_ammo

func can_shoot() -> bool:
	return has_ammo()

func _physics_process(delta: float) -> void :
	timer += delta
	if is_instance_valid(GameManager.player):
		if GameManager.player.ride:
			return
	if not stop_recover:
		if current_ammo < max_ammo:
			current_ammo = clamp(current_ammo + delta * 10, 0.0, max_ammo)
	
	if has_ammo() and not vfx_casted:
		vfx.frame = 0
		vfx_casted = true
