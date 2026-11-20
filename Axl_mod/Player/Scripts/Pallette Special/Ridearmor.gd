extends Weapon

const minimum_time_between_recharges: float = 0.2

export  var recharge_rate: float = 1.0
export  var weapon: Resource

onready var parent: = get_parent()
onready var animatedsprite: AnimatedSprite = $"../../animatedSprite"
onready var weapon_stasis: Node2D = $"../../WeaponStasis"
onready var jump_damage: Node2D = $"../../JumpDamage"
onready var vfx: AnimatedSprite = $break_vfx


var timer: float = 0.0
var last_time_hit: float = 0.0

var vfx_casted: bool = false
var recover_ammo = 0.5
var recharge_ammo = 1.0

func _ready() -> void :
	character.listen("equipped_armor", self, "on_equip")
	character.listen("zero_health", self, "on_zero_health")
	Event.listen("hit_enemy", self, "recharge")
	Event.listen("enemy_kill", self, "recharge")
	current_ammo = max_ammo
	on_equip()
	vfx.show()

func recharge(_d = null) -> void :
	if is_instance_valid(GameManager.player):
		if GameManager.player.ride:
			return
	if active and current_ammo < max_ammo:
		if timer > last_time_hit + minimum_time_between_recharges:
			last_time_hit = timer
			current_ammo = clamp(current_ammo + recharge_ammo, 0.0, max_ammo)

func on_equip() -> void :
	active = true
	Event.emit_signal("special_activated", self, character)
	parent.update_list_of_weapons()
	set_physics_process(active)

func _input(_event: InputEvent) -> void :
	if active and has_ammo() and character.has_control() and not character.is_riding():
		fire()

func fire(_charge_level: = 0) -> void :
	if active and has_ammo() and character.has_control():
		pass

func has_ammo() -> bool:
	return current_ammo >= max_ammo/2

func has_ammo_expent(expent) -> bool:
	return current_ammo >= expent

func can_shoot() -> bool:
	return has_ammo()

func reduce_ammo(expent):
	current_ammo -= expent

func on_zero_health() -> void :
	animatedsprite.modulate = Color.white

func _physics_process(delta: float) -> void :
	timer += delta
	if is_instance_valid(GameManager.player):
		if GameManager.player.ride:
			return
	if current_ammo < max_ammo:
		current_ammo = clamp(current_ammo + delta * recover_ammo, 0.0, max_ammo)

	if has_ammo() and not vfx_casted:
		vfx.frame = 0
		vfx_casted = true
		
	elif not has_ammo() and vfx_casted:
		vfx_casted = false

