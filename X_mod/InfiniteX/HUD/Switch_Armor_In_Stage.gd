extends X8OptionButton

onready var equip: AudioStreamPlayer = $"../../../../../equip"
#onready var unequip: AudioStreamPlayer = $"../../../../../unequip"
#onready var choice: AudioStreamPlayer = $"../../../../../choice"

var block_switch_armor: bool = false
var last_armor_is_ultimate: bool = false

onready var switch_armor: = get_parent().get_parent().get_parent().get_node("SwitchArmor")
onready var no_armor_holder: = switch_armor.get_node_or_null("no_armor_holder")
onready var icarus_holder: = switch_armor.get_node_or_null("icarus_holder")
onready var hermes_holder: = switch_armor.get_node_or_null("hermes_holder")
onready var ultimate_holder: = switch_armor.get_node_or_null("ultimate_holder")
onready var icon_gold: = get_node_or_null("icon_bg_gold")
onready var icon_infinite: = get_node_or_null("infinite_icon")
onready var block_texture: = get_node_or_null("deactivated")
onready var animated_sprite: AnimatedSprite = get_node_or_null("animatedSprite")

func _ready() -> void :
	._ready()
	Tools.timer(0.1,"show_switch",self)
	Event.connect("collected", self, "show_parts")
	Event.connect("is_zashiko_ultimate_x", self, "on_block_switch_armor")#block switch armor if start level as zashiko ultimate x
	Event.connect("end_teleport_to_red", self, "on_block_switch_armor")#block switch armor at red fight
	Event.connect("collected", self, "hit_as_sigma_virus_fist")#block switch armor if hit as sigma virus fist
	#When start level with CharacterManager.switch_armor_in_stage, ultimate x is no longer zashiko ultimate x

func show_switch() -> void :
	if CharacterManager.switch_armor_in_stage:
		switch_armor.show()
	show_parts("collectible")
	block_switch()

func hit_as_sigma_virus_fist(boss_name: String) -> void:
	if boss_name is String:
		if boss_name == "sigma_virus_fist":
			on_block_switch_armor()

func block_switch() -> void :
	if CharacterManager.infinite_x_activated:
		block_switch_armor = true
		if icon_infinite:
			icon_infinite.show()
		if icon_gold:
			icon_gold.show()
		if block_texture:
			block_texture.hide()
	else:
		block_switch_armor = false
		if icon_infinite:
			icon_infinite.hide()
		if icon_gold:
			icon_gold.hide()
	if CharacterManager.ultimate_x_armor:
		last_armor_is_ultimate = true

func on_block_switch_armor() -> void :
	block_switch_armor = true
	if block_texture:
		block_texture.show()
	Event.disconnect("collected", self, "show_parts")
	Event.disconnect("is_zashiko_ultimate_x", self, "start_as_zashiko_ultimate_x")
	Event.disconnect("end_teleport_to_red", self, "start_as_zashiko_ultimate_x")
	Event.disconnect("collected", self, "hit_as_sigma_virus_fist")

func show_parts(_d = null) -> void :
	if name == "icarus_armor":
		if "icarus_head" in GameManager.collectibles and "icarus_body" in GameManager.collectibles and "icarus_arms" in GameManager.collectibles and  "icarus_legs" in GameManager.collectibles:
			if icarus_holder:
				icarus_holder.show()
	if name == "hermes_armor":
		if "hermes_head" in GameManager.collectibles and "hermes_body" in GameManager.collectibles and "hermes_arms" in GameManager.collectibles and  "hermes_legs" in GameManager.collectibles:
			if hermes_holder:
				hermes_holder.show()
	if name == "ultimate_armor":
		if "ultima_head" in GameManager.collectibles and "ultima_body" in GameManager.collectibles and "ultima_arms" in GameManager.collectibles and  "ultima_legs" in GameManager.collectibles:
			if ultimate_holder:
				ultimate_holder.show()
	if name == "no_armor":
		if \
		"icarus_head" in GameManager.collectibles or \
		"icarus_body" in GameManager.collectibles or \
		"icarus_arms" in GameManager.collectibles or \
		"icarus_legs" in GameManager.collectibles or \
		"hermes_head" in GameManager.collectibles or \
		"hermes_body" in GameManager.collectibles or \
		"hermes_arms" in GameManager.collectibles or \
		"hermes_legs" in GameManager.collectibles or \
		"ultima_head" in GameManager.collectibles or \
		"ultima_body" in GameManager.collectibles or \
		"ultima_arms" in GameManager.collectibles or \
		"ultima_legs" in GameManager.collectibles:
			if no_armor_holder:
				no_armor_holder.show()
	full_armor()

func get_current_set() -> String:
	if is_instance_valid(GameManager.player):
		return GameManager.player.is_full_armor()
	return "none"

func setup() -> void :
	pass

func _on_focus_entered() -> void :
	._on_focus_entered()

func _on_focus_exited() -> void :
	if is_instance_valid(GameManager.player):
		if name in GameManager.player.current_armor and GameManager.player.name == "X":
			return
	dim()

func on_press() -> void :
	if block_switch_armor or not CharacterManager.switch_armor_in_stage:
		return
	CharacterManager.ultimate_x_armor = false
	
	if last_armor_is_ultimate:
		last_armor_is_ultimate = false
		toggle_no_armor()
	
	call("toggle_" + name)
	strong_flash()
	full_armor()
	Event.emit_signal("collected_zero_weapon")
	Tools.timer(0.075, "play", equip)
	if animated_sprite:
		animated_sprite.frame = 0
	
	if CharacterManager.ultimate_x_armor:
		last_armor_is_ultimate = true
	else:
		last_armor_is_ultimate = false

func full_armor() -> void :
	if icarus_holder:
		icarus_holder.get_node("icarus_armor").get_node("icon").material.set_shader_param("grayscale", true)
	if hermes_holder:
		hermes_holder.get_node("hermes_armor").get_node("icon").material.set_shader_param("grayscale", true)
	if ultimate_holder:
		ultimate_holder.get_node("ultimate_armor").get_node("icon").material.set_shader_param("grayscale", true)
	if no_armor_holder:
		no_armor_holder.get_node("no_armor").get_node("icon").material.set_shader_param("grayscale", true)
	if name == "icarus_armor" and icarus_holder:
		if get_current_set() == "icarus":
			icarus_holder.get_node("icarus_armor").get_node("icon").material.set_shader_param("grayscale", false)
		else:
			icarus_holder.get_node("icarus_armor").get_node("icon").material.set_shader_param("grayscale", true)
	if name == "hermes_armor" and hermes_holder:
		if get_current_set() == "hermes":
			hermes_holder.get_node("hermes_armor").get_node("icon").material.set_shader_param("grayscale", false)
		else:
			hermes_holder.get_node("hermes_armor").get_node("icon").material.set_shader_param("grayscale", true)
	if name == "ultimate_armor" and ultimate_holder:
		if get_current_set() == "ultimate":
			ultimate_holder.get_node("ultimate_armor").get_node("icon").material.set_shader_param("grayscale", false)
		else:
			ultimate_holder.get_node("ultimate_armor").get_node("icon").material.set_shader_param("grayscale", true)
	if name == "no_armor" and no_armor_holder:
		if get_current_set() == "no_armor":
			no_armor_holder.get_node("no_armor").get_node("icon").material.set_shader_param("grayscale", false)
		else:
			no_armor_holder.get_node("no_armor").get_node("icon").material.set_shader_param("grayscale", true)

func process_inputs() -> void :
	pass

func display_info() -> void :
	pass

func toggle_no_armor() -> void:
	if is_instance_valid(GameManager.player):
		if GameManager.player.name == "X":
			GameManager.player.current_armor.clear()
			GameManager.add_equip_exception("head")
			GameManager.add_equip_exception("body")
			GameManager.add_equip_exception("arms")
			GameManager.add_equip_exception("legs")
			GameManager.player.current_armor.append("no_head")
			GameManager.player.current_armor.append("no_body")
			GameManager.player.current_armor.append("no_arms")
			GameManager.player.current_armor.append("no_legs")
			GameManager.player.equip_no_armor_parts()
			Event.emit_signal("collected", "desperation_nova_strike")

func toggle_icarus_armor() -> void:
	Event.emit_signal("collected", "icarus_head")
	Event.emit_signal("collected", "icarus_body")
	Event.emit_signal("collected", "icarus_arms")
	Event.emit_signal("collected", "icarus_legs")

func toggle_hermes_armor() -> void:
	Event.emit_signal("collected", "hermes_head")
	Event.emit_signal("collected", "hermes_body")
	Event.emit_signal("collected", "hermes_arms")
	Event.emit_signal("collected", "hermes_legs")

func toggle_ultimate_armor() -> void:
	CharacterManager.ultimate_x_armor = true
	Event.emit_signal("collected", "ultima_head")
	Event.emit_signal("collected", "ultima_body")
	Event.emit_signal("collected", "ultima_arms")
	Event.emit_signal("collected", "ultima_legs")
	last_armor_is_ultimate = true
	if is_instance_valid(GameManager.player):
		if GameManager.player.current_armor and GameManager.player.name == "X":
			GameManager.player.current_armor.clear()
			GameManager.player.current_armor.append("ultima_head")
			GameManager.player.current_armor.append("ultima_body")
			GameManager.player.current_armor.append("ultima_arms")
			GameManager.player.current_armor.append("ultima_legs")

func toggle_icarus_head() -> void:
	Event.emit_signal("collected", "icarus_head")

func toggle_icarus_body() -> void:
	Event.emit_signal("collected", "icarus_body")

func toggle_icarus_arms() -> void:
	Event.emit_signal("collected", "icarus_arms")

func toggle_icarus_legs() -> void:
	Event.emit_signal("collected", "icarus_legs")

func toggle_hermes_head() -> void:
	Event.emit_signal("collected", "hermes_head")

func toggle_hermes_body() -> void:
	Event.emit_signal("collected", "hermes_body")

func toggle_hermes_arms() -> void:
	Event.emit_signal("collected", "hermes_arms")

func toggle_hermes_legs() -> void:
	Event.emit_signal("collected", "hermes_legs")




