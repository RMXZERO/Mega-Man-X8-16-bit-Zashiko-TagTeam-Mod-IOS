extends Area2D

onready var main = $"."
onready var outline = $outline
onready var max_distance = $Deadzone.shape.radius
export  var deadzone = 1

export  var _action: String

onready var pick: AudioStreamPlayer = $"../../../../pick"
onready var equip: AudioStreamPlayer = $"../../../../equip"
onready var unequip: AudioStreamPlayer = $"../../../../unequip"
onready var choice: AudioStreamPlayer = $"../../../../choice"

func _ready() -> void :
	if _action == "auto_charge":
		if CharacterManager.auto_charge:
			$outline.material.set_shader_param("grayscale", not CharacterManager.auto_charge)
	if _action == "rapid_fire":
		if CharacterManager.rapid_fire:
			$outline.material.set_shader_param("grayscale", not CharacterManager.rapid_fire)
	if _action == "hide_x_armor":
		if CharacterManager.hide_x_armor:
			$outline.material.set_shader_param("grayscale", not CharacterManager.hide_x_armor)
	if _action == "use_old_sprite":
		if CharacterManager.use_old_sprite:
			$outline.material.set_shader_param("grayscale", not CharacterManager.use_old_sprite)
	if _action == "ultimate_buster":
		if CharacterManager.ultimate_buster:
			$outline.material.set_shader_param("grayscale", not CharacterManager.ultimate_buster)
	if _action == "infinite_glow":
		if CharacterManager.infinite_x_glow:
			$outline.material.set_shader_param("grayscale", not CharacterManager.infinite_x_glow)
	if _action == "custom_zero":
		if CharacterManager.custom_zero_armor:
			$outline.material.set_shader_param("grayscale", not CharacterManager.custom_zero_armor)
	if _action == "beta_zero":
		if CharacterManager.betazero_activated:
			$outline.material.set_shader_param("grayscale", not CharacterManager.betazero_activated)
	if _action == "extra_combo":
		if CharacterManager.extra_saber_combo:
			$outline.material.set_shader_param("grayscale", not CharacterManager.extra_saber_combo)
	if _action == "power_max":
		if CharacterManager.awakened_zero_full_power_max:
			$outline.material.set_shader_param("grayscale", not CharacterManager.awakened_zero_full_power_max)
	if _action == "extra_color":
		if CharacterManager.extra_saber_color:
			$outline.material.set_shader_param("grayscale", not CharacterManager.extra_saber_color)
	if _action == "custom_axl":
		if CharacterManager.custom_axl_armor:
			$outline.material.set_shader_param("grayscale", not CharacterManager.custom_axl_armor)
	if _action == "track_bullet":
		if CharacterManager.track_bullet:
			$outline.material.set_shader_param("grayscale", not CharacterManager.track_bullet)
	if _action == "share_buff":
		if CharacterManager.share_axl_buff:
			$outline.material.set_shader_param("grayscale", not CharacterManager.share_axl_buff)
	if _action == "axl_saber_combo":
		if CharacterManager.axl_saber_combo:
			$outline.material.set_shader_param("grayscale", not CharacterManager.axl_saber_combo)
	if _action == "floppa_axl":
		if CharacterManager.floppa_axl_activated:
			$outline.material.set_shader_param("grayscale", not CharacterManager.floppa_axl_activated)
	if _action == "auto_hover":
		if CharacterManager.floppa_axl_auto_hover:
			$outline.material.set_shader_param("grayscale", not CharacterManager.floppa_axl_auto_hover)
	if _action == "auto_cling_wall":
		if CharacterManager.floppa_axl_auto_cling_wall:
			$outline.material.set_shader_param("grayscale", not CharacterManager.floppa_axl_auto_cling_wall)
	if _action == "auto_lock":
		if CharacterManager.floppa_axl_auto_lock:
			$outline.material.set_shader_param("grayscale", not CharacterManager.floppa_axl_auto_lock)
	if _action == "player_desperation":
		if CharacterManager.player_desperation:
			$outline.material.set_shader_param("grayscale", not CharacterManager.player_desperation)
	if _action == "weapon_get_zero":
		if CharacterManager.weaponget_zero:
			$outline.material.set_shader_param("grayscale", not CharacterManager.weaponget_zero)
	
	if _action == "beta_zero":
		if not CharacterManager.betazero_unlocked:
			$"../../Zero/beta_zero".position.y -= 500
			$"../../Zero/extra_saber_combo".position.y -= 14
			$"../../Zero/awakened_zero_limited".position.y -= 14
			$"../../Zero/extra_saber_color".position.y -= 14
			$"../../Zero/weapon_get_zero".position.y -= 14
	if _action == "extra_combo":
		if not "extra_saber_combo" in GameManager.collectibles:
			$"../../Zero/extra_saber_combo".position.y -= 500
			$"../../Zero/awakened_zero_limited".position.y -= 14
			$"../../Zero/extra_saber_color".position.y -= 14
			$"../../Zero/weapon_get_zero".position.y -= 14
	if _action == "power_max":
		if not CharacterManager.awakened_zero_unlocked:
			$"../../Zero/awakened_zero_limited".position.y -= 500
			$"../../Zero/extra_saber_color".position.y -= 14
			$"../../Zero/weapon_get_zero".position.y -= 14
	if _action == "weapon_get_zero":
		if Configurations.get("ShowDebug") and CharacterManager.betazero_unlocked or "sigma_virus_fist" in GameManager.collectibles:
			pass
		else:
			$"../../Zero/weapon_get_zero".position.y -= 500
	if _action == "track_bullet":
		if not "track_bullet" in GameManager.collectibles:
			$"../../Axl/track_bullet".position.y -= 500
			$"../../Axl/share_buff".position.y -= 14
			$"../../Axl/axl_saber_combo".position.y -= 14
			$"../../Axl/floppa_axl".position.y -= 14
			$"../../Axl/auto_hover".position.y -= 14
			$"../../Axl/auto_cling_wall".position.y -= 14
			$"../../Axl/auto_lock".position.y -= 14
	if _action == "share_buff":
		if not "share_axl_buff" in GameManager.collectibles:
			$"../../Axl/share_buff".position.y -= 500
			$"../../Axl/axl_saber_combo".position.y -= 14
			$"../../Axl/floppa_axl".position.y -= 14
			$"../../Axl/auto_hover".position.y -= 14
			$"../../Axl/auto_cling_wall".position.y -= 14
			$"../../Axl/auto_lock".position.y -= 14
	if _action == "axl_saber_combo":
		if not "axl_saber_combo" in GameManager.collectibles:
			$"../../Axl/axl_saber_combo".position.y -= 500
			$"../../Axl/floppa_axl".position.y -= 14
			$"../../Axl/auto_hover".position.y -= 14
			$"../../Axl/auto_cling_wall".position.y -= 14
			$"../../Axl/auto_lock".position.y -= 14
	if _action == "floppa_axl":
		if not "floppa_axl_activated" in GameManager.collectibles:
			if not CharacterManager.floppa_axl_unlocked:
				$"../../Axl/floppa_axl".position.y -= 500
				$"../../Axl/auto_hover".position.y -= 500
				$"../../Axl/auto_cling_wall".position.y -= 500
				$"../../Axl/auto_lock".position.y -= 500
		if not CharacterManager.floppa_axl_activated:
			$"../../Axl/auto_lock".position.x = 500
			$"../../Axl/auto_cling_wall".position.x = 500
			$"../../Axl/auto_hover".position.x = 500
		else:
			$"../../Axl/auto_lock".position.x = -7
			$"../../Axl/auto_cling_wall".position.x = -7
			$"../../Axl/auto_hover".position.x = -7
	if _action == "player_desperation":
		if not "player_desperation" in GameManager.collectibles:
			$"../../Other/player_desperation".position.y -= 500
	if _action == "ultimate_buster":
		if not CharacterManager.ultimate_buster and not "sigma_virus_fist" in GameManager.collectibles:
			$"../../X/ultimate_buster".position.y -= 500

func _input(event):
	if event is InputEventScreenTouch:
		var distance = event.position.distance_to(outline.global_position)
		if event.pressed:
			if distance < max_distance:
				if _action == "auto_charge":
					toggle_auto_charge()
					$outline.material.set_shader_param("grayscale", not CharacterManager.auto_charge)
				if _action == "rapid_fire":
					toggle_rapid_fire()
					$outline.material.set_shader_param("grayscale", not CharacterManager.rapid_fire)
				if _action == "hide_x_armor":
					toggle_hide_armor()
					$outline.material.set_shader_param("grayscale", not CharacterManager.hide_x_armor)
				if _action == "use_old_sprite":
					toggle_old_sprite()
					$outline.material.set_shader_param("grayscale", not CharacterManager.use_old_sprite)
				if _action == "ultimate_buster":
					toggle_ultimate_buster()
					$outline.material.set_shader_param("grayscale", not CharacterManager.ultimate_buster)
				if _action == "infinite_glow":
					toggle_infinite_x_glow()
					$outline.material.set_shader_param("grayscale", not CharacterManager.infinite_x_glow)
				if _action == "custom_zero":
					toggle_custom_zero()
					$outline.material.set_shader_param("grayscale", not CharacterManager.custom_zero_armor)
				if _action == "beta_zero":
					toggle_beta_zero()
					$outline.material.set_shader_param("grayscale", not CharacterManager.betazero_activated)
				if _action == "extra_combo":
					toggle_extra_combo()
					$outline.material.set_shader_param("grayscale", not CharacterManager.extra_saber_combo)
				if _action == "power_max":
					toggle_power_max()
					$outline.material.set_shader_param("grayscale", not CharacterManager.awakened_zero_full_power_max)
				if _action == "extra_color":
					toggle_extra_color()
					$outline.material.set_shader_param("grayscale", not CharacterManager.extra_saber_color)
				if _action == "custom_axl":
					toggle_custom_axl()
					$outline.material.set_shader_param("grayscale", not CharacterManager.custom_axl_armor)
				if _action == "track_bullet":
					toggle_track_bullet()
					$outline.material.set_shader_param("grayscale", not CharacterManager.track_bullet)
				if _action == "share_buff":
					toggle_share_buff()
					$outline.material.set_shader_param("grayscale", not CharacterManager.share_axl_buff)
				if _action == "axl_saber_combo":
					toggle_axl_saber_combo()
					$outline.material.set_shader_param("grayscale", not CharacterManager.axl_saber_combo)
				if _action == "floppa_axl":
					toggle_floppa_axl()
					$outline.material.set_shader_param("grayscale", not CharacterManager.floppa_axl_activated)
				if _action == "auto_hover":
					toggle_floppa_axl_hover()
					$outline.material.set_shader_param("grayscale", not CharacterManager.floppa_axl_auto_hover)
				if _action == "auto_cling_wall":
					toggle_floppa_axl_cling_wall()
					$outline.material.set_shader_param("grayscale", not CharacterManager.floppa_axl_auto_cling_wall)
				if _action == "auto_lock":
					toggle_floppa_axl_lock()
					$outline.material.set_shader_param("grayscale", not CharacterManager.floppa_axl_auto_lock)
				if _action == "player_desperation":
					toggle_player_desperation()
					$outline.material.set_shader_param("grayscale", not CharacterManager.player_desperation)
				if _action == "weapon_get_zero":
					toggle_weapon_get_zero()
					$outline.material.set_shader_param("grayscale", not CharacterManager.weaponget_zero)
				$"../../../characters/panel/char_container".switch_armor(0)
		elif not event.pressed:
			pass

func toggle_auto_charge() -> void :
	CharacterManager.auto_charge = not CharacterManager.auto_charge
	if CharacterManager.auto_charge:
		Tools.timer(0.075, "play", pick)
	else:
		Tools.timer(0.075, "play", unequip)

func toggle_rapid_fire() -> void :
	CharacterManager.rapid_fire = not CharacterManager.rapid_fire
	if CharacterManager.rapid_fire:
		Tools.timer(0.075, "play", pick)
	else:
		Tools.timer(0.075, "play", unequip)

func toggle_hide_armor() -> void :
	CharacterManager.hide_x_armor = not CharacterManager.hide_x_armor
	if CharacterManager.hide_x_armor:
		Tools.timer(0.075, "play", pick)
	else:
		Tools.timer(0.075, "play", unequip)

func toggle_old_sprite() -> void :
	CharacterManager.use_old_sprite = not CharacterManager.use_old_sprite
	if CharacterManager.use_old_sprite:
		Tools.timer(0.075, "play", pick)
	else:
		Tools.timer(0.075, "play", unequip)

func toggle_ultimate_buster() -> void :
	CharacterManager.ultimate_buster = not CharacterManager.ultimate_buster
	if CharacterManager.ultimate_buster:
		Tools.timer(0.075, "play", pick)
	else:
		Tools.timer(0.075, "play", unequip)

func toggle_infinite_x_glow() -> void :
	CharacterManager.infinite_x_glow = not CharacterManager.infinite_x_glow
	if CharacterManager.infinite_x_glow:
		Tools.timer(0.075, "play", pick)
	else:
		Tools.timer(0.075, "play", unequip)

func toggle_custom_zero() -> void :
	CharacterManager.custom_zero_armor = not CharacterManager.custom_zero_armor
	if CharacterManager.custom_zero_armor:
		Tools.timer(0.075, "play", pick)
	else:
		Tools.timer(0.075, "play", unequip)

func toggle_beta_zero() -> void :
	CharacterManager.betazero_activated = not CharacterManager.betazero_activated
	if CharacterManager.betazero_activated:
		Tools.timer(0.075, "play", pick)
	else:
		Tools.timer(0.075, "play", unequip)

func toggle_extra_combo() -> void :
	CharacterManager.extra_saber_combo = not CharacterManager.extra_saber_combo
	if CharacterManager.extra_saber_combo:
		Tools.timer(0.075, "play", pick)
	else:
		Tools.timer(0.075, "play", unequip)

func toggle_power_max() -> void :
	CharacterManager.awakened_zero_full_power_max = not CharacterManager.awakened_zero_full_power_max
	if CharacterManager.awakened_zero_full_power_max:
		Tools.timer(0.075, "play", pick)
	else:
		Tools.timer(0.075, "play", unequip)

func toggle_extra_color() -> void :
	CharacterManager.extra_saber_color = not CharacterManager.extra_saber_color
	if CharacterManager.extra_saber_color:
		Tools.timer(0.075, "play", pick)
	else:
		Tools.timer(0.075, "play", unequip)

func toggle_custom_axl() -> void :
	CharacterManager.custom_axl_armor = not CharacterManager.custom_axl_armor
	if CharacterManager.custom_axl_armor:
		Tools.timer(0.075, "play", pick)
	else:
		Tools.timer(0.075, "play", unequip)

func toggle_track_bullet() -> void :
	CharacterManager.track_bullet = not CharacterManager.track_bullet
	if CharacterManager.track_bullet:
		Tools.timer(0.075, "play", pick)
	else:
		Tools.timer(0.075, "play", unequip)

func toggle_share_buff() -> void :
	CharacterManager.share_axl_buff = not CharacterManager.share_axl_buff
	if CharacterManager.share_axl_buff:
		Tools.timer(0.075, "play", pick)
	else:
		Tools.timer(0.075, "play", unequip)

func toggle_axl_saber_combo() -> void :
	CharacterManager.axl_saber_combo = not CharacterManager.axl_saber_combo
	if CharacterManager.axl_saber_combo:
		Tools.timer(0.075, "play", pick)
	else:
		Tools.timer(0.075, "play", unequip)

func toggle_floppa_axl() -> void :
	CharacterManager.floppa_axl_activated = not CharacterManager.floppa_axl_activated
	if CharacterManager.floppa_axl_activated:
		Tools.timer(0.075, "play", pick)
		$"../../Axl/auto_lock".position.x = -7
		$"../../Axl/auto_cling_wall".position.x = -7
		$"../../Axl/auto_hover".position.x = -7
	else:
		Tools.timer(0.075, "play", unequip)
		$"../../Axl/auto_lock".position.x = 500
		$"../../Axl/auto_cling_wall".position.x = 500
		$"../../Axl/auto_hover".position.x = 500

func toggle_floppa_axl_hover() -> void :
	CharacterManager.floppa_axl_auto_hover = not CharacterManager.floppa_axl_auto_hover
	if CharacterManager.floppa_axl_auto_hover:
		Tools.timer(0.075, "play", pick)
	else:
		Tools.timer(0.075, "play", unequip)

func toggle_floppa_axl_cling_wall() -> void :
	CharacterManager.floppa_axl_auto_cling_wall = not CharacterManager.floppa_axl_auto_cling_wall
	if CharacterManager.floppa_axl_auto_cling_wall:
		Tools.timer(0.075, "play", pick)
	else:
		Tools.timer(0.075, "play", unequip)

func toggle_floppa_axl_lock() -> void :
	CharacterManager.floppa_axl_auto_lock = not CharacterManager.floppa_axl_auto_lock
	if CharacterManager.floppa_axl_auto_lock:
		Tools.timer(0.075, "play", pick)
	else:
		Tools.timer(0.075, "play", unequip)

func toggle_player_desperation() -> void :
	CharacterManager.player_desperation = not CharacterManager.player_desperation
	if CharacterManager.player_desperation:
		Tools.timer(0.075, "play", pick)
	else:
		Tools.timer(0.075, "play", unequip)

func toggle_weapon_get_zero() -> void :
	CharacterManager.weaponget_zero = not CharacterManager.weaponget_zero
	if CharacterManager.weaponget_zero:
		Tools.timer(0.075, "play", pick)
	else:
		Tools.timer(0.075, "play", unequip)
