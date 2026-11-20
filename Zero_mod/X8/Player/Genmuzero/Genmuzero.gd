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

var stop_recover: bool = false
var vfx_casted: bool = false
var reduce_ammo_at_start: bool = false
var first_time_casted: bool = false
var already_reduce: bool = false
var recover_ammo = 0.5
var upgraded_recover_ammo = 0.5
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
	if active and current_ammo < max_ammo and not stop_recover:
		if timer > last_time_hit + minimum_time_between_recharges:
			last_time_hit = timer
			current_ammo = clamp(current_ammo + recharge_ammo, 0.0, max_ammo)

func on_equip():
	active = true
	Event.emit_signal("special_activated", self, character)
	parent.update_list_of_weapons()
	set_physics_process(active)
	first_time_casted = false

func _input(_event: InputEvent) -> void :
	if active and has_ammo() and character.has_control() and not character.is_riding():
		pass
		#if event.is_action_pressed("select_special"):
		#fire()

func fire(_charge_level: = 0) -> void :
	if active and has_ammo() and character.has_control():
		pass
		#reduce_ammo(0.001)
		#character.execute_genmu_zero = true
		#Input.action_press("select_special")

func has_ammo() -> bool:
	return current_ammo >= max_ammo

func has_ammo_59() -> bool:
	return current_ammo >= 59

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
	if current_ammo < max_ammo and not stop_recover:
		if not first_time_casted:
			current_ammo = clamp(current_ammo + delta * recover_ammo, 0.0, max_ammo)
		if first_time_casted:
			current_ammo = clamp(current_ammo + delta * upgraded_recover_ammo, 0.0, max_ammo)

	if has_ammo() and not vfx_casted:
		vfx.frame = 0
		vfx_casted = true
		
	elif not has_ammo() and vfx_casted:
		vfx_casted = false
		
	if vfx_casted:
		if not first_time_casted:
			first_time_casted = true
			vfx.show()
			if CharacterManager.awakened_zero_armor:
				Tools.timer(1.0, "hide", self)
	
	if CharacterManager.awakened_zero_armor and CharacterManager.awakened_zero_full_power_max:
		hide()
	
	if reduce_ammo_at_start and not already_reduce:
		reduce_ammo_at_start = false
		first_time_casted = false
		already_reduce = true
		reduce_ammo(ammo_per_shot)

func hide() -> void :
	vfx.hide()
