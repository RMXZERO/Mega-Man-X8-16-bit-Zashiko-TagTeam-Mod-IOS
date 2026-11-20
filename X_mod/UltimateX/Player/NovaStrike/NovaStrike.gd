extends Weapon

export  var recharge_rate: = 1.0
export  var weapon: Resource
export  var is_lock_ultimate: bool = false
onready var parent: = get_parent()
onready var ultimate_armor = character.get_node("animatedSprite").get_node_or_null("ultimate_armor")
onready var ultimate_canon = character.get_node("animatedSprite").get_node_or_null("ultimate_canon")
onready var animatedsprite: AnimatedSprite = $"../../animatedSprite"
onready var weapon_stasis: Node2D = $"../../WeaponStasis"
onready var nova_strike: Node2D = $"../../NovaStrike"
onready var jump_damage: Node2D = $"../../JumpDamage"

onready var OriginalMainColor1: Color = weapon.MainColor1
onready var OriginalMainColor2: Color = weapon.MainColor2
onready var OriginalMainColor3: Color = weapon.MainColor3
onready var OriginalMainColor4: Color = MainColor4
onready var OriginalMainColor5: Color = MainColor5
onready var OriginalMainColor6: Color = MainColor6

onready var OriginalCrystalColor1: Color = weapon.CrystalColor1
onready var OriginalCrystalColor2: Color = weapon.CrystalColor2
onready var OriginalCrystalColor3: Color = weapon.CrystalColor3
onready var OriginalCrystalColor4: Color = weapon.CrystalColor4

var CrystalColor1: Color
var CrystalColor2: Color
var CrystalColor3: Color
var CrystalColor4: Color

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

var stop_recover: bool = false
var timer: = 0.0
var last_time_hit: = 0.0
const minimum_time_between_recharges: = 0.2
var vfx_casted: bool = false

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
	if active and has_ammo() and character.has_control() and not character.is_riding():
		if event.is_action_pressed("select_special"):
			fire()

func fire_charged(_charge_level):
	if active and has_ammo() and character.has_control():
		if not character.is_full_armor() == "ultimate":
			return
		jump_damage.effect.visible = false
		Input.action_press("select_special")

func fire(_charge_level: = 0) -> void :
	if active and has_ammo() and character.has_control():
		if not character.is_full_armor() == "ultimate":
			return
		jump_damage.effect.visible = false
		Input.action_press("select_special")

func on_equip():
	if character.is_full_armor() == "ultimate":
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

	if not has_ammo() and vfx_casted:
		vfx_casted = false

	if has_ammo():
		cycle_colors()
		parent.update_character_palette()
		if arm_cannon.current_weapon.name == "NovaStrike":
			#or "Buster" in arm_cannon.current_weapon.name:
			if is_lock_ultimate:
				set_new_colors_on_shader_parameters(animatedsprite)
			if ultimate_armor:
				set_new_colors_on_shader_parameters(ultimate_armor)
			if ultimate_canon:
				set_new_colors_on_shader_parameters(ultimate_canon)
		else:
			if is_lock_ultimate:
				reset_colors_on_shader_parameters(animatedsprite)
			if ultimate_armor:
				reset_colors_on_shader_parameters(ultimate_armor)
			if ultimate_canon:
				reset_colors_on_shader_parameters(ultimate_canon)
			parent.update_character_palette()
	else:
		if tween and tween.is_valid():
			tween.kill()
			if is_lock_ultimate:
				reset_colors_on_shader_parameters(animatedsprite)
			if ultimate_armor:
				reset_colors_on_shader_parameters(ultimate_armor)
			if ultimate_canon:
				reset_colors_on_shader_parameters(ultimate_canon)
			parent.update_character_palette()

const color_cycle_duration: = 0.25
func cycle_colors() -> void :
	if CharacterManager.hide_x_armor:
		return
	if not tween or not tween.is_valid():
		tween = create_tween().set_loops()
		tween.tween_property(self, "CrystalColor1", Color("#FFFFFF"), color_cycle_duration)
		tween.set_parallel().tween_property(self, "CrystalColor2", OriginalCrystalColor1, color_cycle_duration * 2)
		tween.set_parallel().tween_property(self, "CrystalColor3", OriginalCrystalColor2, color_cycle_duration * 2)
		tween.set_parallel().tween_property(self, "MainColor1", Color("#FFFFFF"), color_cycle_duration * 2)
		tween.set_parallel().tween_property(self, "MainColor2", OriginalMainColor1, color_cycle_duration * 2)
		tween.set_parallel().tween_property(self, "MainColor3", OriginalMainColor2, color_cycle_duration * 2)
		
		tween.chain().tween_property(self, "CrystalColor1", OriginalCrystalColor2, color_cycle_duration)
		tween.set_parallel().tween_property(self, "CrystalColor2", OriginalCrystalColor3, color_cycle_duration * 2)
		tween.set_parallel().tween_property(self, "CrystalColor3", OriginalCrystalColor4, color_cycle_duration * 2)
		tween.set_parallel().tween_property(self, "MainColor1", OriginalMainColor1, color_cycle_duration * 2)
		tween.set_parallel().tween_property(self, "MainColor2", OriginalMainColor2, color_cycle_duration * 2)
		tween.set_parallel().tween_property(self, "MainColor3", OriginalMainColor3, color_cycle_duration * 2)

func set_new_colors_on_shader_parameters(object) -> void :
	if not CharacterManager.hide_x_armor:
		object.material.set_shader_param("R_CrystalColor1", CrystalColor1)
		object.material.set_shader_param("R_CrystalColor2", CrystalColor2)
		object.material.set_shader_param("R_CrystalColor3", CrystalColor3)
		object.material.set_shader_param("R_ArmorColor1", MainColor1)
		object.material.set_shader_param("R_ArmorColor2", MainColor2)
		object.material.set_shader_param("R_ArmorColor3", MainColor3)

func reset_colors_on_shader_parameters(object) -> void :
	if not CharacterManager.hide_x_armor:
		object.material.set_shader_param("R_CrystalColor1", OriginalCrystalColor2)
		object.material.set_shader_param("R_CrystalColor2", OriginalCrystalColor3)
		object.material.set_shader_param("R_CrystalColor3", OriginalCrystalColor4)
		object.material.set_shader_param("R_ArmorColor1", OriginalMainColor1)
		object.material.set_shader_param("R_ArmorColor2", OriginalMainColor2)
		object.material.set_shader_param("R_ArmorColor3", OriginalMainColor3)

