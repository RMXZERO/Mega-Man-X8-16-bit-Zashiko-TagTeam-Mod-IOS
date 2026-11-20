extends EnemyMeleeAttack

export var always_can_damage: bool = true
export var take_player: bool = false
export var cancel_player_ability: bool = false

func activate():
	if always_can_damage:
		hit_through_invulnerability = true
	damage_in_combo = damage
	.activate()
	visible = true

func deal_damage(target) -> void:
	final_hit()
	.deal_damage(target)
	if take_player:
		handle_player()
		if GameManager.player.toggleable_invulnerabilities.size() == 0:
			if GameManager.player.global_position.y >= character.global_position.y:
				GameManager.player.global_position.y = character.global_position.y - 0
	if cancel_player_ability:
		handle_player()
		if GameManager.player.toggleable_invulnerabilities.size() == 0 and GameManager.player.has_health():
			GameManager.player.interrupt_all_moves()
			GameManager.player.force_movement()
			GameManager.player.play_animation("damage")
			GameManager.player.animatedSprite.set_frame(0)
			Tools.timer(0.5, "player_forced_over", self)

func player_forced_over() -> void:
	if is_instance_valid(GameManager.player) and GameManager.player.has_health():
		GameManager.player.stop_forced_movement()

func handle_player() -> void:

	if GameManager.player.is_executing("Ride"):
		GameManager.player.get_parent().void_touch()

func final_hit() -> void:
	if is_instance_valid(GameManager.player) and GameManager.player.has_health():
		var player_damage = GameManager.player.get_node_or_null("Damage")
		var actual_damage = round(((damage * (1 - player_damage.damage_reduction / 100)) * CharacterManager.damage_get_multiplier) * player_damage.extra_damage_reduction)
		var skill_name = get_parent()
		if actual_damage > 1:
			if GameManager.player.current_health <= actual_damage:
				if skill_name.name == "7SlashCombo":
					if name == "risingsaber":
						player_damage.set_death_protection(0)
						dont_deal_damage = false
					else:
						dont_deal_damage = true
			else:
				if name != "catch_player":
					dont_deal_damage = false
		elif actual_damage <= 1:
			if GameManager.player.current_health == 1:
				if skill_name.name == "7SlashCombo":
					if name == "risingsaber":
						dont_deal_damage = false
					else:
						dont_deal_damage = true
			else:
				if name != "catch_player":
					dont_deal_damage = false

