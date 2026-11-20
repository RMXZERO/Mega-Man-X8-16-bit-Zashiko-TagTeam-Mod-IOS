extends Control

var character

const bike = preload("res://src/Actors/Props/RideChaser/RideChaser.tscn")
const ridearmor = preload("res://src/Actors/Props/RideArmor/RideArmor.tscn")
const ridearmor2 = preload("res://src/Actors/Props/RideArmor/RideArmorNoCannon.tscn")
var last_checkpoint : Node2D
onready var checkpoints := get_parent().get_parent().get_parent().get_parent().get_node_or_null("Checkpoints")
var open := false
onready var main_button: Button = $vBoxContainer/hide_menu

onready var cheat_buttons: HBoxContainer = $vBoxContainer/hBoxContainer

signal cheat_pressed(visibility)

var invulnerability: bool = false

func _set_character_node() -> void :
	var char_node = CharacterManager.player_character
	character = get_tree().current_scene.get_node(char_node)

func _ready() -> void:
	call_deferred("_set_character_node")
	hide_totally()
	show_cheats()
	set_text_at_start()
	close_cheats()
	Event.connect("pause_menu_opened",self,"close_cheats")
	Event.connect("pause_menu_opened",self,"hide_totally")
	Event.connect("pause_menu_closed",self,"show_cheats")
	Event.connect("boss_start",self,"on_boss_start")
	if checkpoints:
		if checkpoints.get_child_count() > 0:
			last_checkpoint = checkpoints.get_child(checkpoints.get_child_count()-1)

func set_text_at_start() -> void:
	invulnerability = false
	boss_half_health_text()
	switch_armor_text()
	z_buster_ammo_text()
	z_buster_base_damage_text()
	invulnerability_text()

func _physics_process(_delta: float) -> void:
	if visible:
		if Input.is_action_pressed("debug") and Input.is_action_pressed("debug2"):
			_on_reset_checkpoint_pressed()

func show_cheats():
	if GameManager.debug_enabled or OS.has_feature("editor"):
		if Configurations.get("ShowDebug"):
			visible = true

func hide_totally():
	visible = false

func stage_has_checkpoints() -> bool:
	return checkpoints.get_child_count() > 0

#func _input(event: InputEvent) -> void:
#	if open:
#		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
#			_on_hide_menu_pressed()
#			close_cheats()

func _on_hide_menu_pressed() -> void:
	open = !open
	GameManager.used_cheats = true
	for option in $vBoxContainer.get_children():
		if option.name != "hide_menu":
			option.set_visible (not option.is_visible())
	_on_pause_pressed()
	emit_signal("cheat_pressed",cheat_buttons.visible)

func close_cheats():
	open = false
	for option in $vBoxContainer.get_children():
		if option.name != "hide_menu":
			option.set_visible (false)
		else:
			option.pressed = false
	GameManager.unpause("DebugMenu")
	

func show_debug(show = true) -> void:
	$vBoxContainer.visible = show

func _on_icarus_head_pressed() -> void:
	Event.emit_signal("collected", "icarus_head")

func _on_icarus_body_pressed() -> void:
	Event.emit_signal("collected", "icarus_body")
	
func _on_icarus_arms_pressed() -> void:
	Event.emit_signal("collected", "icarus_arms")

func _on_icarus_legs_pressed() -> void:
	Event.emit_signal("collected", "icarus_legs")

func _on_hermes_head_pressed() -> void:
	Event.emit_signal("collected", "hermes_head")

func _on_hermes_body_pressed() -> void:
	Event.emit_signal("collected", "hermes_body")

func _on_hermes_arms_pressed() -> void:
	Event.emit_signal("collected", "hermes_arms")

func _on_hermes_legs_pressed() -> void:
	Event.emit_signal("collected", "hermes_legs")

func _on_icarus_all_pressed() -> void:
	CharacterManager.ultimate_x_armor = false
	Event.emit_signal("collected", "icarus_head")
	Event.emit_signal("collected", "icarus_body")
	Event.emit_signal("collected", "icarus_arms")
	Event.emit_signal("collected", "icarus_legs")
	Event.emit_signal("collected_zero_weapon")

func _on_hermes_all_pressed() -> void:
	CharacterManager.ultimate_x_armor = false
	Event.emit_signal("collected", "hermes_head")
	Event.emit_signal("collected", "hermes_body")
	Event.emit_signal("collected", "hermes_arms")
	Event.emit_signal("collected", "hermes_legs")
	Event.emit_signal("collected_zero_weapon")

func _on_ultima_pressed() -> void:
	CharacterManager.ultimate_x_armor = true
	Event.emit_signal("collected", "ultima_head")
	Event.emit_signal("collected", "ultima_body")
	Event.emit_signal("collected", "ultima_arms")
	Event.emit_signal("collected", "ultima_legs")
	Event.emit_signal("collected_zero_weapon")
	
func _switch_armor_in_game_pressed() -> void:
	if not CharacterManager.infinite_x_activated:
		GameManager.remove_equip_exception("icarus_head")
		GameManager.remove_equip_exception("icarus_body")
		GameManager.remove_equip_exception("icarus_arms")
		GameManager.remove_equip_exception("icarus_legs")
		GameManager.remove_equip_exception("hermes_head")
		GameManager.remove_equip_exception("hermes_body")
		GameManager.remove_equip_exception("hermes_arms")
		GameManager.remove_equip_exception("hermes_legs")
		GameManager.remove_equip_exception("ultima_head")
		GameManager.remove_equip_exception("ultima_body")
		GameManager.remove_equip_exception("ultima_arms")
		GameManager.remove_equip_exception("ultima_legs")
		GameManager.add_equip_exception("head")
		GameManager.add_equip_exception("body")
		GameManager.add_equip_exception("arms")
		GameManager.add_equip_exception("legs")
		CharacterManager.ultimate_x_armor = false
		CharacterManager.switch_armor_in_stage = not CharacterManager.switch_armor_in_stage
		switch_armor_text()
		GameManager.restart_level()

func switch_armor_text() -> void:
	if CharacterManager.switch_armor_in_stage:
		$vBoxContainer/hBoxContainer/vBoxContainer2/switch_armor.text = String("switch_armor(on)")
	else:
		$vBoxContainer/hBoxContainer/vBoxContainer2/switch_armor.text = String("switch_armor(off)")

func _z_buster_ammo_entered(new_text: String) -> void:
	if new_text.is_valid_integer():
		if int(new_text) < 0:
			CharacterManager.buster_base_energy = -int(new_text)
		else:
			CharacterManager.buster_base_energy = int(new_text)
		GameManager.restart_level()
		CharacterManager._save()

func z_buster_ammo_text() -> void:
	$vBoxContainer/hBoxContainer/vBoxContainer/z_buster_cooldown.placeholder_text = "zbuster_amo" + "(" +String(CharacterManager.buster_base_energy) + ")"

func _z_buster_base_damage_entered(new_text: String) -> void:
	if new_text.is_valid_integer():
		if int(new_text) < 0:
			CharacterManager.z_buster_base_damage = -int(new_text)
		else:
			CharacterManager.z_buster_base_damage = int(new_text)
		GameManager.restart_level()
		CharacterManager._save()

func z_buster_base_damage_text() -> void:
	$vBoxContainer/hBoxContainer/vBoxContainer/z_buster_damage.placeholder_text = "z_buster_dmg" + "(" +String(CharacterManager.z_buster_base_damage) + ")"

func _on_zero_weapon_pressed() -> void:
	Event.emit_signal("collected", "b_fan_zero")
	Event.emit_signal("collected", "d_glaive_zero")
	Event.emit_signal("collected", "k_knuckle_zero")
	Event.emit_signal("collected", "t_breaker_zero")
	Event.emit_signal("collected", "z_breaker_zero")
	Event.emit_signal("collected", "rogue_blade_zero")
	Event.emit_signal("collected", "v_hanger_zero")
	Event.emit_signal("collected", "sigma_blade_zero")
	Event.emit_signal("collected_zero_weapon")

func _on_special_item_pressed() -> void:
	Event.emit_signal("collected", "track_bullet")
	Event.emit_signal("collected", "share_axl_buff")
	Event.emit_signal("collected", "player_desperation")
	Event.emit_signal("collected", "axl_saber_combo")
	Event.emit_signal("collected", "axl_first_time")
	Event.emit_signal("collected", "axl_second_time")
	Event.emit_signal("collected", "axl_seen_x_boss")
	Event.emit_signal("collected", "zero_seen_x_boss")

func _on_black_zero_pressed() -> void:
	Event.emit_signal("collected", "black_zero_armor")
	if CharacterManager.player_character == "Zero":
		if is_instance_valid(GameManager.player):
			var zero = GameManager.player
			CharacterManager.black_zero_armor = true
			zero.equip_black_zero_parts()
			CharacterManager.set_zeroX8_colors(zero.animatedSprite)
			zero.animatedSprite.get_node("afterImages").set_shader_colors()
			CharacterManager.set_saberX8_colors(zero.animatedSprite)

func _on_awakened_zero_pressed() -> void:
	Event.emit_signal("collected", "awakened_zero_armor")
	if CharacterManager.player_character == "Zero":
		if is_instance_valid(GameManager.player):
			var zero = GameManager.player
			CharacterManager.awakened_zero_armor = true
			zero.equip_awakened_zero_parts()
			if CharacterManager.awakened_zero_full_power_max:
				zero.equip_awakened_zero_up_parts()
			CharacterManager.set_zeroX8_colors(zero.animatedSprite)
			zero.animatedSprite.get_node("afterImages").set_shader_colors()
			CharacterManager.set_saberX8_colors(zero.animatedSprite)
			Event.emit_signal("beamin")

func _on_extra_zero_pressed() -> void:
	Event.emit_signal("collected", "extra_saber_combo")
	CharacterManager.extra_saber_combo = true
	Event.emit_signal("refresh_hud")

func _on_white_axl_pressed() -> void:
	Event.emit_signal("collected", "white_axl_armor")
	if CharacterManager.player_character == "Axl":
		if is_instance_valid(GameManager.player):
			var axl = GameManager.player
			CharacterManager.white_axl_armor = true
			axl.equip_axl_white_parts()
			CharacterManager.set_axl_colors(axl.animatedSprite)
			axl.animatedSprite.get_node("afterImagesn").set_shader_colors()

func _on_floppa_axl_pressed() -> void:
	Event.emit_signal("collected", "floppa_axl_activated")
	if CharacterManager.player_character == "Axl":
		CharacterManager.floppa_axl_activated = true
		GameManager.restart_level()

func _boss_half_health_pressed() -> void:
	CharacterManager.boss_half_health = not CharacterManager.boss_half_health
	CharacterManager.update_game_mode()
	boss_half_health_text()
	GameManager.restart_level()

func boss_half_health_text() -> void:
	if CharacterManager.boss_half_health:
		$vBoxContainer/hBoxContainer/vBoxContainer/boss_half_health.text = String("boss_half_hp(on)")
	else:
		$vBoxContainer/hBoxContainer/vBoxContainer/boss_half_health.text = String("boss_half_hp(off)")

func _on_damage_pressed() -> void:
	GameManager.player.invulnerability = 0.0
	GameManager.player.damage(2)

func _on_heal_pressed() -> void:
	if is_instance_valid(GameManager.player):
		GameManager.player.current_health = GameManager.player.max_health
	if is_instance_valid(GameManager.inactive_player):
		if CharacterManager.team.size() > 1:
			if not CharacterManager.both_alive:
				GameManager.inactive_player.get_node("CharSwitchRevive").character_alive()
			GameManager.inactive_player.current_health = GameManager.inactive_player.max_health

func _on_inifinte_health_pressed() -> void:
	if is_instance_valid(GameManager.player):
		GameManager.player.current_health = 16000
	if is_instance_valid(GameManager.inactive_player):
		if CharacterManager.team.size() > 1:
			if not CharacterManager.both_alive:
				GameManager.inactive_player.get_node("CharSwitchRevive").character_alive()
			GameManager.inactive_player.current_health = 16000

func _on_invulnerability_pressed() -> void:
	invulnerability = not invulnerability
	if invulnerability:
		if is_instance_valid(GameManager.player):
			GameManager.player.add_invulnerability("debug")
		if is_instance_valid(GameManager.inactive_player):
			if CharacterManager.team.size() > 1:
				if CharacterManager.both_alive:
					GameManager.inactive_player.add_invulnerability("debug")
	else:
		if is_instance_valid(GameManager.player):
			GameManager.player.remove_invulnerability("debug")
		if is_instance_valid(GameManager.inactive_player):
			if CharacterManager.team.size() > 1:
				if CharacterManager.both_alive:
					GameManager.inactive_player.remove_invulnerability("debug")
	invulnerability_text()

func invulnerability_text() -> void:
	if invulnerability:
		$vBoxContainer/hBoxContainer/vBoxContainer/invulnerability.text = String("invulnerable(on)")
	else:
		$vBoxContainer/hBoxContainer/vBoxContainer/invulnerability.text = String("invulnerable(off)")

func _on_disable_camera_limits_pressed() -> void:
	GameManager.camera.set_limits(-100000,100000,-100000,100000)

func _on_reset_stage_pressed() -> void:
	GameManager.checkpoint = null
	GlobalVariables.set("pitch_black_energized",false)
	GameManager.restart_level()

func _on_remove_collects_pressed() -> void:
	GameManager.collectibles = []
	CharacterManager.black_zero_armor = false
	CharacterManager.white_axl_armor = false
	CharacterManager.ultimate_x_armor = false
	CharacterManager.extra_saber_combo = false
	CharacterManager.axl_saber_combo = false
	CharacterManager.share_axl_buff = false
	CharacterManager.track_bullet = false
	CharacterManager.awakened_zero_armor = false
	CharacterManager.infinite_x_activated = false
	CharacterManager.cheat_axl_activated = false
	GlobalVariables.erase("vile3_defeated")
	GlobalVariables.erase("gateway_bosses_beaten")
	GlobalVariables.erase("copy_sigma_defeated")
	GlobalVariables.erase("vile_palace_defeated")
	GlobalVariables.erase("defeated_antonion_vile")
	GlobalVariables.erase("defeated_panda_vile")
	GlobalVariables.erase("red_defeated")
	GlobalVariables.erase("serenade_defeated")
	GlobalVariables.erase("vile_ex_defeated")
	GlobalVariables.erase("seraph_lumine_defeated")
	for character in CharacterManager.equipped_hearts.keys():
		CharacterManager.equipped_hearts[character] = 0
	CharacterManager.check_for_deactivated_skills_Zero()
	
	GameManager.restart_level()
	pass # Replace with function body.

func _on_kill_pressed() -> void:
	character.current_health = 0
	CharacterManager.both_alive = false
	CharacterManager.alive_team = []
	emit_signal("zero_health")
	if is_instance_valid(GameManager.player):
		GameManager.player.emit_signal("zero_health")
		GameManager.player.zero_health_team()
	if is_instance_valid(GameManager.inactive_player):
		GameManager.inactive_player.emit_signal("zero_health")
		GameManager.inactive_player.zero_health_team()

func _on_30fps_pressed() -> void:
	set_fps(30)


func _on_60fps_pressed() -> void:
	set_fps(60)


func _on_120fps_pressed() -> void:
	set_fps(120)


func _on_144fps_pressed() -> void:
	set_fps(144)

func set_fps(value :int) -> void:
	#if Engine.get_iterations_per_second() != value:
	print_debug("Engine fps: " + str(Engine.get_iterations_per_second()) + " changing to: " + str(value))
	Engine.iterations_per_second = value
	Engine.target_fps = value
	$"vBoxContainer/hBoxContainer/vBoxContainer/144fps/fps".text= "fps: " + str(Engine.get_iterations_per_second()) + "target: " + str(Engine.target_fps)

func _on_pause_pressed() -> void:
	if cheat_buttons.visible:
		GameManager.pause("DebugMenu")
	else:
		GameManager.unpause("DebugMenu")

func _on_start_boss_pressed() -> void:
	GameManager.start_boss()


func _on_time_attack_pressed() -> void:
	$"../Rec Info".set_visible (not $"../Rec Info".is_visible())
	GameManager.time_attack = not GameManager.time_attack
	GameManager.restart_level()
	pass # Replace with function body.


func _on_1xSize_pressed() -> void:
	OS.set_window_size(Vector2(398, 224))


func _on_2xSize_pressed() -> void:
	OS.set_window_size(Vector2(796, 448))

func _on_3xSize_pressed() -> void:
	OS.set_window_size(Vector2(1194, 672))
	
func _on_fullscreen_pressed() -> void:
	OS.window_fullscreen = !OS.window_fullscreen

func _on_next_checkpoint_pressed() -> void:
	if not stage_has_checkpoints():
		return
	var current_c : int = 0
	if GameManager.checkpoint:
		current_c = GameManager.checkpoint.id
	var next_checkpoint = checkpoints.get_node(str(clamp(current_c + 1,0,int(last_checkpoint.name))))
	GameManager.set_checkpoint(next_checkpoint.settings)
	GameManager.restart_level()

func _on_reset_checkpoint_pressed() -> void:
	GameManager.restart_level()

func _on_previous_checkpoint_pressed() -> void:
	if not stage_has_checkpoints():
		return
	var current_c : int = 0
	if GameManager.checkpoint:
		current_c = GameManager.checkpoint.id
	if current_c <= 1:
		_on_reset_stage_pressed()
	else:
		var previous_checkpoint = checkpoints.get_node(str(clamp(current_c - 1,1,int(last_checkpoint.name))))
		GameManager.set_checkpoint(previous_checkpoint.settings)
		GameManager.restart_level()
	
func _on_teleport_to_boss_pressed() -> void:
	if not stage_has_checkpoints():
		return
	if last_checkpoint:
		GameManager.fill_subtanks()
		GameManager.reached_checkpoint(last_checkpoint.settings)
		GameManager.restart_level()


func _on_spawn_bike_pressed() -> void:
	var instance = bike.instance()
	get_tree().current_scene.add_child(instance,true)
	instance.set_position(GameManager.get_player_position()) 


func _on_mute_music_pressed() -> void:
	AudioServer.set_bus_mute(2,!AudioServer.is_bus_mute(2))


func _on_intro_stage_pressed() -> void:
	GameManager.start_level("NoahsPark")

func _on_show_colliders_pressed() -> void:
	get_tree().set_debug_collisions_hint(!get_tree().is_debugging_collisions_hint())

func _on_subtank1_pressed() -> void:
	for subtank in GameManager.player.get_node("Subtanks").get_children():
		if not subtank.active:
			GameManager.player.equip_subtank(subtank.subtank.id)
			GameManager.add_collectible_to_savedata(subtank.subtank.id)
			GlobalVariables.set(subtank.subtank.id,0)
			break


func _on_use_subtank_pressed() -> void:
	Event.emit_signal("use_any_subtank")
	pass # Replace with function body.


func _on_unlock_weapons_pressed() -> void:
	GameManager.add_collectible_to_savedata("yeti_weapon")
	GameManager.add_collectible_to_savedata("rooster_weapon")
	GameManager.add_collectible_to_savedata("mantis_weapon")
	GameManager.add_collectible_to_savedata("sunflower_weapon")
	GameManager.add_collectible_to_savedata("trilobyte_weapon")
	GameManager.add_collectible_to_savedata("panda_weapon")
	GameManager.add_collectible_to_savedata("manowar_weapon")
	GameManager.add_collectible_to_savedata("antonion_weapon")
	GameManager.restart_level()
	pass # Replace with function body.


func _on_spawn_ridearm_pressed() -> void:
	var instance = ridearmor.instance()
	get_tree().current_scene.add_child(instance,true)
	var armor_pos = GameManager.get_player_position()
	armor_pos.y -= 16
	instance.set_position(armor_pos)


func _on_stage_select_pressed() -> void:
	GameManager.go_to_stage_select()


func _on_fill_subtank_pressed() -> void:
	GameManager.fill_subtanks()

const all_hearts = ["life_up_panda","life_up_yeti","life_up_manowar","life_up_rooster","life_up_trilobyte","life_up_mantis","life_up_antonion","life_up_sunflower","life_up_ex1","life_up_ex2","life_up_ex3","life_up_ex4"]
#const debug_hearts = ["life_up_ex5","life_up_ex6","life_up_ex7","life_up_ex8","life_up_ex9","life_up_ex10","life_up_ex11","life_up_ex12","life_up_ex13","life_up_ex14","life_up_ex15","life_up_ex16"]

func _on_add_heart_pressed() -> void:
	for heart in all_hearts:
		add_heart(heart)

func add_heart(collectible_name) -> void:
	if not GameManager.is_collectible_in_savedata(collectible_name):
		GameManager.add_collectible_to_savedata(collectible_name)
		if is_instance_valid(GameManager.player):
			GameManager.player.num_equipped_hearts += 1
			GameManager.player.max_health += CharacterManager.heart_tank_buff_amt
			GameManager.player.recover_health(CharacterManager.heart_tank_buff_amt)
		if is_instance_valid(GameManager.inactive_player):
			GameManager.inactive_player.num_equipped_hearts += 1
			GameManager.inactive_player.max_health += CharacterManager.heart_tank_buff_amt
			GameManager.inactive_player.recover_health(CharacterManager.heart_tank_buff_amt)
		for character in CharacterManager.equipped_hearts.keys():
			CharacterManager.equipped_hearts[character] += 1

func _on_remove_all_hearts() -> void:
	for heart in all_hearts:
		remove_heart(heart)

func remove_heart(collectible_name) -> void:
	if GameManager.is_collectible_in_savedata(collectible_name):
		GameManager.remove_collectible_from_savedata(collectible_name)
		if is_instance_valid(GameManager.player):
			GameManager.player.num_equipped_hearts += -1
			GameManager.player.max_health -= CharacterManager.heart_tank_buff_amt
			if GameManager.player.max_health > CharacterManager.starting_max_health:
				GameManager.player.max_health -= CharacterManager.heart_tank_buff_amt
			if GameManager.player.current_health > CharacterManager.heart_tank_buff_amt:
				GameManager.player.reduce_health(CharacterManager.heart_tank_buff_amt)
		if is_instance_valid(GameManager.inactive_player):
			GameManager.inactive_player.num_equipped_hearts += -1
			if GameManager.inactive_player.max_health > CharacterManager.starting_max_health:
				GameManager.inactive_player.max_health -= CharacterManager.heart_tank_buff_amt
			if GameManager.inactive_player.current_health > CharacterManager.heart_tank_buff_amt:
				GameManager.inactive_player.reduce_health(CharacterManager.heart_tank_buff_amt)
		for character in CharacterManager.equipped_hearts.keys():
			CharacterManager.equipped_hearts[character] += -1

var bosses : Array
func on_boss_start(boss):
	bosses.append(boss)

func _on_defeat_boss_pressed() -> void:
	for boss in bosses:
		if is_instance_valid(boss):
			boss.current_health = 0
			_on_hide_menu_pressed()
			main_button.pressed = false

func _on_dj_sigma_pressed() -> void:
	GameManager.go_to_dj_sigma()
	pass # Replace with function body.

func _on_seraph_lumine_pressed() -> void:
	GameManager.go_to_lumine_boss_test()
	pass # Replace with function body.


func _on_rooster_crystal_pressed() -> void:
	Event.emit_signal("gateway_crystal_get","rooster")
func _on_manow_crystal_pressed() -> void:
	Event.emit_signal("gateway_crystal_get","manowar")
func _on_trilo_crystal_pressed() -> void:
	Event.emit_signal("gateway_crystal_get","trilobyte")
func _on_sunf_crystal_pressed() -> void:
	Event.emit_signal("gateway_crystal_get","sunflower")
func _on_yeti_crystal_pressed() -> void:
	Event.emit_signal("gateway_crystal_get","yeti")
func _on_panda_crystal_pressed() -> void:
	Event.emit_signal("gateway_crystal_get","panda")
func _on_mantis_crystal_pressed() -> void:
	Event.emit_signal("gateway_crystal_get","mantis")

func _on_anton_crystal_pressed() -> void:
	Event.emit_signal("gateway_crystal_get","antonion")
	pass # Replace with function body.


func _on_gateway_reset_pressed() -> void:
	GatewayManager.reset_bosses()
	_on_reset_stage_pressed()
	pass # Replace with function body.


func _on_gateway_final_pressed() -> void:
	Event.emit_signal("gateway_final_section")


func _on_sss_rank_pressed() -> void:
	GlobalVariables.set("RankSSS",true)
	pass # Replace with function body.


func _on_set_seed_text_entered(new_text: String) -> void:
	if new_text.is_valid_integer():
		BossRNG.set_seed(int(new_text))
		GameManager.restart_level()
	else:
		pass
	pass # Replace with function body.




func _on_gateway_pressed() -> void:
	GameManager.start_level("Gateway")
	pass # Replace with function body.


func _on_igtscreen_pressed() -> void:
	GameManager.go_to_igt()
	pass # Replace with function body.


func _on_spawn_gridearm_pressed() -> void:
	var instance = ridearmor2.instance()
	get_tree().current_scene.add_child(instance,true)
	var armor_pos = GameManager.get_player_position()
	armor_pos.y -= 16
	instance.current_health = instance.current_health/2
	instance.set_position(armor_pos)
	pass # Replace with function body.

func _reset_position() -> void:
	CharacterManager.jump_position_x = 3840
	CharacterManager.jump_position_y = 1760
	CharacterManager.dash_position_x = 3840
	CharacterManager.dash_position_y = 1360
	CharacterManager.fire_position_x = 3440
	CharacterManager.fire_position_y = 1760
	CharacterManager.alt_fire_position_x = 3440
	CharacterManager.alt_fire_position_y = 1360
	CharacterManager.special_position_x = 3440
	CharacterManager.special_position_y = 560
	CharacterManager.switch_position_x = 3840
	CharacterManager.switch_position_y = 560
	CharacterManager.dash_jump_position_x = 3440
	CharacterManager.dash_jump_position_y = 960
	CharacterManager.dash_fire_position_x = 3840
	CharacterManager.dash_fire_position_y = 960
	CharacterManager.weapon_left_position_x = 320
	CharacterManager.weapon_left_position_y = 0
	CharacterManager.weapon_right_position_x = 3740
	CharacterManager.weapon_right_position_y = 0
	CharacterManager.joystick_position_x = 910
	CharacterManager.joystick_position_y = 1660
	CharacterManager.weaponround_position_x = 3310
	CharacterManager.weaponround_position_y = 300
	CharacterManager.pause_position_x = 2150
	CharacterManager.pause_position_y = 0
	Event.emit_signal("touchcontrol")
	GameManager.restart_level()
