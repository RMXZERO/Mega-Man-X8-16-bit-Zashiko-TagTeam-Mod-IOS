extends BossWeapon

var current_shield: Node

func fire(charge_level) -> void :
	if CharacterManager.ultimate_buster and not CharacterManager.weaponget:
		if arm_cannon.upgraded:
			if has_ammo() and not buster.has_infinite_charged_ammo():#Hermes no ammo
				Log("Firing Charged Shot")
				reduce_charged_ammo()
				fire_charged()
				fire_regular()
				start_charge_cooldown()
				last_fired_shot_was_charged = true
			elif buster.has_infinite_charged_ammo():#Icarus
				Log("Firing Charged Shot")
				reduce_charged_ammo()
				fire_charged()
				fire_regular()
				start_charge_cooldown()
				last_fired_shot_was_charged = true
			else:#Hermes no ammo
				Log("Firing Regular Shot")
				reduce_regular_ammo()
				fire_regular()
				start_cooldown()
				last_fired_shot_was_charged = false
				arm_cannon.actions[0] = "fire"
		else:#Normal
			Log("Firing Regular Shot")
			reduce_regular_ammo()
			fire_regular()
			start_cooldown()
			last_fired_shot_was_charged = false
			arm_cannon.actions[0] = "fire"
	else:
		if charge_level >= 3:
			if charge_max != null:
				if charge_max.max_charge:
					Log("Firing Charged Shot")
					reduce_charged_ammo()
					fire_charged()
					fire_regular()
					start_charge_cooldown()
					last_fired_shot_was_charged = true
		else:
			if charge_max != null:
				if not charge_max.max_charge:
					Log("Firing Regular Shot")
					reduce_regular_ammo()
					fire_regular()
					start_cooldown()
					last_fired_shot_was_charged = false

func is_cooling_down() -> bool:
	return timer > 0

func fire_regular() -> void :
	play(weapon.sound)
	if is_instance_valid(current_shield):
		current_shield.expire()
	current_shield = instantiate_projectile(weapon.regular_shot)
	set_position_as_shot_position(current_shield)

func fire_charged() -> void :
	
	var shot = instantiate_projectile(weapon.charged_shot)
	set_position_as_shot_position(shot)
	set_shot_extra_damage(shot)
