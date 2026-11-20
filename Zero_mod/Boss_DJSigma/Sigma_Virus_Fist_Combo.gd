extends EnemyMeleeAttack

export var always_can_damage: bool = true
export var take_player: bool = false
export var cancel_player_ability: bool = false

var on_hit: bool = false
var track_bullet: bool = false
var share_axl_buff: bool = false
var extra_saber_combo: bool = false
var ultimate_buster: bool = false
var player_desperation: bool = false

func _ready() -> void:
	._ready()
	save_ability()
	Event.connect("player_death",self,"reset_ability")
	
func save_ability() -> void:
	track_bullet = CharacterManager.track_bullet
	share_axl_buff = CharacterManager.share_axl_buff
	extra_saber_combo = CharacterManager.extra_saber_combo
	ultimate_buster = CharacterManager.ultimate_buster
	player_desperation = CharacterManager.player_desperation

func reset_ability() -> void:
	CharacterManager.track_bullet = track_bullet
	CharacterManager.share_axl_buff = share_axl_buff
	CharacterManager.extra_saber_combo = extra_saber_combo
	CharacterManager.ultimate_buster = ultimate_buster
	CharacterManager.player_desperation = player_desperation
	Event.disconnect("player_death",self,"reset_ability")

func activate():
	if always_can_damage:
		hit_through_invulnerability = true
	damage_in_combo = damage
	on_hit = true
	.activate()
	visible = true

func deal_damage(target) -> void:
	handle_player()
	.deal_damage(target)
	
	if take_player:
		GameManager.player.global_position.x = character.global_position.x
		GameManager.player.global_position.y = character.global_position.y - 0
	if cancel_player_ability:
		if GameManager.player.has_health():
			GameManager.player.interrupt_all_moves()
			GameManager.player.force_movement()
			GameManager.player.play_animation("damage")
			GameManager.player.animatedSprite.set_frame(0)
			Tools.timer(0.5, "player_forced_over", self)

func handle_player() -> void:
	if GameManager.player.is_executing("Ride"):
		GameManager.player.get_parent().void_touch()
	if on_hit:
		on_hit = false
		CharacterManager.player_desperation = false
		if CharacterManager.player_character == "Axl":
			CharacterManager.track_bullet = false
			CharacterManager.share_axl_buff = false
		if CharacterManager.player_character == "Zero":
			CharacterManager.extra_saber_combo = false
		if CharacterManager.player_character == "X" or CharacterManager.player_character == "Alia":
			CharacterManager.ultimate_buster = false
			Event.emit_signal("collected", "sigma_virus_fist")
			var player_charge = GameManager.player.get_node_or_null("Charge")
			if player_charge:
				player_charge.reset_input()
		GameManager.player.toggleable_invulnerabilities.clear()
		first_time_meet_sigma_virus_fist()
		var player_lifesteal = GameManager.player.get_node_or_null("LifeSteal")
		if player_lifesteal:
			player_lifesteal.deactivate()
		var player_hover = GameManager.player.get_node_or_null("Hover")
		if player_hover:
			player_hover.deactivate()
		var player_dash = GameManager.player.get_node_or_null("Dash")
		if player_dash:
			player_dash.upgraded = false
			player_dash.invulnerability_duration = 0
			player_dash.get_node_or_null("duringImage").visible = false
		var player_airdash = GameManager.player.get_node_or_null("AirDash")
		if player_airdash:
			player_airdash.upgraded = false
			player_airdash.invulnerability_duration = 0
			player_airdash.get_node_or_null("duringImage").visible = false
		if GameManager.player.current_health >= GameManager.player.max_health/3:
			GameManager.player.current_health -= GameManager.player.max_health/3
		else:
			GameManager.player.current_health = 0

func player_forced_over() -> void:
	if is_instance_valid(GameManager.player) and GameManager.player.has_health():
		GameManager.player.stop_forced_movement()

func first_time_meet_sigma_virus_fist() -> void:
	if not "sigma_virus_fist" in GameManager.collectibles or not "sigma_virus_fist_first_time" in GameManager.collectibles:
		GameManager.add_collectible_to_savedata("sigma_virus_fist")
		GameManager.add_collectible_to_savedata("sigma_virus_fist_first_time")
		Achievements.unlock("SIGMAVIRUSFIST")
		GameManager.player.zero_health_team()






